@echo off
setlocal ENABLEEXTENSIONS
set PATH=%PATH%;C:\Batch\bin
title %~1
set /a FONT=6, SHOWTITLE=0
if not "%~2"=="" set /a FONT=%~2
if not "%~3"=="" set /a SHOWTITLE=%~3
:SHOWLOOP
	cmdwiz setfont %FONT% & cmdwiz setbuffersize - - & cmdwiz fullscreen 1 & cmdwiz showcursor 0
	rem cmdgfx "fbox 8 0 fa"
	gotoxy 0 0 "\Nfa" 8 0
	set /a XP=0, YP=0

	for /F "tokens=1,2,3,4" %%a in ('cmdwiz gxyinfo %1') do @if "%%a"=="Dimension:" set /a IMGW=%%b, IMGH=%%d
	cmdwiz getconsoledim sw
	set /a SCRW=%errorlevel%
	cmdwiz getconsoledim sh
	set /a SCRH=%errorlevel%
	set /a XP=%SCRW%/2 - %IMGW%/2
	set /a YP=%SCRH%/2 - %IMGH%/2 - 1

:MINILOOP
	gotoxy 0 0 "\M1024{\gfa}" 8 0 x 
	rem cmdgfx "fbox 8 0 fa 0,0,1024,0" p
	gotoxy %XP% %YP% %1
	if %SHOWTITLE% equ 1 gotoxy 0 0 "%~n1%~x1 " 7 0 i
	cmdwiz getch
	set /a KEY=%errorlevel%
	if %KEY% == 116 set /a SHOWTITLE=1-%SHOWTITLE% & goto :MINILOOP
	if %KEY% == 102 set /a SHOWTITLE=1-%SHOWTITLE% & goto :MINILOOP
	if %KEY% == 105 set /a SHOWTITLE=1-%SHOWTITLE% & goto :MINILOOP
	
	if %KEY% == 333 call :CHANGEFILE "%~n1%~x1" "%0"
	if %KEY% == 331 call :CHANGEFILE "%~n1%~x1" "%0" -
	
if %KEY% geq 48 if %KEY% leq 57 cmdwiz fullscreen 0 & set /a FONT=%KEY%-48 & goto :SHOWLOOP
endlocal
goto :eof

:CHANGEFILE
setlocal ENABLEDELAYEDEXPANSION
set /a FND=0
for /f "tokens=*" %%F in ('dir /o%3n /-p /b *.gxy') do (
	if !FND! == 1 call %~2 "%CD%\%%F" %FONT% %SHOWTITLE% & set /a FND=0
	if "%~1"=="%%F" set /a FND=1
)
endlocal
