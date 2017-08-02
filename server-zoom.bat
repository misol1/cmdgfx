@echo off
bg font 0 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" TkOSf0:0,0,220,110W12
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=110
mode %W%, %H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set /a XMID=%W%/2, YMID=%H%/2
set /a RX=0,RY=0,RZ=0, DIST=1000
set ASPECT=0.66
call centerwindow.bat 0 -18
set STOP=

call sindef.bat
del /Q EL.dat >nul 2>nul

set /a MUL=2000, MMID=2600, SC=0
set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-apa.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 150,150,150,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
echo "cmdgfx: quit"
