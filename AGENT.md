# AI Agent & Developer Guidelines: Game No-Core-0 Optimizer

> **Purpose:** This document provides comprehensive architectural context, constraints, and instructions for any AI assistant (Claude, GPT, Gemini, Cursor, Copilot, Antigravity, Aider) or human developer continuing work on this project.

---

## 1. Project Overview & Philosophy

**Game No-Core-0 Optimizer** is an open-source Windows gaming latency and frame-pacing optimization toolkit designed primarily for **AMD Ryzen (especially X3D: 9850X3D, 7800X3D, 5800X3D)** and **Intel multi-core** architectures.

### The Problem It Solves:
On modern Windows systems, **Core 0 (CPU 0 + CPU 1 with SMT)** handles system interrupts (DPC/ISR), mouse/keyboard polling, audio pipeline, network stack, and Windows background services. When modern games run on Core 0, they compete with Windows for L3 cache and execution pipelines, causing:
- Micro-stutters and jitter.
- Degraded 0.1% and 1% Low FPS.
- Higher input latency spikes during intense action.

### The Solution:
By binding games to **Cores 1–7** (Threads 2–15 on an 8C/16T processor) and freeing Core 0 exclusively for the OS and peripheral drivers:
- **0% Background CPU & RAM:** No resident programs, daemons, background polling scripts, or third-party drivers.
- **100% Native Windows Mechanism:** Utilizes the official Microsoft NT kernel feature **IFEO** (*Image File Execution Options*) under:
  `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<GameExe>\PerfOptions`
  Value: `CpuAffinityMask` (REG_DWORD)
- **100% Anti-Cheat Safe:** Completely invisible to EAC, BattlEye, Vanguard, Ricochet, and VAC. It does not inject code, hook memory, or modify game binaries.
- **100% Reversible:** All settings can be reverted in 1 click via `Restore_Defaults.reg` or Menu Option `[6]`.

---

## 2. Strict Project Boundaries & Safety Rules

1. **DRIVE RESTRICTIONS:**
   - **NEVER** touch, write, read, or modify anything on the `D:` drive. Strictly operate within the active repository directory:
     `C:\Users\User\Documents\AutoSettingsPS\Game-NoCore0-Optimizer`
2. **PRESERVE 100% REVERSIBILITY:**
   - Any game executable added to `Preset_Popular_Games.reg` **MUST** also be added to:
     - `Restore_Defaults.reg` (to cleanly remove the key).
     - `$popularGames` array in `Game_NoCore0_Manager.bat`.
     - `README.md` (EN) and `README_RU.md` (RU) game tables.
3. **BILINGUAL REQUIREMENT:**
   - All documentation, scripts, menus, and user messages must support both **Russian (RU)** and **English (EN)**.
   - Interactive batch script must auto-detect system locale and provide `[L]` toggle.
4. **FILE ENCODINGS & INTEGRITY:**
   - `.bat` files: UTF-8 encoding with CRLF or LF (CRLF preferred for Windows CMD compatibility).
   - `.reg` files: `Windows Registry Editor Version 5.00` header, UTF-8 or ANSI.
   - `.md` documentation: UTF-8.
5. **DO NOT BREAK OS INTEGRITY:**
   - Never disable or corrupt Windows core security, cryptography (`CryptSvc`), RPC, DCOM, or network base filtering.

---

## 3. CPU Topology & Mask Mathematics

The affinity mask is a bitmask where bit 0 is CPU 0, bit 1 is CPU 1, etc.
To exclude Core 0:
- **8 Cores / 16 Threads (SMT Enabled, e.g. Ryzen 7 9850X3D / 7800X3D):**
  - Core 0 = CPU 0 and CPU 1.
  - Mask: `1111 1111 1111 1100` (binary)
  - Hex: `0xFFFC`
  - Decimal: `65532`
- **8 Cores / 8 Threads (SMT Disabled):**
  - Core 0 = CPU 0.
  - Mask: `1111 1110` (binary)
  - Hex: `0xFE`
  - Decimal: `254`
- **Dynamic Script Formula:**
  ```powershell
  if ($smt) {
      $binMask = ('1' * ($logical - 2)) + '00'
  } else {
      $binMask = ('1' * ($logical - 1)) + '0'
  }
  $affinityMask = [Convert]::ToInt64($binMask, 2)
  $affinityHex  = [Convert]::ToString($affinityMask, 16).ToUpper()
  ```

---

## 4. Game Executable Best Practices

1. **Unreal Engine 4 & 5 Titles:**
   - The launcher or launcher-stub (e.g. `Icarus.exe`, `AbioticFactor.exe`) is usually just a splash screen.
   - The actual game process running the engine is **`*-Win64-Shipping.exe`** (e.g., `Icarus-Win64-Shipping.exe`, `AbioticFactor-Win64-Shipping.exe`, `WS-Win64-Shipping.exe`, `b1-Win64-Shipping.exe`, `FortniteClient-Win64-Shipping.exe`).
   - **Always register both the base executable and the Shipping binary.**
2. **Multiplayer & Custom Clients (MTA, Hassle, GTA):**
   - MTA:SA uses `proxy_sa.exe` to launch `gta_sa.exe`. Register both.
   - Hassle Online uses `hassle.exe` and `gta_sa.exe`. Register both.
   - CoD / Warzone uses `cod.exe`.
3. **Space Sanitization:**
   - Always wrap registry paths with spaces in quotes.
   - In PowerShell, ensure `Add-GameToIFEO` strips quotation marks and appends `.exe` if omitted by user.

---

## 5. Script Architecture (`Game_NoCore0_Manager.bat`)

The manager script uses a **Polyglot Hybrid Architecture**:
- Line 1 is pure CMD batch:
  ```cmd
  @(set "0=%~f0" '& set 1=%*) & powershell -Sta -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText($env:0, [System.Text.Encoding]::UTF8); Invoke-Expression ($c.Substring($c.IndexOf([char]10)+1))" & exit /b
  ```
- Lines 2+ are pure PowerShell 5.1/7+ executing with full UTF-8 console encoding and `-Sta` (Single-Thread Apartment) mode for Windows Forms dialogs.
- Features supported:
  - Drag & Drop of any `.exe` or desktop `.lnk` shortcut.
  - Interactive Menu:
    - `[1]` Register 140+ popular games master preset.
    - `[2]` File Picker GUI (`System.Windows.Forms.OpenFileDialog`).
    - `[3]` Manual `.exe` input with auto `.exe` extension and quote cleanup.
    - `[4]` List all currently configured games in IFEO table.
    - `[5]` Remove single game.
    - `[6]` Reset / Remove all games.
    - `[7]` Install / Remove Windows Explorer right-click context menu.
    - `[L]` Language toggle (Russian <-> English).
    - `[0]` Exit.

---

## 6. How to Build & Publish Releases

1. Update `Game_NoCore0_Manager.bat`, `Preset_Popular_Games.reg`, `Restore_Defaults.reg`, `README.md`, `README_RU.md`.
2. Mirror files to active workspace root: `C:\Users\User\Documents\AutoSettingsPS\Game_NoCore0_Manager.bat`.
3. Create zip package:
   ```powershell
   Compress-Archive -Path "C:\Users\User\Documents\AutoSettingsPS\Game-NoCore0-Optimizer\*" -DestinationPath "C:\Users\User\Documents\AutoSettingsPS\Game-NoCore0-Optimizer-vX.Y.Z.zip" -Force
   ```
4. GitHub Authentication:
   - Tokens can be read from Windows Credential Manager: `gh:github.com:Vektor010` via `Advapi32.dll::CredReadW`.
5. Push commit and publish GitHub Release to repository `Vektor010/game-nocore0-optimizer`.
