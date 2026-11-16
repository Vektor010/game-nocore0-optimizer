@(set "0=%~f0" '& set 1=%*) & powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText($env:0, [System.Text.Encoding]::UTF8); Invoke-Expression ($c.Substring($c.IndexOf([char]10)+1))" & exit /b

# ===================================================================
# Game No-Core-0 Manager: Настройка игр без Ядра 0 через нативный реестр IFEO
# Разработано под AMD Ryzen 7 9850X3D (8C/16T) и любые современные CPU
# Без фонового софта, 0% нагрузки, 100% обратимо
# ===================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# 1. Проверка прав Администратора с защитой от зацикливания (-elevated)
$isElevatedFlag = $env:1 -like "*-elevated*"
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($isElevatedFlag) {
        Write-Host "[-] Ошибка: Не удалось получить права Администратора для записи в реестр IFEO!" -ForegroundColor Red
        Write-Host "Нажмите Enter для закрытия..."
        $null = Read-Host
        exit 1
    }
    Write-Host "[*] Запрос прав Администратора для реестра IFEO..." -ForegroundColor Yellow
    Start-Process cmd.exe -Verb RunAs -ArgumentList "/c `"`"$env:0`" -elevated $env:1`""
    exit 0
}

# Очищаем флаг -elevated из аргументов
$cleanArgs = if ($env:1) { ($env:1 -replace '-elevated', '').Trim() } else { "" }

# 2. Автоматический расчет маски аффинити
$cpu = Get-CimInstance Win32_Processor
$cores = $cpu.NumberOfCores
$logical = $cpu.NumberOfLogicalProcessors
$smt = $logical -gt $cores

# Для 8C/16T (SMT ON) Ядро 0 = CPU 0 + CPU 1 -> маска FFFC (...1100).
# Если SMT OFF (8C/8T) Ядро 0 = CPU 0 -> маска FE (...1110).
if ($smt) {
    $binMask = ('1' * ($logical - 2)) + '00'
} else {
    $binMask = ('1' * ($logical - 1)) + '0'
}
$affinityMask = [Convert]::ToInt64($binMask, 2)
$affinityHex  = [Convert]::ToString($affinityMask, 16).ToUpper()

$Host.UI.RawUI.WindowTitle = "Менеджер Игр: Без Ядра 0 (0x$affinityHex)"

$ifeoBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"

# Функция добавления игры
function Add-GameToIFEO {
    param([string]$ExeName)
    $cleanName = [System.IO.Path]::GetFileName($ExeName).Trim()
    if (-not $cleanName -or -not $cleanName.EndsWith('.exe', [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Host " [-] Ошибка: '$ExeName' не является исполняемым файлом .exe" -ForegroundColor Red
        return $false
    }
    
    $keyPath = "$ifeoBase\$cleanName\PerfOptions"
    try {
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $keyPath -Name "CpuAffinityMask" -Value $affinityMask -Type DWord -Force
        Write-Host " [+] $cleanName -> УСПЕШНО! Маска 0x$affinityHex (Ядра 1-$($cores - 1))" -ForegroundColor Green
        return $true
    } catch {
        Write-Host " [-] Ошибка записи для $cleanName : $_" -ForegroundColor Red
        return $false
    }
}

# Функция удаления игры
function Remove-GameFromIFEO {
    param([string]$ExeName)
    $cleanName = [System.IO.Path]::GetFileName($ExeName).Trim()
    $keyPath = "$ifeoBase\$cleanName\PerfOptions"
    if (Test-Path $keyPath) {
        try {
            Remove-ItemProperty -Path $keyPath -Name "CpuAffinityMask" -ErrorAction SilentlyContinue
            $props = (Get-Item -Path $keyPath).Property
            if (-not $props -or $props.Count -eq 0) {
                Remove-Item -Path $keyPath -Force -ErrorAction SilentlyContinue
                $parent = "$ifeoBase\$cleanName"
                $subkeys = (Get-Item -Path $parent).SubKeyCount
                if ($subkeys -eq 0) {
                    Remove-Item -Path $parent -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host " [+] $cleanName -> Удалено из реестра (вернется работа на ВСЕХ ядрах)." -ForegroundColor Yellow
            return $true
        } catch {
            Write-Host " [-] Ошибка удаления $cleanName : $_" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host " [i] $cleanName не числится в списке настроенных игр." -ForegroundColor Gray
        return $false
    }
}

# Функция получения списка настроенных игр
function Get-ConfiguredGames {
    $results = @()
    Get-ChildItem -Path $ifeoBase -ErrorAction SilentlyContinue | ForEach-Object {
        $perf = Join-Path $_.PSPath "PerfOptions"
        if (Test-Path $perf) {
            $mask = (Get-ItemProperty -Path $perf -ErrorAction SilentlyContinue).CpuAffinityMask
            if ($null -ne $mask) {
                $hex = ('{0:X}' -f [int64]$mask)
                $results += [PSCustomObject]@{
                    ExeName = $_.PSChildName
                    MaskHex = "0x$hex"
                    Status  = if ($hex -eq $affinityHex) { "Активно (без Ядра 0)" } else { "Другая маска" }
                }
            }
        }
    }
    return $results
}

# Разрешение перетащенного пути (поддержка .lnk)
function Resolve-DroppedPath {
    param([string]$rawPath)
    $p = $rawPath.Trim('"', ' ')
    if (-not (Test-Path $p)) { return $p }
    
    if ($p.EndsWith('.lnk', [System.StringComparison]::OrdinalIgnoreCase)) {
        try {
            $sh = New-Object -ComObject WScript.Shell
            $target = $sh.CreateShortcut($p).TargetPath
            if ($target -and (Test-Path $target)) {
                return $target
            }
        } catch {}
    }
    return $p
}

# Пакет популярных игр
$popularGames = @(
    @{ Name = "Counter-Strike 2"; Exes = @("cs2.exe") },
    @{ Name = "MTA: San Andreas / CCDPlanet"; Exes = @("proxy_sa.exe", "gta_sa.exe", "Multi Theft Auto.exe", "CCDPlanet.exe") },
    @{ Name = "Hassle Online"; Exes = @("hassle.exe", "gta_sa.exe") },
    @{ Name = "ROB RUN"; Exes = @("ROB RUN.exe") },
    @{ Name = "BeamNG.drive"; Exes = @("BeamNG.drive.x64.exe", "BeamNG.drive.exe") },
    @{ Name = "Euro Truck Simulator 2"; Exes = @("eurotrucks2.exe") },
    @{ Name = "Grand Theft Auto V"; Exes = @("GTA5.exe", "PlayGTAV.exe") },
    @{ Name = "Fortnite"; Exes = @("FortniteClient-Win64-Shipping.exe") },
    @{ Name = "Dota 2"; Exes = @("dota2.exe") },
    @{ Name = "Deadlock"; Exes = @("project8.exe") },
    @{ Name = "Apex Legends"; Exes = @("r5apex.exe") },
    @{ Name = "PUBG: BATTLEGROUNDS"; Exes = @("TslGame.exe") },
    @{ Name = "Rust"; Exes = @("RustClient.exe") },
    @{ Name = "Cyberpunk 2077"; Exes = @("Cyberpunk2077.exe") },
    @{ Name = "Valorant"; Exes = @("VALORANT-Win64-Shipping.exe") },
    @{ Name = "Call of Duty / Warzone"; Exes = @("cod.exe") },
    @{ Name = "War Thunder"; Exes = @("aces.exe") },
    @{ Name = "World of Tanks"; Exes = @("WorldOfTanks.exe") },
    @{ Name = "Overwatch 2"; Exes = @("Overwatch.exe") },
    @{ Name = "Rainbow Six Siege"; Exes = @("RainbowSix.exe", "RainbowSix_Vulkan.exe") },
    @{ Name = "Escape from Tarkov"; Exes = @("EscapeFromTarkov.exe") },
    @{ Name = "Roblox"; Exes = @("RobloxPlayerBeta.exe") },
    @{ Name = "Rocket League"; Exes = @("RocketLeague.exe") },
    @{ Name = "Marvel Rivals"; Exes = @("Marvel-Win64-Shipping.exe") }
)

# ===================================================================
# СЦЕНАРИЙ 1: ПЕРЕТАСКИВАНИЕ ФАЙЛА (DRAG & DROP)
# ===================================================================
if ($cleanArgs) {
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "           МЕНЕДЖЕР ИГР: БЫСТРОЕ ДОБАВЛЕНИЕ (DRAG & DROP)          " -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "[ПРОЦЕССОР] $($cpu.Name) ($cores ядер / $logical потоков)" -ForegroundColor Green
    Write-Host "[МАСКА]     0x$affinityHex (Ядро 0 [CPU 0 $(if($smt){'+ CPU 1'})] исключено)" -ForegroundColor Yellow
    Write-Host ""

    $matches = [regex]::Matches($cleanArgs, '"([^"]+)"|(\S+)')
    
    foreach ($m in $matches) {
        $raw = $m.Value.Trim('"', ' ')
        if (-not $raw) { continue }
        $real = Resolve-DroppedPath $raw
        $filename = [System.IO.Path]::GetFileName($real)
        
        Write-Host "[*] Обработка: $filename" -ForegroundColor White
        
        # Интеллектуальное авто-раскрытие для связанных игровых файлов
        if ($filename -like "*mta*" -or $filename -eq "proxy_sa.exe" -or $filename -eq "Multi Theft Auto.exe") {
            Write-Host "    [!] Обнаружен клиент MTA:SA -> регистрируем proxy_sa.exe и gta_sa.exe..." -ForegroundColor Cyan
            Add-GameToIFEO "proxy_sa.exe" | Out-Null
            Add-GameToIFEO "gta_sa.exe" | Out-Null
        } elseif ($filename -like "*hassle*" -or $filename -eq "hassle.exe") {
            Write-Host "    [!] Обнаружен клиент Hassle Online -> регистрируем hassle.exe и gta_sa.exe..." -ForegroundColor Cyan
            Add-GameToIFEO "hassle.exe" | Out-Null
            Add-GameToIFEO "gta_sa.exe" | Out-Null
        } elseif ($filename -like "*fortnite*") {
            Write-Host "    [!] Обнаружен Fortnite -> регистрируем игровой движок FortniteClient-Win64-Shipping.exe..." -ForegroundColor Cyan
            Add-GameToIFEO "FortniteClient-Win64-Shipping.exe" | Out-Null
        } else {
            Add-GameToIFEO $filename | Out-Null
        }
    }

    Write-Host ""
    Write-Host "===================================================================" -ForegroundColor Green
    Write-Host " [ГОТОВО] Игра успешно зарегистрирована в реестре Windows IFEO!" -ForegroundColor Green
    Write-Host " Теперь при КАЖДОМ запуске Windows автоматически выделит ей Ядра 1-$($cores - 1)!" -ForegroundColor White
    Write-Host " (0% фоновых процессов, 0 МБ ОЗУ, работает для любых лаунчеров)" -ForegroundColor Gray
    Write-Host "===================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Окно закроется через 3 секунды..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
    exit 0
}

# ===================================================================
# СЦЕНАРИЙ 2: ИНТЕРАКТИВНОЕ МЕНЮ (ДВОЙНОЙ КЛИК ПО БАТНИКУ)
# ===================================================================
while ($true) {
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "   МЕНЕДЖЕР ИГР БЕЗ ЯДРА 0 (IFEO) — RYZEN 7 9850X3D (0x$affinityHex)   " -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host " [ИНФО] Процессор: $($cpu.Name)" -ForegroundColor Green
    Write-Host " [ИНФО] Конфиг:    $cores ядер / $logical потоков (SMT: $(if($smt){'ВКЛ'}else{'ВЫКЛ'}))" -ForegroundColor Green
    Write-Host " [ИНФО] Маска:     0x$affinityHex (Ядро 0 [CPU 0$(if($smt){'+1'})] выключено)" -ForegroundColor Yellow
    Write-Host " [ИНФО] Метод:     Нативный реестр Windows NT (0% фона, 0 МБ ОЗУ, VAC/EAC safe)" -ForegroundColor Gray
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Зарегистрировать популярные игры (CS2, MTA, Hassle, Fortnite, GTA V и др.)" -ForegroundColor White
    Write-Host " [2] Выбрать игру через проводник (кнопка 'Обзор')" -ForegroundColor White
    Write-Host " [3] Ввести имя файла .exe вручную (например: mygame.exe)" -ForegroundColor White
    Write-Host " [4] Список всех настроенных сейчас игр" -ForegroundColor White
    Write-Host " [5] Удалить игру из списка (вернуть стандартные ядра)" -ForegroundColor White
    Write-Host " [6] Удалить ВСЕ игры из списка (полный сброс твика)" -ForegroundColor White
    Write-Host " [7] Настроить пункт в Контекстном Меню Windows (ПКМ на любой .exe)" -ForegroundColor White
    Write-Host ""
    Write-Host " [0] Выход" -ForegroundColor Gray
    Write-Host "-------------------------------------------------------------------"
    
    $choice = Read-Host "Выберите действие [0-7]"
    if ([string]::IsNullOrWhiteSpace($choice)) {
        continue
    }

    switch ($choice.Trim()) {
        "1" {
            Clear-Host
            Write-Host "=== Регистрация пакета популярных игр ===" -ForegroundColor Cyan
            foreach ($g in $popularGames) {
                Write-Host "`n[*] Настройка: $($g.Name)..." -ForegroundColor White
                foreach ($exe in $g.Exes) {
                    Add-GameToIFEO $exe | Out-Null
                }
            }
            Write-Host "`n[УСПЕХ] Все популярные игры успешно настроены на маску 0x$affinityHex!" -ForegroundColor Green
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "2" {
            Add-Type -AssemblyName System.Windows.Forms
            $openFile = New-Object System.Windows.Forms.OpenFileDialog
            $openFile.Filter = "Исполняемые файлы (*.exe)|*.exe|Все файлы (*.*)|*.*"
            $openFile.Title = "Выберите .exe файл игры"
            if ($openFile.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $sel = [System.IO.Path]::GetFileName($openFile.FileName)
                Write-Host "`n[*] Добавление: $sel" -ForegroundColor Cyan
                Add-GameToIFEO $sel | Out-Null
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "3" {
            Write-Host ""
            $manual = Read-Host "Введите имя исполняемого файла игры (например: gta_sa.exe)"
            if ($manual) {
                Add-GameToIFEO $manual | Out-Null
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "4" {
            Clear-Host
            Write-Host "=== Список игр, запускающихся без Ядра 0 ===" -ForegroundColor Cyan
            $list = Get-ConfiguredGames
            if ($list.Count -eq 0) {
                Write-Host "`nСписок пуст. Ни одна игра еще не настроена." -ForegroundColor Yellow
            } else {
                Write-Host ""
                $list | Format-Table -AutoSize
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "5" {
            Write-Host ""
            $toRemove = Read-Host "Введите имя .exe файла для удаления (например: cs2.exe)"
            if ($toRemove) {
                Remove-GameFromIFEO $toRemove | Out-Null
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "6" {
            Write-Host ""
            $confirm = Read-Host "Вы действительно хотите удалить ВСЕ игры из списка IFEO? (y/n)"
            if ($confirm -eq 'y' -or $confirm -eq 'д') {
                $list = Get-ConfiguredGames
                foreach ($item in $list) {
                    Remove-GameFromIFEO $item.ExeName | Out-Null
                }
                Write-Host "`n[УСПЕХ] Все твики аффинити удалены. Игры будут работать на всех ядрах." -ForegroundColor Green
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "7" {
            Clear-Host
            Write-Host "=== Настройка Контекстного Меню Проводника Windows ===" -ForegroundColor Cyan
            Write-Host "Добавляет пункт при нажатии правой кнопкой мыши (ПКМ) на любой .exe:" -ForegroundColor White
            Write-Host " -> '🎮 Запускать без Ядра 0 (0x$affinityHex)'" -ForegroundColor Green
            Write-Host ""
            Write-Host " [1] Установить пункт в контекстное меню" -ForegroundColor White
            Write-Host " [2] Удалить пункт из контекстного меню" -ForegroundColor Yellow
            $ctxChoice = Read-Host "Выберите [1-2]"
            
            $ctxPath = "Registry::HKEY_CLASSES_ROOT\exefile\shell\NoCore0"
            if ($ctxChoice -eq "1") {
                try {
                    $batPath = $env:0
                    New-Item -Path $ctxPath -Force | Out-Null
                    Set-ItemProperty -Path $ctxPath -Name "(Default)" -Value "🎮 Запускать без Ядра 0 (0x$affinityHex)" -Force
                    Set-ItemProperty -Path $ctxPath -Name "Icon" -Value "imageres.dll,-109" -Force
                    $cmdPath = "$ctxPath\command"
                    New-Item -Path $cmdPath -Force | Out-Null
                    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "`"$batPath`" `"%1`"" -Force
                    Write-Host "`n[УСПЕХ] Пункт добавлен в контекстное меню для всех .exe файлов!" -ForegroundColor Green
                } catch {
                    Write-Host "`n[-] Ошибка: $_" -ForegroundColor Red
                }
            } elseif ($ctxChoice -eq "2") {
                try {
                    if (Test-Path $ctxPath) {
                        Remove-Item -Path $ctxPath -Recurse -Force
                        Write-Host "`n[УСПЕХ] Пункт контекстного меню удален." -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "`n[-] Ошибка: $_" -ForegroundColor Red
                }
            }
            Write-Host "`nНажмите Enter для возврата в меню..."
            $null = Read-Host
        }
        "0" {
            Clear-Host
            exit 0
        }
    }
}
