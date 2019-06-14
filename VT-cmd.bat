@echo off
setlocal

if "%~1"=="" echo Usage: VT-cmd "cmdgfx_VT-string" [BUFWIDTH [BUFHEIGHT]] & goto :eof

cmdwiz getcursorpos x
set /a XP=%errorlevel%
cmdwiz getcursorpos y
set /a YP=%errorlevel%
cmdwiz getconsoledim sw
set /a W=%errorlevel%-2
if not "%~2"=="" set /a W=%~2
cmdwiz getconsoledim sh
set /a H=%errorlevel%-4
if not "%~3"=="" set /a H=%~3
 
cmdgfx_VT.exe "%~1" f:%XP%,%YP%,%W%,%H%

endlocal
