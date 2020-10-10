@echo off
set /a W=180, H=100
set /a F6W=W/2, F6H=H/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Object split
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,360,%H%,%W%,%H%N315Z500
set __=
set W=&set H=&set F6W=&set F6H=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -16
call prepareScale 0

set /a RX=0, RY=0, RZ=0, XMID=W/2, YMID=H/2, XMID2=W/2+W, DIST=2500, DRAWMODE=2, ACTIVE_KEY=0, WW=W*2, ZVAL=500
set ASPECT=0.7083

set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
set PAL1=f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db
set PAL2=f e b2  f e b2  f e b1  f e b0  e 0 db  e c b2  e c b1  c 0 db  c 4 b1  c 4 b2  4 0 db  4 0 b1 4 0 b0 4 0 db  4 0 b2  4 0 b1  0 0 db  0 0 db
set PAL3=b 0 db
set /A O0=-1,O1=0,O2=0,O3=-1
set PAL=!PAL%DRAWMODE%!

call :MAKESPLIT

set STOP=
:REP
for /L %%1 in (1,1,400) do if not defined STOP for %%o in (!DRAWMODE!) do (
	echo "cmdgfx: fbox 8 0 . & 3d objects\torus.plg !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 -1,-1,-1, 0,0,0 1,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & 3d objects\springy1.plg !DRAWMODE!,!O%%o! !RY!,!RZ!,!RZ! 0,0,0 -1,-1,-1, 0,0,0 1,-4000,0,10 !XMID2!,!YMID!,!DIST!,%ASPECT% !PAL! & !SPLITSCR:~1,-1!" Ff0:0,0,!WW!,!H!,!W!,!H!Z!ZVAL!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G  2>nul ) 
	
	if "!RESIZED!"=="1" set /a "W=SCRW*2*rW/100+1, H=SCRH*2*rH/100+1, XMID=W/2, XMID2=W/2+W, YMID=H/2, WW=W*2" & set /a "ZVAL=500+(H-100)*6" & cmdwiz showcursor 0 & call :MAKESPLIT
	
	set /a RX+=2, RY+=6, RZ-=4, RR=!RANDOM! %% 100
	if !RR! lss 10 set /a RY+=1
	if !RR! lss 5 set /a RX+=1
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 32 set /A DRAWMODE+=1&(if !DRAWMODE! gtr 3 set DRAWMODE=0)&for %%a in (!DRAWMODE!) do set PAL=!PAL%%a!
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 27 set STOP=1
			if !KEY! == 13 set PAL=f b b2  f b b2  f b b1  f b b0  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  0 0 db  0 0 db

			)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)	
	)
	if !ACTIVE_KEY! gtr 0 (
		if !ACTIVE_KEY! == 331 set /a XMID-=1
		if !ACTIVE_KEY! == 333 set /a XMID+=1
		if !ACTIVE_KEY! == 328 set /a XMID2+=1
		if !ACTIVE_KEY! == 336 set /a XMID2-=1
		if !ACTIVE_KEY! == 100 set /a DIST+=20
		if !ACTIVE_KEY! == 68 set /a DIST-=20
   )
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:MAKESPLIT
set SPLITSCR=""& for /l %%a in (1,2,%H%) do set SPLITSCR="!SPLITSCR:~1,-1! & block 0 %W%,%%a,%W%,1 0,%%a"
