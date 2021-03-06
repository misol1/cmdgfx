@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title Zoom (no cmdgfx_input)
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOTSf0:0,0,220,110W12
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
set /a RX=0,RY=0,RZ=0, DIST=1000, MUL=2000, MMID=2600, SC=0
set ASPECT=0.66 & set STOP=
call sindef.bat
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-apa.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 150,150,150,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%" f0:0,0,!W!,!H!

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
