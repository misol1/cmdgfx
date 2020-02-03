@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cmdwiz setfont 6 & cls
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/4+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/6+1

set /a "SCALE=150+((%W%-220)*2)/4"
set __=.
call %0 %* | cmdgfx_gdi "" m0OW12%TOP%TSf0:0,0,%W%,%H% 331111,661122,664444,991122,DD1133,AA5522,CC6633,CC2244,AA6655,DD6655,CC8855,DD9966,DD7788,EEBB99,FFEEDD
set __=
cls
cmdwiz fullscreen 0 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50 & cmdwiz showmousecursor 1
set W=&set H=&set SCALE=&set TOP=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if not %%v==SCALE set "%%v="
set /a XMID=%W%/2, YMID=%H%/2
set /a RX=0,RY=0,RZ=0, DIST=1000
set ASPECT=0.66
set STOP=

call sindef.bat
set /a MUL=2000, MMID=2600, SC=0
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
set SKIP=

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-pepper.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 %SCALE%,%SCALE%,%SCALE%,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & !SKIP! 3d objects\spaceship.obj 1,0 700,!RZ!,!RX! 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID%,%YMID%,1000,%ASPECT% 0 0 0 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	if !KEY! == 13 set /a KEY=0 & set SKTMP=!SKIP!&set SKIP=&if "!SKTMP!"=="" set SKIP=skip
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
