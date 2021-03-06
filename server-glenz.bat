@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Glenz vector
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a F8W=W/2, F8H=H/2
cmdwiz fullscreen 0
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

call centerwindow.bat 0 -20
call prepareScale.bat 1

set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=4000, DRAWMODE=0, ROTMODE=0, RX=0,RY=0,RZ=0, SHOWHELP=1, HLPY=H-2
set ASPECT=0.725

set PAL0=0 0 db  0 0 db  0 0 db 0 0 db 0 0 db  0 0 db   7 0 db  7 0 db  7 0 db  7 0 db  7 0 db 7 0 db
set PAL1_0=2 0 db  2 0 db  2 0 db 2 0 db 2 0 db  2 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_1=1 0 db  1 0 db  1 0 db 1 0 db 1 0 db  1 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_2=4 0 db  4 0 db  4 0 db 4 0 db 4 0 db  4 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_3=3 0 db  3 0 db  3 0 db 3 0 db 3 0 db  3 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_4=5 0 db  5 0 db  5 0 db 5 0 db 5 0 db  5 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_5=6 0 db  6 0 db  6 0 db 6 0 db 6 0 db  6 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db

set /a COLCNT=1, BITOP=1, SCALE=340

set FNAME=cube-g.ply
set MOD=250,250,250, 0,0,0 1
set MOD2=-250,-250,-250, 0,0,0 1

set HELPMSG="text 3 0 0 SPACE,b,S/s,ENTER,d/D,h 1,%HLPY%"
set MSG=%HELPMSG%

set /a ACTIVE_KEY=0

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (
	echo "cmdgfx: fbox 0 8 08 0,0,!W!,!H! & !MSG:~1,-1! & 3d objects\%FNAME% 0,1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL1_%%c! & 3d objects\%FNAME% 0,!BITOP! !RX!,!RY!,!RZ! 0,0,0 -!SCALE!,-!SCALE!,-!SCALE!, 0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL0!" Ff1:0,0,!W!,!H!
	
	if !ROTMODE! == 0 set /a RX+=2, RY+=6, RZ-=4

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a W=SCRW*2*rW/100+1, H=SCRH*2*rH/100+1, XMID=W/2, YMID=H/2, HLPY=H-3 & cmdwiz showcursor 0 & set HELPMSG="text 3 0 0 SPACE,b,S/s,ENTER,d/D,h 1,!HLPY!"& if not !MSG!=="" set MSG=!HELPMSG!
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68 115 83) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
			if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 5 set COLCNT=0
			if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG="")&if !SHOWHELP!==1 set MSG=!HELPMSG!
			if !KEY! == 98 set /A BITOP+=1&(if !BITOP! gtr 7 set BITOP=0)
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 331 set /a RY+=10
			if !ACTIVE_KEY! == 333 set /a RY-=10
			if !ACTIVE_KEY! == 328 set /a RX+=10
			if !ACTIVE_KEY! == 336 set /a RX-=10
			if !ACTIVE_KEY! == 122 set /a RZ+=10
			if !ACTIVE_KEY! == 90 set /a RZ-=10
		)
		if !ACTIVE_KEY! == 100 set /a DIST+=40
		if !ACTIVE_KEY! == 68 set /a DIST-=40
		if !ACTIVE_KEY! == 115 set /A SCALE-=3
		if !ACTIVE_KEY! == 83 set /A SCALE+=3
   )
	
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
