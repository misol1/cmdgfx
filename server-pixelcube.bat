@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Pixelcube
if defined __ goto :START
set __=.
cmdgfx_input.exe knW10xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a W8=W/2, H8=H/2
mode %W8%,%H8%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -15
call prepareScale.bat 1

set /a XMID=W/2, YMID=H/2, DIST=5300, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0, OW=10, COLCNT=0
set ASPECT=0.75
set COLS=f 0 db   f 7 b1  7	 0 db   7 8 b1   8 0 db  8 0 db  8 0 b1  8 0 b1   8 0 b1   8 0 b1  8 0 b1  8 0 b1

set WNAME=objects\pixelcube.ply
set /a XMUL=2200, CNT=0, BOU=0, SC=50, CRX=12, CRY=47, XPOS=200
call sindef.bat

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a CNT+=1 & if !CNT! gtr 300 set /a BOU=1
	if !BOU!==1 set /a SC+=3, XM+=3
	set /a "DIST=(%SINE(x):x=!SC!*31416/180%*!XMUL!>>!SHR!) + 3000"
	if !XPOS! gtr !XMID! set /a XPOS-=1
	if !XPOS! lss !XMID! set /a XPOS+=1
	set /a CRZ+=7,CRX+=5,CRY-=4
	
	echo "cmdgfx: fbox 7 0 20 & 3d %WNAME% %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 10,10,10,0,0,0 0,0,0,60 !XPOS!,!YMID!,!DIST!,%ASPECT% %COLS%" f1:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a W=SCRW*2*rW/100+1, H=SCRH*2*rH/100+1, XMID=W/2, YMID=H/2 & cmdwiz showcursor 0

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
