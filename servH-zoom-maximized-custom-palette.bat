@echo off
cmdwiz fullscreen 1 & cmdwiz showmousecursor 0
bg font 6 & cls & cmdwiz showcursor 0
if defined __ goto :START
cmdwiz getconsoledim sw
set /a W=%errorlevel% * 2 + 4
cmdwiz getconsoledim sh
set /a H=%errorlevel% * 2 + 8
set /a "SCALE=150+((%W%-220)*2)/4"
set __=.
cmdgfx_input.exe knW12x | call %0 %* | cmdgfx_gdi "" TSf0:0,0,%W%,%H% 331111,661122,664444,991122,DD1133,AA5522,CC6633,CC2244,AA6655,DD6655,CC8855,DD9966,DD7788,EEBB99,FFEEDD,
set __=
cls
cmdwiz fullscreen 0 & bg font 6 & cmdwiz showcursor 1 & mode 80,50 & cmdwiz showmousecursor 1
set W=&set H=&set SCALE=
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
set SKIP=skip

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-pepper.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 %SCALE%,%SCALE%,%SCALE%,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & !SKIP! 3d objects\spaceship.obj 1,0 700,!RZ!,!RX! 0,0,0 100,100,100,0,0,0 0,0,0,0 %XMID%,%YMID%,1000,%ASPECT% 0 0 0 & text 9 0 0 SPACE 0,0" F

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
	
	if !KEY! == 32 set SKTMP=!SKIP!&set SKIP=&if "!SKTMP!"=="" set SKIP=skip
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
