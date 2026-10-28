@echo off
setlocal
echo Setting up World Clock Desktop Shortcut with Hotkey Ctrl+Alt+W...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$wsh = New-Object -ComObject WScript.Shell; $s = $wsh.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'World Clock.lnk')); $s.TargetPath = '%~dp0WorldClock.exe'; $s.WorkingDirectory = '%~dp0'; $s.IconLocation = '%~dp0WorldClock.exe,0'; $s.Hotkey = 'CTRL+ALT+W'; $s.Description = 'World Clock Widget (Ctrl+Alt+W)'; $s.Save()"
echo.
echo [OK] Shortcut created on Desktop! You can now launch World Clock anytime by pressing:
echo       Ctrl + Alt + W
echo.
pause
