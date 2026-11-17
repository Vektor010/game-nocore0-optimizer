# Contributing to Game No-Core-0 Optimizer

Thank you for your interest in improving **Game No-Core-0 Optimizer**!

## How to Add New Games
When proposing a new game to be added to the popular preset:
1. Identify the real game engine executable:
   - For Unreal Engine games: Look for `*-Win64-Shipping.exe`.
   - For Unity games: Usually `<GameName>.exe` + Unity crash handler.
   - For custom engines: Check Task Manager during gameplay to verify the primary CPU consumer.
2. Add the executable(s) to:
   - `Game_NoCore0_Manager.bat` (inside `$popularGames` array).
   - `Preset_Popular_Games.reg` (create `[HKLM\...\<exe>\PerfOptions]` with `"CpuAffinityMask"=dword:0000fffc`).
   - `Restore_Defaults.reg` (create `[-HKLM\...\<exe>\PerfOptions]`).
   - `README.md` and `README_RU.md` (add to corresponding genre table).
3. Verify that the entry uninstalls cleanly using `Restore_Defaults.reg`.

## Code Quality Standards
- Keep `Game_NoCore0_Manager.bat` self-contained and single-file.
- Always provide both Russian and English translations.
- Test with AST syntax parser before submitting:
  ```powershell
  $psCode = (Get-Content Game_NoCore0_Manager.bat -Raw -Encoding UTF8).Substring(...)
  [System.Management.Automation.Language.Parser]::ParseInput($psCode, [ref]$null, [ref]$errors)
  ```

For AI agents, please read `AGENT.md` before making any modifications.
