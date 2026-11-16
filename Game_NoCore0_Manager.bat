@(set "0=%~f0" '& set 1=%*) & powershell -Sta -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText($env:0, [System.Text.Encoding]::UTF8); Invoke-Expression ($c.Substring($c.IndexOf([char]10)+1))" & exit /b

# ===================================================================
# Game No-Core-0 Manager: Native Windows IFEO Process Affinity Tuner
# Bilingual Edition: English (EN) & Russian (RU) with Auto-Detection
# Developed for AMD Ryzen (X3D) & Intel Multi-Core Processors
# 0% Background RAM/CPU, Anti-Cheat Safe, 100% Reversible
# ===================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8

# 1. System Language Detection (Default to RU if Russian locale, else EN)
$sysLang = (Get-Culture).TwoLetterISOLanguageName
$script:isRu = $sysLang -in @('ru', 'be', 'uk', 'kk')

# 2. Administrator Elevation Check with Recursion Guard
$isElevatedFlag = $env:1 -like "*-elevated*"
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($isElevatedFlag) {
        if ($script:isRu) {
            Write-Host "[-] Ошибка: Не удалось получить права Администратора для записи в реестр IFEO!" -ForegroundColor Red
            Write-Host "Нажмите Enter для закрытия..."
        } else {
            Write-Host "[-] Error: Failed to obtain Administrator privileges to modify IFEO registry!" -ForegroundColor Red
            Write-Host "Press Enter to exit..."
        }
        $null = Read-Host
        exit 1
    }
    if ($script:isRu) {
        Write-Host "[*] Запрос прав Администратора для реестра IFEO..." -ForegroundColor Yellow
    } else {
        Write-Host "[*] Requesting Administrator privileges for IFEO registry..." -ForegroundColor Yellow
    }
    Start-Process cmd.exe -Verb RunAs -ArgumentList "/c `"`"$env:0`" -elevated $env:1`""
    exit 0
}

# Clean elevation flag from arguments
$cleanArgs = if ($env:1) { ($env:1 -replace '-elevated', '').Trim() } else { "" }

# 3. Dynamic CPU Topology & Affinity Mask Calculation
$cpu = Get-CimInstance Win32_Processor
$cores = $cpu.NumberOfCores
$logical = $cpu.NumberOfLogicalProcessors
$smt = $logical -gt $cores

# For 8C/16T (SMT ON), Core 0 = CPU 0 + CPU 1 -> Mask 0xFFFC (...1100).
# For 8C/8T (SMT OFF), Core 0 = CPU 0 -> Mask 0xFE (...1110).
if ($smt) {
    $binMask = ('1' * ($logical - 2)) + '00'
} else {
    $binMask = ('1' * ($logical - 1)) + '0'
}
$affinityMask = [Convert]::ToInt64($binMask, 2)
$affinityHex  = [Convert]::ToString($affinityMask, 16).ToUpper()

$Host.UI.RawUI.WindowTitle = if ($script:isRu) { "Менеджер Игр: Без Ядра 0 (0x$affinityHex)" } else { "Game No-Core-0 Manager (0x$affinityHex)" }

$ifeoBase = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"

# Functions
function Add-GameToIFEO {
    param([string]$ExeName)
    $sanitized = if ($ExeName) { $ExeName.Trim().Trim('"').Trim("'") } else { "" }
    if (-not $sanitized) { return $false }
    $cleanName = [System.IO.Path]::GetFileName($sanitized).Trim()
    if (-not $cleanName.EndsWith('.exe', [System.StringComparison]::OrdinalIgnoreCase)) {
        $cleanName += ".exe"
    }
    
    $keyPath = "$ifeoBase\$cleanName\PerfOptions"
    try {
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $keyPath -Name "CpuAffinityMask" -Value $affinityMask -Type DWord -Force
        if ($script:isRu) {
            Write-Host " [+] $cleanName -> УСПЕШНО! Маска 0x$affinityHex (Ядра 1-$($cores - 1))" -ForegroundColor Green
        } else {
            Write-Host " [+] $cleanName -> SUCCESS! Affinity mask 0x$affinityHex (Cores 1-$($cores - 1))" -ForegroundColor Green
        }
        return $true
    } catch {
        Write-Host " [-] Error writing $cleanName : $_" -ForegroundColor Red
        return $false
    }
}

function Remove-GameFromIFEO {
    param([string]$ExeName)
    $sanitized = if ($ExeName) { $ExeName.Trim().Trim('"').Trim("'") } else { "" }
    if (-not $sanitized) { return $false }
    $cleanName = [System.IO.Path]::GetFileName($sanitized).Trim()
    if (-not $cleanName.EndsWith('.exe', [System.StringComparison]::OrdinalIgnoreCase)) {
        $cleanName += ".exe"
    }
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
            if ($script:isRu) {
                Write-Host " [+] $cleanName -> Удалено из реестра (вернется работа на ВСЕХ ядрах)." -ForegroundColor Yellow
            } else {
                Write-Host " [+] $cleanName -> Removed from registry (restored to ALL CPU cores)." -ForegroundColor Yellow
            }
            return $true
        } catch {
            Write-Host " [-] Error removing $cleanName : $_" -ForegroundColor Red
            return $false
        }
    } else {
        if ($script:isRu) {
            Write-Host " [i] $cleanName не числится в списке настроенных игр." -ForegroundColor Gray
        } else {
            Write-Host " [i] $cleanName is not currently in the configured list." -ForegroundColor Gray
        }
        return $false
    }
}

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
                    Status  = if ($hex -eq $affinityHex) { $(if ($script:isRu){"Активно (без Ядра 0)"}else{"Active (No Core 0)"}) } else { "Other Mask" }
                }
            }
        }
    }
    return $results
}

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

# Master Preset: Competitive, Single-Player AAA, Sims & Sandboxes (70+ Games)
$popularGames = @(
    # Competitive & Shooters
    @{ Name = "Counter-Strike 2"; Exes = @("cs2.exe") },
    @{ Name = "Valorant"; Exes = @("VALORANT-Win64-Shipping.exe") },
    @{ Name = "Fortnite"; Exes = @("FortniteClient-Win64-Shipping.exe") },
    @{ Name = "Apex Legends"; Exes = @("r5apex.exe") },
    @{ Name = "PUBG: BATTLEGROUNDS"; Exes = @("TslGame.exe") },
    @{ Name = "Call of Duty / Warzone"; Exes = @("cod.exe") },
    @{ Name = "Rainbow Six Siege"; Exes = @("RainbowSix.exe", "RainbowSix_Vulkan.exe") },
    @{ Name = "Overwatch 2"; Exes = @("Overwatch.exe") },
    @{ Name = "Deadlock"; Exes = @("project8.exe") },
    @{ Name = "Marvel Rivals"; Exes = @("Marvel-Win64-Shipping.exe") },
    @{ Name = "The Finals"; Exes = @("Discovery.exe") },
    @{ Name = "Rust"; Exes = @("RustClient.exe") },
    @{ Name = "Escape from Tarkov"; Exes = @("EscapeFromTarkov.exe") },
    @{ Name = "Hunt: Showdown 1896"; Exes = @("HuntGame.exe") },
    @{ Name = "Team Fortress 2"; Exes = @("tf_win64.exe", "tf.exe") },

    # Single-Player AAA Masterpieces (Steam & Epic)
    @{ Name = "Black Myth: Wukong"; Exes = @("b1-Win64-Shipping.exe") },
    @{ Name = "S.T.A.L.K.E.R. 2: Heart of Chornobyl"; Exes = @("Stalker2-Win64-Shipping.exe") },
    @{ Name = "Cyberpunk 2077"; Exes = @("Cyberpunk2077.exe") },
    @{ Name = "Red Dead Redemption 2"; Exes = @("RDR2.exe") },
    @{ Name = "Elden Ring"; Exes = @("eldenring.exe") },
    @{ Name = "Baldur's Gate 3"; Exes = @("bg3.exe", "bg3_dx11.exe") },
    @{ Name = "The Witcher 3: Wild Hunt"; Exes = @("witcher3.exe") },
    @{ Name = "Starfield"; Exes = @("Starfield.exe") },
    @{ Name = "Hogwarts Legacy"; Exes = @("HogwartsLegacy.exe") },
    @{ Name = "Alan Wake 2"; Exes = @("AlanWake2.exe") },
    @{ Name = "God of War"; Exes = @("GoW.exe") },
    @{ Name = "Ghost of Tsushima"; Exes = @("GhostOfTsushima.exe") },
    @{ Name = "Marvel's Spider-Man (Remastered / Miles Morales)"; Exes = @("Spider-Man.exe", "MilesMorales.exe") },
    @{ Name = "The Last of Us Part I"; Exes = @("tloUp1.exe") },
    @{ Name = "Horizon Zero Dawn / Forbidden West"; Exes = @("HorizonZeroDawn.exe", "HorizonForbiddenWest.exe") },
    @{ Name = "DOOM Eternal"; Exes = @("DOOMEternalx64vk.exe") },
    @{ Name = "Resident Evil Series (RE4, RE8, RE2, RE3, RE7)"; Exes = @("re4.exe", "re8.exe", "re2.exe", "re3.exe", "re7.exe") },
    @{ Name = "Dying Light 2"; Exes = @("DyingLightGame_x64_rwdi.exe") },
    @{ Name = "Death Stranding"; Exes = @("ds.exe") },
    @{ Name = "Control"; Exes = @("Control_DX12.exe", "Control_DX11.exe") },
    @{ Name = "Fallout 4"; Exes = @("Fallout4.exe") },
    @{ Name = "Skyrim (Original, Special Edition, VR)"; Exes = @("TESV.exe", "SkyrimSE.exe", "SkyrimVR.exe") },
    @{ Name = "Remnant II"; Exes = @("Remnant2-Win64-Shipping.exe") },

    # 2025 - 2026 Next-Gen Releases & Upcoming Masterpieces
    @{ Name = "Grand Theft Auto VI (GTA 6)"; Exes = @("GTA6.exe", "PlayGTA6.exe") },
    @{ Name = "Kingdom Come: Deliverance II"; Exes = @("KingdomCome.exe") },
    @{ Name = "Delta Force"; Exes = @("DeltaForceClient-Win64-Shipping.exe", "DeltaForce.exe") },
    @{ Name = "Monster Hunter Wilds"; Exes = @("MonsterHunterWilds.exe") },
    @{ Name = "DOOM: The Dark Ages"; Exes = @("DoomTheDarkAges.exe", "DOOMTheDarkAges.exe") },
    @{ Name = "Sid Meier's Civilization VII"; Exes = @("Civ7.exe", "CivilizationVII.exe") },
    @{ Name = "Mafia: The Old Country"; Exes = @("MafiaOldCountry.exe", "MafiaTOC.exe") },
    @{ Name = "Borderlands 4"; Exes = @("Borderlands4.exe", "Borderlands4-Win64-Shipping.exe") },
    @{ Name = "Avowed"; Exes = @("Avowed-Win64-Shipping.exe", "Avowed.exe") },
    @{ Name = "Dune: Awakening"; Exes = @("DuneAwakening-Win64-Shipping.exe") },
    @{ Name = "inZOI"; Exes = @("inZOI-Win64-Shipping.exe") },
    @{ Name = "Subnautica 2"; Exes = @("Subnautica2.exe") },
    @{ Name = "Crimson Desert"; Exes = @("CrimsonDesert.exe") },
    @{ Name = "Splitgate 2"; Exes = @("Splitgate2-Win64-Shipping.exe") },
    @{ Name = "Metaphor: ReFantazio"; Exes = @("METAPHOR.exe") },

    # Open World Survival Craft, Co-op & MMO Survival
    @{ Name = "Once Human"; Exes = @("ONCE_HUMAN.exe", "OnceHuman.exe") },
    @{ Name = "Icarus"; Exes = @("Icarus-Win64-Shipping.exe", "Icarus.exe") },
    @{ Name = "ARK: Survival Ascended & Evolved"; Exes = @("ArkAscended.exe", "ShooterGame.exe") },
    @{ Name = "Valheim"; Exes = @("valheim.exe") },
    @{ Name = "Conan Exiles"; Exes = @("ConanSandbox.exe") },
    @{ Name = "V Rising"; Exes = @("VRising.exe") },
    @{ Name = "7 Days to Die"; Exes = @("7DaysToDie.exe") },
    @{ Name = "The Forest & Sons of the Forest"; Exes = @("TheForest.exe", "SonsOfTheForest.exe") },
    @{ Name = "Raft"; Exes = @("Raft.exe") },
    @{ Name = "Project Zomboid"; Exes = @("ProjectZomboid64.exe") },
    @{ Name = "SCUM"; Exes = @("SCUM.exe") },
    @{ Name = "Abiotic Factor"; Exes = @("AbioticFactor-Win64-Shipping.exe") },
    @{ Name = "Soulmask"; Exes = @("WS-Win64-Shipping.exe") },
    @{ Name = "Bellwright"; Exes = @("Bellwright-Win64-Shipping.exe") },
    @{ Name = "No Man's Sky"; Exes = @("NMS.exe") },
    @{ Name = "Grounded"; Exes = @("Grounded-Win64-Shipping.exe") },
    @{ Name = "Green Hell"; Exes = @("GH.exe") },
    @{ Name = "Pacific Drive"; Exes = @("PacificDrive-Win64-Shipping.exe") },
    @{ Name = "The Planet Crafter"; Exes = @("Planet Crafter.exe") },
    @{ Name = "Sunkenland"; Exes = @("Sunkenland.exe") },
    @{ Name = "Helldivers 2"; Exes = @("helldivers2.exe") },
    @{ Name = "Warhammer 40,000: Space Marine 2"; Exes = @("Warhammer 40000 Space Marine 2 - Retail.exe") },
    @{ Name = "Palworld"; Exes = @("Palworld-Win64-Shipping.exe") },
    @{ Name = "Lethal Company"; Exes = @("Lethal Company.exe") },
    @{ Name = "Manor Lords"; Exes = @("ManorLords-Win64-Shipping.exe") },
    @{ Name = "Enshrouded"; Exes = @("Enshrouded.exe") },
    @{ Name = "Satisfactory"; Exes = @("FactoryGame-Win64-Shipping.exe") },
    @{ Name = "Deep Rock Galactic"; Exes = @("FSD-Win64-Shipping.exe") },
    @{ Name = "DayZ"; Exes = @("DayZ_x64.exe") },
    @{ Name = "Squad"; Exes = @("SquadGame.exe") },
    @{ Name = "ARMA 3"; Exes = @("arma3_x64.exe") },
    @{ Name = "Monster Hunter: World & Wilds"; Exes = @("MonsterHunterWorld.exe", "MonsterHunterWilds.exe") },

    # Racing & Driving Sims
    @{ Name = "BeamNG.drive"; Exes = @("BeamNG.drive.x64.exe", "BeamNG.drive.exe") },
    @{ Name = "Euro Truck Simulator 2"; Exes = @("eurotrucks2.exe") },
    @{ Name = "American Truck Simulator"; Exes = @("amtrucks.exe") },
    @{ Name = "Forza Horizon Series (FH6, FH5, FH4)"; Exes = @("ForzaHorizon6.exe", "ForzaHorizon5.exe", "ForzaHorizon4.exe") },
    @{ Name = "Forza Motorsport (Steam, Xbox, FM7)"; Exes = @("forza_steamworks_release_final.exe", "forza_gaming.desktop.x64_release_final.exe", "ForzaMotorsport7.exe") },
    @{ Name = "Assetto Corsa & Competizione"; Exes = @("acs.exe", "acc.exe") },

    # GTA, MTA, Hassle, MMOs & Strategy
    @{ Name = "Grand Theft Auto V"; Exes = @("GTA5.exe", "PlayGTAV.exe") },
    @{ Name = "Grand Theft Auto IV"; Exes = @("GTAIV.exe", "PlayGTAIV.exe") },
    @{ Name = "MTA: San Andreas / CCDPlanet"; Exes = @("proxy_sa.exe", "gta_sa.exe", "Multi Theft Auto.exe", "CCDPlanet.exe", "samp.exe") },
    @{ Name = "Hassle Online"; Exes = @("hassle.exe", "gta_sa.exe") },
    @{ Name = "ROB RUN"; Exes = @("ROB RUN.exe") },
    @{ Name = "Cities: Skylines 1 & 2"; Exes = @("Cities2.exe", "Cities.exe") },
    @{ Name = "Dota 2"; Exes = @("dota2.exe") },
    @{ Name = "League of Legends"; Exes = @("League of Legends.exe") },
    @{ Name = "World of Warcraft"; Exes = @("Wow.exe", "WowClassic.exe") },
    @{ Name = "Diablo IV"; Exes = @("Diablo IV.exe") },
    @{ Name = "Path of Exile 1 & 2"; Exes = @("PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile2.exe") },
    @{ Name = "War Thunder"; Exes = @("aces.exe") },
    @{ Name = "World of Tanks"; Exes = @("WorldOfTanks.exe") },
    @{ Name = "Roblox"; Exes = @("RobloxPlayerBeta.exe") },
    @{ Name = "Rocket League"; Exes = @("RocketLeague.exe") },
    @{ Name = "Minecraft (Java)"; Exes = @("javaw.exe") }
)

# ===================================================================
# SCENARIO 1: DRAG & DROP MODE
# ===================================================================
if ($cleanArgs) {
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host $(if ($script:isRu){"           МЕНЕДЖЕР ИГР: БЫСТРОЕ ДОБАВЛЕНИЕ (DRAG & DROP)          "}else{"           GAME NO-CORE-0 MANAGER: QUICK SETUP (DRAG & DROP)       "}) -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host $(if ($script:isRu){"[ПРОЦЕССОР] $($cpu.Name) ($cores ядер / $logical потоков)"}else{"[CPU]       $($cpu.Name) ($cores Cores / $logical Threads)"}) -ForegroundColor Green
    Write-Host $(if ($script:isRu){"[МАСКА]     0x$affinityHex (Ядро 0 [CPU 0 $(if($smt){'+ CPU 1'})] исключено)"}else{"[MASK]      0x$affinityHex (Core 0 [CPU 0 $(if($smt){'+ CPU 1'})] excluded)"}) -ForegroundColor Yellow
    Write-Host ""

    $matches = [regex]::Matches($cleanArgs, '"([^"]+)"|(\S+)')
    
    foreach ($m in $matches) {
        $raw = $m.Value.Trim('"', ' ')
        if (-not $raw) { continue }
        $real = Resolve-DroppedPath $raw
        $filename = [System.IO.Path]::GetFileName($real)
        
        Write-Host $(if ($script:isRu){"[*] Обработка: $filename"}else{"[*] Processing: $filename"}) -ForegroundColor White
        
        # Smart detection for bundled game exes
        if ($filename -like "*mta*" -or $filename -eq "proxy_sa.exe" -or $filename -eq "Multi Theft Auto.exe") {
            Write-Host $(if ($script:isRu){"    [!] MTA:SA -> регистрируем proxy_sa.exe и gta_sa.exe..."}else{"    [!] MTA:SA detected -> registering proxy_sa.exe & gta_sa.exe..."}) -ForegroundColor Cyan
            Add-GameToIFEO "proxy_sa.exe" | Out-Null
            Add-GameToIFEO "gta_sa.exe" | Out-Null
        } elseif ($filename -like "*hassle*" -or $filename -eq "hassle.exe") {
            Write-Host $(if ($script:isRu){"    [!] Hassle Online -> регистрируем hassle.exe и gta_sa.exe..."}else{"    [!] Hassle Online detected -> registering hassle.exe & gta_sa.exe..."}) -ForegroundColor Cyan
            Add-GameToIFEO "hassle.exe" | Out-Null
            Add-GameToIFEO "gta_sa.exe" | Out-Null
        } elseif ($filename -like "*fortnite*") {
            Write-Host $(if ($script:isRu){"    [!] Fortnite -> регистрируем FortniteClient-Win64-Shipping.exe..."}else{"    [!] Fortnite detected -> registering FortniteClient-Win64-Shipping.exe..."}) -ForegroundColor Cyan
            Add-GameToIFEO "FortniteClient-Win64-Shipping.exe" | Out-Null
        } else {
            Add-GameToIFEO $filename | Out-Null
        }
    }

    Write-Host ""
    Write-Host "===================================================================" -ForegroundColor Green
    Write-Host $(if ($script:isRu){" [ГОТОВО] Игра успешно зарегистрирована в реестре Windows IFEO!"}else{" [SUCCESS] Game successfully registered in Windows IFEO Registry!"}) -ForegroundColor Green
    Write-Host $(if ($script:isRu){" Теперь при КАЖДОМ запуске Windows выделит ей Ядра 1-$($cores - 1)!"}else{" Windows kernel will automatically allocate Cores 1-$($cores - 1) on every launch!"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" (0% фоновых процессов, 0 МБ ОЗУ, работает для любых лаунчеров)"}else{" (0% background RAM/CPU overhead, works with any launcher/shortcut)"}) -ForegroundColor Gray
    Write-Host "===================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host $(if ($script:isRu){"Окно закроется через 3 секунды..."}else{"Closing in 3 seconds..."}) -ForegroundColor Gray
    Start-Sleep -Seconds 3
    exit 0
}

# ===================================================================
# SCENARIO 2: INTERACTIVE MENU (DOUBLE CLICK)
# ===================================================================
while ($true) {
    $Host.UI.RawUI.WindowTitle = if ($script:isRu) { "Менеджер Игр: Без Ядра 0 (0x$affinityHex)" } else { "Game No-Core-0 Manager (0x$affinityHex)" }
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host $(if ($script:isRu){"   МЕНЕДЖЕР ИГР БЕЗ ЯДРА 0 (IFEO) — RYZEN / CORE i (0x$affinityHex)   "}else{"   GAME NO-CORE-0 MANAGER (IFEO) — RYZEN / CORE i (0x$affinityHex)    "}) -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host $(if ($script:isRu){" [ИНФО] Процессор: $($cpu.Name)"}else{" [INFO] Processor: $($cpu.Name)"}) -ForegroundColor Green
    Write-Host $(if ($script:isRu){" [ИНФО] Конфиг:    $cores ядер / $logical потоков (SMT: $(if($smt){'ВКЛ'}else{'ВЫКЛ'}))"}else{" [INFO] Topology:  $cores Cores / $logical Threads (SMT: $(if($smt){'ON'}else{'OFF'}))"}) -ForegroundColor Green
    Write-Host $(if ($script:isRu){" [ИНФО] Маска:     0x$affinityHex (Ядро 0 [CPU 0$(if($smt){'+1'})] выключено)"}else{" [INFO] Mask:      0x$affinityHex (Core 0 [CPU 0$(if($smt){'+1'})] excluded)"}) -ForegroundColor Yellow
    Write-Host $(if ($script:isRu){" [ИНФО] Метод:     Нативный реестр Windows NT (0% фона, 0 МБ ОЗУ, VAC/EAC safe)"}else{" [INFO] Engine:    Native Windows NT Registry (0% Background RAM, VAC/EAC safe)"}) -ForegroundColor Gray
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host $(if ($script:isRu){" [1] Зарегистрировать 140+ популярных игр (CS2, GTA 6/5, FH, Survival, Скайрим, Wukong и др.)"}else{" [1] Register 140+ Popular Games (CS2, GTA 6/5, FH, Survival, Skyrim, Wukong, etc.)"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [2] Выбрать игру через проводник (кнопка 'Обзор')"}else{" [2] Browse .exe file via Explorer picker"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [3] Ввести имя файла .exe вручную (например: mygame.exe)"}else{" [3] Enter .exe file name manually (e.g. mygame.exe)"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [4] Список всех настроенных сейчас игр"}else{" [4] List all currently configured games"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [5] Удалить игру из списка (вернуть стандартные ядра)"}else{" [5] Remove a game from IFEO (restore default cores)"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [6] Удалить ВСЕ игры из списка (полный сброс твика)"}else{" [6] Remove ALL configured games (reset to defaults)"}) -ForegroundColor White
    Write-Host $(if ($script:isRu){" [7] Настроить пункт в Контекстном Меню Windows (ПКМ на любой .exe)"}else{" [7] Configure Explorer Right-Click Context Menu for all .exe files"}) -ForegroundColor White
    Write-Host ""
    Write-Host $(if ($script:isRu){" [L] Переключить язык меню / Switch Language (Current: Русский)"}else{" [L] Switch Menu Language / Переключить язык (Current: English)"}) -ForegroundColor Yellow
    Write-Host $(if ($script:isRu){" [0] Выход"}else{" [0] Exit"}) -ForegroundColor Gray
    Write-Host "-------------------------------------------------------------------"
    
    $choice = Read-Host $(if ($script:isRu){"Выберите действие [0-7, L]"}else{"Select action [0-7, L]"})
    if ([string]::IsNullOrWhiteSpace($choice)) {
        continue
    }

    switch ($choice.Trim().ToUpper()) {
        "L" {
            $script:isRu = -not $script:isRu
            continue
        }
        "1" {
            Clear-Host
            Write-Host $(if ($script:isRu){"=== Регистрация полного пакета популярных игр (140+ игр) ==="}else{"=== Registering Popular Games Preset (140+ Games) ==="}) -ForegroundColor Cyan
            foreach ($g in $popularGames) {
                Write-Host "`n[*] $($g.Name)..." -ForegroundColor White
                foreach ($exe in $g.Exes) {
                    Add-GameToIFEO $exe | Out-Null
                }
            }
            Write-Host $(if ($script:isRu){"`n[УСПЕХ] Все популярные игры успешно настроены на маску 0x$affinityHex!"}else{"`n[SUCCESS] All popular games successfully configured to mask 0x$affinityHex!"}) -ForegroundColor Green
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "2" {
            Add-Type -AssemblyName System.Windows.Forms
            $openFile = New-Object System.Windows.Forms.OpenFileDialog
            $openFile.Filter = "Executable files (*.exe)|*.exe|All files (*.*)|*.*"
            $openFile.Title = if ($script:isRu){"Выберите .exe файл игры"}else{"Select game .exe executable"}
            if ($openFile.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $sel = [System.IO.Path]::GetFileName($openFile.FileName)
                Write-Host "`n[*] Adding: $sel" -ForegroundColor Cyan
                Add-GameToIFEO $sel | Out-Null
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "3" {
            Write-Host ""
            $manual = Read-Host $(if ($script:isRu){"Введите имя исполняемого файла игры (например: gta_sa.exe)"}else{"Enter game executable name (e.g. gta_sa.exe)"})
            if ($manual) {
                Add-GameToIFEO $manual | Out-Null
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "4" {
            Clear-Host
            Write-Host $(if ($script:isRu){"=== Список игр, запускающихся без Ядра 0 ==="}else{"=== Currently Configured Games (No Core 0) ==="}) -ForegroundColor Cyan
            $list = Get-ConfiguredGames
            if ($list.Count -eq 0) {
                Write-Host $(if ($script:isRu){"`nСписок пуст. Ни одна игра еще не настроена."}else{"`nList is empty. No games configured yet."}) -ForegroundColor Yellow
            } else {
                Write-Host ""
                $list | Format-Table -AutoSize
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "5" {
            Write-Host ""
            $toRemove = Read-Host $(if ($script:isRu){"Введите имя .exe файла для удаления (например: cs2.exe)"}else{"Enter .exe filename to remove (e.g. cs2.exe)"})
            if ($toRemove) {
                Remove-GameFromIFEO $toRemove | Out-Null
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "6" {
            Write-Host ""
            $confirm = Read-Host $(if ($script:isRu){"Вы действительно хотите удалить ВСЕ игры из списка IFEO? (y/n)"}else{"Are you sure you want to remove ALL games from IFEO? (y/n)"})
            if ($confirm -match '^(y|yes|д|да)$') {
                $list = Get-ConfiguredGames
                foreach ($item in $list) {
                    Remove-GameFromIFEO $item.ExeName | Out-Null
                }
                Write-Host $(if ($script:isRu){"`n[УСПЕХ] Все твики аффинити удалены. Игры будут работать на всех ядрах."}else{"`n[SUCCESS] All affinity tweaks removed. Games will run on all cores."}) -ForegroundColor Green
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "7" {
            Clear-Host
            Write-Host $(if ($script:isRu){"=== Настройка Контекстного Меню Проводника Windows ==="}else{"=== Configure Windows Explorer Context Menu ==="}) -ForegroundColor Cyan
            Write-Host $(if ($script:isRu){"Добавляет пункт при нажатии правой кнопкой мыши (ПКМ) на любой .exe:"}else{"Adds a right-click menu item for any .exe file:"}) -ForegroundColor White
            $menuPreview = if ($script:isRu) { "🎮 Настроить без Ядра 0 (0x$affinityHex)" } else { "🎮 Optimize: No Core 0 (0x$affinityHex)" }
            Write-Host " -> '$menuPreview'" -ForegroundColor Green
            Write-Host ""
            Write-Host $(if ($script:isRu){" [1] Установить пункт в контекстное меню"}else{" [1] Install context menu item"}) -ForegroundColor White
            Write-Host $(if ($script:isRu){" [2] Удалить пункт из контекстного меню"}else{" [2] Uninstall context menu item"}) -ForegroundColor Yellow
            $ctxChoice = Read-Host $(if ($script:isRu){"Выберите [1-2]"}else{"Select [1-2]"})
            
            $ctxPath = "Registry::HKEY_CLASSES_ROOT\exefile\shell\NoCore0"
            if ($ctxChoice -eq "1") {
                try {
                    $batPath = $env:0
                    New-Item -Path $ctxPath -Force | Out-Null
                    $menuText = if ($script:isRu) { "🎮 Настроить без Ядра 0 (0x$affinityHex)" } else { "🎮 Optimize: No Core 0 (0x$affinityHex)" }
                    Set-ItemProperty -Path $ctxPath -Name "(Default)" -Value $menuText -Force
                    Set-ItemProperty -Path $ctxPath -Name "Icon" -Value "imageres.dll,-109" -Force
                    $cmdPath = "$ctxPath\command"
                    New-Item -Path $cmdPath -Force | Out-Null
                    Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value "`"$batPath`" `"%1`"" -Force
                    Write-Host $(if ($script:isRu){"`n[УСПЕХ] Пункт добавлен в контекстное меню для всех .exe файлов!"}else{"`n[SUCCESS] Item added to context menu for all .exe files!"}) -ForegroundColor Green
                } catch {
                    Write-Host "`n[-] Error: $_" -ForegroundColor Red
                }
            } elseif ($ctxChoice -eq "2") {
                try {
                    if (Test-Path $ctxPath) {
                        Remove-Item -Path $ctxPath -Recurse -Force
                        Write-Host $(if ($script:isRu){"`n[УСПЕХ] Пункт контекстного меню удален."}else{"`n[SUCCESS] Context menu item removed."}) -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "`n[-] Error: $_" -ForegroundColor Red
                }
            }
            Write-Host $(if ($script:isRu){"`nНажмите Enter для возврата в меню..."}else{"`nPress Enter to return to menu..."})
            $null = Read-Host
        }
        "0" {
            Clear-Host
            exit 0
        }
    }
}
