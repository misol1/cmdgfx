@echo off
cmdwiz setfont 8 & cls & title Bit op test
set /a F8W=160/2, F8H=80/2
cmdwiz fullscreen 0 & mode %F8W%,%F8H% & cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW10xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W  set "%%v="

call centerwindow.bat 0 -20
call prepareScale.bat 1

set /a XMID=%W%/2, YMID=%H%/2, DIST=2500, DRAWMODE=0
set ASPECT=0.75

set WNAME=objects\circle.ply
set /a SHOWHELP=1, BKG=0, BITOP=3
set /a CRX=0,CRY=0,CRZ=0,CRZ2=0, HLPY=H-2, ZVAL=500

set /a COL1=1,   COL2=2,  COL3=4,  COL4=8,  COL5=12,  COL6=10
set /a PX1=129,  PX2=-40,  PX3=-150, PX4=150,  PX5=-120, PX6=0
set /a PY1=10,   PY2=-160, PY3=100,  PY4=-100, PY5=100,  PY6=0
set /a PZ1=-200, PZ2=-150, PZ3=600,  PZ4=-140, PZ5=300,  PZ6=0
set OP=XOR

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""
	for /l %%a in (1,1,3) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% !DRAWMODE!,!BITOP! !CRX!,!CRY!,!CRZ! 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 !COL%%a! 20"
	for /l %%a in (4,1,6) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% !DRAWMODE!,!BITOP! !CRX!,!CRY!,!CRZ2! 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 !COL%%a! 20"

	echo "cmdgfx: fbox 0 !BKG! db & !CRSTR:~1,-1! & text 9 ? 0 !OP!(space)\-Bg\-!BKG!(ENTER)_d/D 1,!HLPY!" f1:0,0,!W!,!H!Z!ZVAL!

	set /a CRZ+=9,CRX+=0,CRY-=0,CRZ2-=4

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100+2, H=SCRH*2*rH/100+2, XMID=W/2, YMID=H/2, HLPY=H-4, ZVAL=500+(H-80)*10" & cmdwiz showcursor 0

	if !KEY! == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
	if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set /a BKG=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 27 set STOP=1
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
