@echo off
fscreen /hmc
bg font 6 & cls & cmdwiz showcursor 0
if defined __ goto :START
cmdwiz getdisplaydim w
set SW=%errorlevel%
cmdwiz getdisplaydim h
set SH=%errorlevel%
set /a "W=(%SW%+10)/4"
set /a "H=(%SH%+10)/6"
set /a "SCALE=150+((%W%-220)*2)/5"
set __=.
call %0 %* | cmdgfx_gdi "" TkOSf0:0,0,%W%,%H%W12
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
set W=&set H=&set SW=&set SH=&set SCALE=
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
set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1"

	echo "cmdgfx: 3d objects\plane-apa.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 %SCALE%,%SCALE%,%SCALE%,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a RZ+=10, KEY=0
)
if not defined STOP goto LOOP

endlocal
echo "cmdgfx: quit"
