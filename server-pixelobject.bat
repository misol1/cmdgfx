@echo off
if not defined __ cmdwiz fullscreen 0
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Pixel objects
if defined __ goto :START
set __=.
cmdgfx_input.exe m0unW12xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -20

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=1, ROTMODE=0
set /a RX=0,RY=0,RZ=0
set ASPECT=0.75
set COLS_0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 .  8 0 fa
set COLS_1=f 0 04   f 0 04   b 0 .  9	 0 .   9 0 .   9 0 .  1 0 .  1 0 .  1 0 .   1 0 .   1 0 fa
set /a COLCNT=0, OBJCNT=0
set HELP="text 9 0 0 S\nP\nA\nC\nE\n\n\80t\no\n\ns\nw\ni\nt\nc\nh\n\no\nb\nj\ne\nc\nt\n 157,56"
set OBJ0=plot-torus&set OBJ1=plot-sphere&set OBJ2=plot-double-sphere&set OBJ3=plot-cube&set OBJ4=linecube
set SCALE0=1.2,1.2,1.2
set SCALE1=120,120,120
set SCALE2=520,520,520
set SCALE=%SCALE0%

set /a SHOWHELP=1
set HELPMSG="text 3 0 0 D/d\-c\-p\-ENTER\-\g1e\g1f\g11\g10zZ\-h 1,78"
set MSG=""& if !SHOWHELP!==1 set MSG=%HELPMSG%

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do for %%o in (!OBJCNT!) do (
	echo "cmdgfx: fbox 7 0 20 0,0,!W!,!H! & 3d objects\!OBJ%%o!.ply %DRAWMODE%,1 !RX!,!RY!,!RZ! 0,0,0 !SCALE!,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !COLS_%%c! & !MSG:~1,-1!& !HELP:~1,-1!" Ff1:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul ) 

	if "!RESIZED!"=="1" set /a W=SCRW*2+1, H=SCRH*2+1, XMID=W/2, YMID=H/2, HLPY=H-25,HLPX=W-4,HLPY2=H-3 & cmdwiz showcursor 0 & set HELP="text 9 0 0 S\nP\nA\nC\nE\n\n\80t\no\n\ns\nw\ni\nt\nc\nh\n\no\nb\nj\ne\nc\nt\n !HLPX!,!HLPY!"&set HELPMSG="text 3 0 0 D/d\-c\-p\-ENTER\-\g1e\g1f\g11\g10zZ\-h 1,!HLPY2!"& if !SHOWHELP!==1 set MSG=!HELPMSG!
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a RX=0,RY=0,RZ=0
			if !KEY! == 99 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
			if !KEY! == 32 set SCALE=%SCALE0%& set /A OBJCNT+=1& (if !OBJCNT!==3 set SCALE=%SCALE1%) & (if !OBJCNT!==4 set SCALE=%SCALE2%) & if !OBJCNT! gtr 4 set /a OBJCNT=0
			if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG="")&if !SHOWHELP!==1 set MSG=!HELPMSG!
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	if !ROTMODE! == 0 set /A RZ+=5,RX+=3,RY-=4
	
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 331 set /a RY+=8
			if !ACTIVE_KEY! == 333 set /a RY-=8
			if !ACTIVE_KEY! == 328 set /a RX+=8
			if !ACTIVE_KEY! == 336 set /a RX-=8
			if !ACTIVE_KEY! == 122 set /a RZ+=8
			if !ACTIVE_KEY! == 90 set /a RZ-=8
		)
		if !ACTIVE_KEY! == 100 set /a DIST+=60
		if !ACTIVE_KEY! == 68 set /a DIST-=60
   )
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
