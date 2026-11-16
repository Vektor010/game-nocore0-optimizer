@(set "0=%~f0" '& set 1=%*) & powershell -nop -c "type -lit $env:0 | out-string | powershell -nop -c -" & exit /b ');.{

# ===================================================================
# Steam & CS2: Ultimate No-Core-0 Launcher (Single-File .BAT)
# Разработано под AMD Ryzen 7 9850X3D / X3D Zen 5
# ===================================================================

$Host.UI.RawUI.WindowTitle = "Steam: Запуск без Ядра 0"

# 1. Автоматический расчет маски под конфигурацию процессора
$cpu = Get-CimInstance Win32_Processor
$cores = $cpu.NumberOfCores
$logical = $cpu.NumberOfLogicalProcessors
$smt = $logical -gt $cores

# Для 8C/16T (SMT ON) Ядро 0 состоит из CPU 0 и CPU 1 -> маска FFFC (бинарно ...1100).
# Если SMT в BIOS выключен (8C/8T) -> маска FE (бинарно ...1110).
if ($smt) {
    $binMask = ('1' * ($logical - 2)) + '00'
} else {
    $binMask = ('1' * ($logical - 1)) + '0'
}

$affinityMask = [Convert]::ToInt64($binMask, 2)
$affinityHex  = [Convert]::ToString($affinityMask, 16).ToUpper()

Clear-Host
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "      STEAM & CS2: УЛЬТРА-ОПТИМИЗИРОВАННЫЙ ЗАПУСК БЕЗ ЯДРА 0       " -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "[ИНФО] Процессор: $($cpu.Name)" -ForegroundColor Green
Write-Host "[ИНФО] Конфигурация: $cores ядер / $logical потоков (SMT: $(if($smt){'ВКЛЮЧЕН'}else{'ВЫКЛЮЧЕН'}))" -ForegroundColor Green
Write-Host "[ИНФО] Маска сходства: 0x$affinityHex (Ядро 0 [CPU 0 $(if($smt){'+ CPU 1'})] полностью исключено)" -ForegroundColor Yellow
Write-Host ""

# 2. Поиск установленного клиента Steam
$steamExe = $null
$regKeys = @(
    "HKCU:\Software\Valve\Steam",
    "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam",
    "HKLM:\SOFTWARE\Valve\Steam"
)

foreach ($k in $regKeys) {
    if (Test-Path $k) {
        $val = (Get-ItemProperty -Path $k -ErrorAction SilentlyContinue).SteamExe
        if ($val -and (Test-Path $val)) {
            $steamExe = $val.Replace('/', '\')
            break
        }
    }
}

if (-not $steamExe) {
    $def = "C:\Program Files (x86)\Steam\steam.exe"
    if (Test-Path $def) { $steamExe = $def }
}

if (-not $steamExe) {
    Write-Host "[ОШИБКА] steam.exe не найден по стандартным путям!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# 3. Лучшие оптимизационные флаги для производительности (без скрытия окна)
# -nojoy: отключает опрос геймпадов (снижает задержки ввода мыши и DPC latency)
# -noshaders: отключает фоновую сборку шейдеров во время простоя
# -cef-disable-gpu: запрещает браузеру CEF дергать видеокарту
# -cef-delaypageload -cef-force-occlusion: замораживает скрытые вкладки Chromium в фоне
$steamArgs = "-nojoy -noshaders -cef-disable-gpu -cef-disable-gpu-sandbox -cef-delaypageload -cef-force-occlusion"

# 4. Проверка состояния Steam
$steamRunning = Get-Process -Name steam -ErrorAction SilentlyContinue

if ($steamRunning) {
    Write-Host "[*] Steam уже запущен. Применяю маску 0x$affinityHex на лету..." -ForegroundColor Cyan
    Get-Process -Name steam, steamwebhelper -ErrorAction SilentlyContinue | ForEach-Object {
        try { $_.ProcessorAffinity = [IntPtr]$affinityMask } catch {}
    }
    # Разворачиваем главное окно Steam на экран
    Start-Process "steam://open/main"
} else {
    Write-Host "[*] Запуск Steam в обычном окне с маской 0x$affinityHex..." -ForegroundColor Cyan
    & cmd.exe /c "start `"`" /affinity $affinityHex `"$steamExe`" $steamArgs"
    Start-Sleep -Seconds 2
}

# 5. Если CS2 уже запущена, страхуем и фиксируем маску на ней
$cs2Running = Get-Process -Name cs2 -ErrorAction SilentlyContinue
if ($cs2Running) {
    try {
        $cs2Running.ProcessorAffinity = [IntPtr]$affinityMask
        Write-Host "[*] Обнаружена запущенная CS2! Маска 0x$affinityHex зафиксирована." -ForegroundColor Green
    } catch {}
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Green
Write-Host " [ГОТОВО] Steam работает на ядрах 1-7 (0x$affinityHex) без Ядра 0!" -ForegroundColor Green
Write-Host " [ПАМЯТЬ] Скрипт НЕ висит в фоне и сейчас полностью завершится." -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 1
exit 0

} #end
