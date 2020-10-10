@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title Zoom
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12xR | call %0 %* | cmdgfx_RGB "" TSf0:0,0,220,110
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=110, F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -18
call prepareScale.bat 0

set /a XMID=%W%/2, YMID=%H%/2
set /a RX=0,RY=0,RZ=0, DIST=1000,MUL=2000, MMID=2600, SC=0, SCALE=150
set ASPECT=0.66 & set STOP=
call sindef.bat

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-123.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 !SCALE!,!SCALE!,!SCALE!,0,0,0 0,0,0,0 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 0" Ff0:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100+2, H=SCRH*2*rH/100+3, XMID=W/2, YMID=H/2, SCALE=150+((W-220)*2)/4" & cmdwiz showcursor 0

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit" & title input:Q
