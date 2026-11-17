# GitHub Copilot Instructions for Game No-Core-0 Optimizer

## Project Context
Game No-Core-0 Optimizer is a lightweight, zero-background-overhead Windows utility that isolates Core 0 (CPU 0 + CPU 1) from games using native Windows IFEO registry keys (`PerfOptions\CpuAffinityMask`). This eliminates micro-stutters and improves 0.1%/1% Low FPS, especially on AMD Ryzen X3D processors.

## Development Constraints
- Scope: Only modify files inside the repository directory (`Game-NoCore0-Optimizer`). Never access or write to drive D:.
- Reversibility: Every game added to `Preset_Popular_Games.reg` must be cleanly removable via `Restore_Defaults.reg`.
- Safety: Never modify or disable core Windows services (RPC, DCOM, CryptSvc) or anti-cheats.
- Scripting: `Game_NoCore0_Manager.bat` is a polyglot batch/PowerShell script. Do not split it into separate files unless requested. Ensure PowerShell runs with `-Sta` and UTF-8 encoding.
- Bilingual: Support both Russian (RU) and English (EN) in all scripts, menus, and documentation.
- See `AGENT.md` for detailed mathematical calculations of affinity masks and full architecture.
