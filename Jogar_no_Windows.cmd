@echo off
setlocal
set "GODOT_TRIAL=%USERPROFILE%\Downloads\Godot_v4.6.1-stable_win64.exe"
if exist "%GODOT_TRIAL%" goto play
for %%G in (godot.exe godot4.exe) do (
  if not "%%~$PATH:G"=="" (
    set "GODOT_TRIAL=%%~$PATH:G"
    goto play
  )
)
echo Abra a Godot 4.6.1 e importe o arquivo project.godot desta pasta.
pause
exit /b 1
:play
if /I "%~1"=="tempestade" (
  start "" "%GODOT_TRIAL%" --path "%~dp0." res://Gameplay.tscn -- --prever-tempestade
) else if /I "%~1"=="bomba" (
  start "" "%GODOT_TRIAL%" --path "%~dp0." res://Gameplay.tscn -- --prever-bomba
) else (
  start "" "%GODOT_TRIAL%" --path "%~dp0."
)
