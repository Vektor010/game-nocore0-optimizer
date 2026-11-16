# NoCore0 Gaming Optimizer для Windows

> Нативный оптимизатор соответствия процессора (CPU Affinity) для Windows 10/11. Устраняет микрофризы, просадки 1% Low FPS и снижает задержку ввода за счет полной изоляции Ядра 0 от игрового процесса без сторонних программ в фоне.

🌐 **[English Version](README.md)** • **[Русская версия](README_RU.md)**

![Banner](assets/banner.svg)

---

## ⚡ Быстрый старт (Инструкция для новичка за 30 секунд)

Если вы только что скачали проект и хотите получить максимум FPS без лишней возни:

1. **Распакуйте** скачанный архив `.zip` в любую папку.
2. **Запустите двойным кликом** файл `Game_NoCore0_Manager.bat`.
3. В появившемся окне **нажмите клавишу `1` и затем Enter**.
4. **Всё готово!** 70+ популярных игр (CS2, GTA V, Wukong, Stalker 2, RDR2, Elden Ring, MTA, Cyberpunk и др.) навсегда зарегистрированы в Windows.
5. **Запускайте свои игры как обычно** (из Steam, Epic Games, лаунчера сервера или с рабочего стола). Они сами стартуют на ядрах 1–7 без Ядра 0!

> 💡 **Скачали новую игру?** Просто перетащите мышкой её ярлык с рабочего стола на `Game_NoCore0_Manager.bat`. Твик применится за 0.1 секунды!

---

## 🎮 Список поддерживаемых игр (Пакет 70+ хитов)

Пресет `[1]` и файл `Preset_Popular_Games.reg` содержат готовые настройки для главных игр Steam, Epic Games, Battle.net, Rockstar и кастомных лаунчеров:

### 🏆 Соревновательные шутеры и Battle Royale
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

### ⚔️ Одиночные AAA-шедевры (Steam, Epic Games, GOG)
* **Black Myth: Wukong** (`b1-Win64-Shipping.exe`)
* **S.T.A.L.K.E.R. 2: Heart of Chornobyl** (`Stalker2-Win64-Shipping.exe`)
* **Cyberpunk 2077** (`Cyberpunk2077.exe`)
* **Red Dead Redemption 2** (`RDR2.exe`)
* **Elden Ring** (`eldenring.exe`)
* **Baldur's Gate 3** (`bg3.exe`, `bg3_dx11.exe`)
* **Ведьмак 3: Дикая Охота** (`witcher3.exe`)
* **Starfield** (`Starfield.exe`)
* **Hogwarts Legacy** (`HogwartsLegacy.exe`)
* **Alan Wake 2** (`AlanWake2.exe`)
* **God of War** (`GoW.exe`)
* **Ghost of Tsushima** (`GhostOfTsushima.exe`)
* **Marvel's Spider-Man** (`Spider-Man.exe`, `MilesMorales.exe`)
* **The Last of Us Part I** (`tloUp1.exe`)
* **Horizon Zero Dawn & Forbidden West** (`HorizonZeroDawn.exe`, `HorizonForbiddenWest.exe`)
* **DOOM Eternal** (`DOOMEternalx64vk.exe`)
* **Серия Resident Evil** (RE4 Remake, Village, RE2, RE3, RE7)
* **Dying Light 2** (`DyingLightGame_x64_rwdi.exe`)
* **Death Stranding** (`ds.exe`)
* **Control** (`Control_DX12.exe`, `Control_DX11.exe`)
* **Fallout 4** (`Fallout4.exe`)
* **Skyrim Special Edition** (`SkyrimSE.exe`)
* **Remnant II** (`Remnant2-Win64-Shipping.exe`)

### 🚗 Автосимуляторы и гонки
* **BeamNG.drive** (`BeamNG.drive.x64.exe`, `BeamNG.drive.exe`)
* **Euro Truck Simulator 2** (`eurotrucks2.exe`)
* **American Truck Simulator** (`amtrucks.exe`)
* **Forza Horizon 5 & 4** (`ForzaHorizon5.exe`, `ForzaHorizon4.exe`)
* **Assetto Corsa & Competizione** (`acs.exe`, `acc.exe`)

### 🌍 Кооператив, выживание и песочницы
* **Helldivers 2** (`helldivers2.exe`)
* **Warhammer 40,000: Space Marine 2** (`Warhammer 40000 Space Marine 2 - Retail.exe`)
* **Palworld** (`Palworld-Win64-Shipping.exe`)
* **Sons of the Forest** (`SonsOfTheForest.exe`)
* **Lethal Company** (`Lethal Company.exe`)
* **Manor Lords** (`ManorLords-Win64-Shipping.exe`)
* **Enshrouded** (`Enshrouded.exe`)
* **Satisfactory** (`FactoryGame-Win64-Shipping.exe`)
* **Deep Rock Galactic** (`FSD-Win64-Shipping.exe`)
* **DayZ** (`DayZ_x64.exe`)
* **Squad** (`SquadGame.exe`)
* **ARMA 3** (`arma3_x64.exe`)
* **Monster Hunter: World & Wilds** (`MonsterHunterWorld.exe`, `MonsterHunterWilds.exe`)

### 🏙️ GTA, MTA, MMO и сетевые платформы
* **Grand Theft Auto V / Online** (`GTA5.exe`, `PlayGTAV.exe`)
* **Grand Theft Auto IV** (`GTAIV.exe`, `PlayGTAIV.exe`)
* **Multi Theft Auto: San Andreas (вкл. CCDPlanet)** (`proxy_sa.exe`, `gta_sa.exe`, `Multi Theft Auto.exe`, `CCDPlanet.exe`)
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

## 🔬 В чем суть твика и почему это работает?

В архитектуре процессоров x86-64 и планировщике Windows ядро **Core 0 (логические процессоры CPU 0 и CPU 1)** исторически берет на себя большинство аппаратных прерываний системы:
- Сетевой стек (DPC/ISR прерывания сетевого контроллера)
- Системные таймеры и вывод аудио
- Высокочастотный опрос USB (игровые мыши 1000–8000 Гц)
- Фоновые службы Windows

Когда требовательные потоки игры выполняются на том же Ядре 0, они конкурируют с системными прерываниями. Это порождает задержки фреймтайма (micro-stutters) и просадки 1% Low FPS. 

Исключив Ядро 0 из маски соответствия игры, мы оставляем Ядро 0 для системных прерываний, а игра использует чистые, ненагруженные ядра 1–7.

### Таблица расчета масок аффинити

| Процессор | Конфигурация | Маска (Hex) | Десятичное | Выделенные ядра |
| :--- | :--- | :--- | :--- | :--- |
| **8C / 16T (SMT ON)** *(Ryzen 7 9850X3D, 7800X3D, 9700X, 5800X3D)* | 8 ядер / 16 потоков | `0xFFFC` | `65532` | Ядра 1–7 (14 потоков) |
| **8C / 8T (SMT OFF)** *(SMT выключен в BIOS)* | 8 ядер / 8 потоков | `0x00FE` | `254` | Ядра 1–7 (7 физических ядер) |
| **6C / 12T (SMT ON)** *(Ryzen 5 7600X, 9600X, 5600X)* | 6 ядер / 12 потоков | `0x0FFC` | `4092` | Ядра 1–5 (10 потоков) |

---

## 🛠️ Функции скрипта Game_NoCore0_Manager.bat

Запустите `Game_NoCore0_Manager.bat` двойным кликом для доступа к интерактивному меню:
- `[1]` — Зарегистрировать 70+ популярных игр в 1 клик
- `[2]` — Выбрать любой `.exe` через окно «Обзор» проводника
- `[3]` — Ввести имя файла процесса вручную
- `[4]` — Посмотреть список всех активных игр без Ядра 0
- `[5]` — Удалить конкретную игру (вернуть стандартные ядра)
- `[6]` — Полный сброс всех твиков
- `[7]` — Добавить пункт в меню правой кнопки мыши (ПКМ на любой `.exe` $\rightarrow$ *"🎮 Запускать без Ядра 0"*)
- `[L]` — Переключение языка интерфейса (English / Русский)

---

## 🔄 Как вернуть всё по умолчанию (Откат)
Запустите файл `Restore_Defaults.reg`. Он мгновенно удалит все созданные ключи аффинити из реестра и вернет стандартное поведение Windows.
