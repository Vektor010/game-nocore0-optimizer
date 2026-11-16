# NoCore0 Gaming Optimizer for Windows

> Native Windows process affinity tuner designed to eliminate 1% low frame drops and input stutter by dedicating CPU Core 0 exclusively to operating system DPC interrupts and background tasks, while routing game engines to high-performance cores.

🌐 **[English](README.md)** • **[Русская версия](README_RU.md)**

![Banner](assets/banner.svg)

---

## ⚡ Quick Start (For Beginners in 30 Seconds)

If you just downloaded the project and want the maximum performance boost with zero effort:

1. **Extract** the downloaded `.zip` archive to any folder.
2. **Double-click** `Game_NoCore0_Manager.bat`.
3. In the menu that appears, **press `1` and hit Enter**.
4. **Done!** 70+ popular games (CS2, GTA V, Wukong, Stalker 2, RDR2, Elden Ring, MTA, Cyberpunk, etc.) are instantly configured in the Windows kernel.
5. **Launch your games normally** (from Steam, Epic Games, server launchers, or desktop shortcuts). They will now automatically run without Core 0!

> 💡 **Got a new game?** Simply drag and drop its desktop shortcut or `.exe` file onto `Game_NoCore0_Manager.bat`. The tweak applies in 0.1s!

---

## 🎮 Supported Games (70+ Master Preset)

Option `[1]` and `Preset_Popular_Games.reg` include pre-configured support for the top PC games across Steam, Epic Games, Battle.net, and Rockstar:

### 🏆 Competitive & Battle Royale
* **Counter-Strike 2** (`cs2.exe`)
* **VALORANT** (`VALORANT-Win64-Shipping.exe`)
* **Fortnite** (`FortniteClient-Win64-Shipping.exe`)
* **Apex Legends** (`r5apex.exe`)
* **PUBG: BATTLEGROUNDS** (`TslGame.exe`)
* **Call of Duty: Warzone / BO6 / MW3** (`cod.exe`)
* **Rainbow Six Siege** (`RainbowSix.exe`, `RainbowSix_Vulkan.exe`)
* **Overwatch 2** (`Overwatch.exe`)
* **Deadlock** (`project8.exe`)
* **Marvel Rivals** (`Marvel-Win64-Shipping.exe`)
* **The Finals** (`Discovery.exe`)
* **Rust** (`RustClient.exe`)
* **Escape from Tarkov** (`EscapeFromTarkov.exe`)
* **Hunt: Showdown 1896** (`HuntGame.exe`)
* **Team Fortress 2** (`tf_win64.exe`, `tf.exe`)

### 🔮 2025–2026 Next-Gen Releases & Anticipated Hits
* **Grand Theft Auto VI (GTA 6)** (`GTA6.exe`, `PlayGTA6.exe`)
* **Kingdom Come: Deliverance II** (`KingdomCome.exe`)
* **Delta Force** (`DeltaForceClient-Win64-Shipping.exe`, `DeltaForce.exe`)
* **Monster Hunter Wilds** (`MonsterHunterWilds.exe`)
* **DOOM: The Dark Ages** (`DoomTheDarkAges.exe`, `DOOMTheDarkAges.exe`)
* **Sid Meier's Civilization VII** (`Civ7.exe`, `CivilizationVII.exe`)
* **Mafia: The Old Country** (`MafiaOldCountry.exe`, `MafiaTOC.exe`)
* **Borderlands 4** (`Borderlands4.exe`, `Borderlands4-Win64-Shipping.exe`)
* **Avowed** (`Avowed-Win64-Shipping.exe`, `Avowed.exe`)
* **Dune: Awakening** (`DuneAwakening-Win64-Shipping.exe`)
* **inZOI** (`inZOI-Win64-Shipping.exe`)
* **Subnautica 2** (`Subnautica2.exe`)
* **Crimson Desert** (`CrimsonDesert.exe`)
* **Splitgate 2** (`Splitgate2-Win64-Shipping.exe`)
* **Metaphor: ReFantazio** (`METAPHOR.exe`)

### ⚔️ Single-Player AAA Masterpieces (Steam & Epic Games)
* **The Elder Scrolls V: Skyrim (Legendary, Special Edition, VR)** (`TESV.exe`, `SkyrimSE.exe`, `SkyrimVR.exe`)
* **Black Myth: Wukong** (`b1-Win64-Shipping.exe`)
* **S.T.A.L.K.E.R. 2: Heart of Chornobyl** (`Stalker2-Win64-Shipping.exe`)
* **Cyberpunk 2077** (`Cyberpunk2077.exe`)
* **Red Dead Redemption 2** (`RDR2.exe`)
* **Elden Ring** (`eldenring.exe`)
* **Baldur's Gate 3** (`bg3.exe`, `bg3_dx11.exe`)
* **The Witcher 3: Wild Hunt** (`witcher3.exe`)
* **Starfield** (`Starfield.exe`)
* **Hogwarts Legacy** (`HogwartsLegacy.exe`)
* **Alan Wake 2** (`AlanWake2.exe`)
* **God of War** (`GoW.exe`)
* **Ghost of Tsushima** (`GhostOfTsushima.exe`)
* **Marvel's Spider-Man Remastered & Miles Morales** (`Spider-Man.exe`, `MilesMorales.exe`)
* **The Last of Us Part I** (`tloUp1.exe`)
* **Horizon Zero Dawn & Forbidden West** (`HorizonZeroDawn.exe`, `HorizonForbiddenWest.exe`)
* **DOOM Eternal** (`DOOMEternalx64vk.exe`)
* **Resident Evil Series** (RE4 Remake, Village, RE2, RE3, RE7)
* **Dying Light 2** (`DyingLightGame_x64_rwdi.exe`)
* **Death Stranding** (`ds.exe`)
* **Control** (`Control_DX12.exe`, `Control_DX11.exe`)
* **Fallout 4** (`Fallout4.exe`)
* **Remnant II** (`Remnant2-Win64-Shipping.exe`)

### 🚗 Vehicle & Driving Simulators
* **Forza Horizon Lineup (FH6, FH5, FH4)** (`ForzaHorizon6.exe`, `ForzaHorizon5.exe`, `ForzaHorizon4.exe`)
* **Forza Motorsport (Steam, Xbox App / Store, FM7)** (`forza_steamworks_release_final.exe`, `forza_gaming.desktop.x64_release_final.exe`, `ForzaMotorsport7.exe`)
* **BeamNG.drive** (`BeamNG.drive.x64.exe`, `BeamNG.drive.exe`)
* **Euro Truck Simulator 2** (`eurotrucks2.exe`)
* **American Truck Simulator** (`amtrucks.exe`)
* **Assetto Corsa & Competizione** (`acs.exe`, `acc.exe`)

### 🏕️ Open World Survival Craft & MMO Survival
* **Once Human** (`ONCE_HUMAN.exe`, `OnceHuman.exe`)
* **Icarus** (`Icarus-Win64-Shipping.exe`, `Icarus.exe`)
* **ARK: Survival Ascended & Evolved** (`ArkAscended.exe`, `ShooterGame.exe`)
* **Valheim** (`valheim.exe`)
* **Conan Exiles** (`ConanSandbox.exe`)
* **V Rising** (`VRising.exe`)
* **7 Days to Die** (`7DaysToDie.exe`)
* **The Forest & Sons of the Forest** (`TheForest.exe`, `SonsOfTheForest.exe`)
* **Raft** (`Raft.exe`)
* **Project Zomboid** (`ProjectZomboid64.exe`)
* **SCUM** (`SCUM.exe`)
* **Abiotic Factor** (`AbioticFactor-Win64-Shipping.exe`)
* **Soulmask** (`WS-Win64-Shipping.exe`)
* **Bellwright** (`Bellwright-Win64-Shipping.exe`)
* **No Man's Sky** (`NMS.exe`)
* **Grounded** (`Grounded-Win64-Shipping.exe`)
* **Green Hell** (`GH.exe`)
* **Pacific Drive** (`PacificDrive-Win64-Shipping.exe`)
* **The Planet Crafter** (`Planet Crafter.exe`)
* **Sunkenland** (`Sunkenland.exe`)

### 🌍 Co-op, Tactical & Simulation
* **Helldivers 2** (`helldivers2.exe`)
* **Warhammer 40,000: Space Marine 2** (`Warhammer 40000 Space Marine 2 - Retail.exe`)
* **Palworld** (`Palworld-Win64-Shipping.exe`)
* **Lethal Company** (`Lethal Company.exe`)
* **Manor Lords** (`ManorLords-Win64-Shipping.exe`)
* **Enshrouded** (`Enshrouded.exe`)
* **Satisfactory** (`FactoryGame-Win64-Shipping.exe`)
* **Deep Rock Galactic** (`FSD-Win64-Shipping.exe`)
* **DayZ** (`DayZ_x64.exe`)
* **Squad** (`SquadGame.exe`)
* **ARMA 3** (`arma3_x64.exe`)
* **Monster Hunter: World & Wilds** (`MonsterHunterWorld.exe`, `MonsterHunterWilds.exe`)

### 🏙️ GTA, MTA, MMOs & Strategy
* **Grand Theft Auto V / Online** (`GTA5.exe`, `PlayGTAV.exe`)
* **Grand Theft Auto IV** (`GTAIV.exe`, `PlayGTAIV.exe`)
* **Multi Theft Auto: San Andreas (incl. CCDPlanet)** (`proxy_sa.exe`, `gta_sa.exe`, `Multi Theft Auto.exe`, `CCDPlanet.exe`)
* **SA-MP (San Andreas Multiplayer)** (`samp.exe`, `gta_sa.exe`)
* **Hassle Online** (`hassle.exe`)
* **ROB RUN** (`ROB RUN.exe`)
* **Cities: Skylines 1 & 2** (`Cities2.exe`, `Cities.exe`)
* **Dota 2** (`dota2.exe`)
* **League of Legends** (`League of Legends.exe`)
* **World of Warcraft** (`Wow.exe`, `WowClassic.exe`)
* **Diablo IV** (`Diablo IV.exe`)
* **Path of Exile 1 & 2** (`PathOfExile.exe`, `PathOfExile2.exe`)
* **War Thunder** (`aces.exe`)
* **World of Tanks** (`WorldOfTanks.exe`)
* **Roblox** (`RobloxPlayerBeta.exe`)
* **Rocket League** (`RocketLeague.exe`)
* **Minecraft (Java)** (`javaw.exe`)

---

## 🔬 Technical Principle

On modern multi-core processors, CPU Core 0 (logical processors 0 and 1) handles the majority of system interrupts:
- Network packet processing (NIC DPC/ISR)
- Audio rendering and system timers
- High-frequency USB polling (gaming mice at 1000–8000 Hz)
- Windows background worker threads

When compute-heavy game threads execute on Core 0, they compete with system interrupts. This causes frame pacing variance (micro-stutters) and severe 1% Low FPS dips. By masking Core 0 out of the game's process affinity mask, the Windows kernel schedules the game exclusively across remaining physical cores.

### Affinity Mask Topology Calculation

| Architecture | Total Cores / Threads | Windows Affinity Mask | Active Cores |
| :--- | :--- | :--- | :--- |
| **8C / 16T (SMT ON)** | 8 Cores / 16 Threads | `0xFFFC` (`65532`) | Cores 1 - 7 (14 logical threads) |
| **8C / 8T (SMT OFF)** | 8 Cores / 8 Threads | `0x00FE` (`254`) | Cores 1 - 7 (7 physical cores) |
| **6C / 12T (SMT ON)** | 6 Cores / 12 Threads | `0x0FFC` (`4092`) | Cores 1 - 5 (10 logical threads) |

---

## 🛠️ Manager Features

Launch `Game_NoCore0_Manager.bat` to access the interactive bilingual menu:
- `[1]` — Register 70+ popular titles in 1 click
- `[2]` — Browse any `.exe` file via Explorer picker
- `[3]` — Enter executable name manually
- `[4]` — List all currently configured games
- `[5]` — Remove a game from IFEO (restore default cores)
- `[6]` — Remove ALL games (reset to defaults)
- `[7]` — Add right-click Explorer context menu item (`Run without Core 0`)
- `[L]` — Toggle interface language (English / Russian)

---

## 🔄 Revert to Defaults
Import `Restore_Defaults.reg` to immediately remove all affinity registry keys and restore default Windows scheduling.
