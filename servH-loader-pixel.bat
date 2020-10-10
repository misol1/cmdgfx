@echo off
cmdwiz setfont 6 & cls & title Loader (Space)
set /a F6W=200/2, F6H=90/2
mode %F6W%,%F6H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW30xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,200,90t4
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=90
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -20
call prepareScale.bat 0

set /a W*=4, H*=6, RX=0, RY=0, RZ=0

set /a XMID=!W!/2, YMID=!H!/2
set /a DRAWMODE=0, ROTMODE=0, DIST=500,WIRE=0,RANDVAL=5
set ASPECT=1.19948

set PAL=0 0 db 0 0 b1 

set OBJINDEX=0
set NOFOBJECTS=2
call :SETOBJECT

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	if !WIRE!==0 echo "cmdgfx: fbox 0 0 A 0,0,!W!,!H! & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & block 0 0,0,!W!,!H! 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" Ffa:0,0,!W!,!H!
	if !WIRE!==1 echo "cmdgfx: 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & block 0 0,0,!W!,!H! 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" Ffa:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
		
	if "!RESIZED!"=="1" set /a "W=SCRW*2*4*rW/100+10, H=SCRH*2*6*rH/100+6, XMID=W/2, YMID=H/2" & cmdwiz showcursor 0
		
	set /a RX+=2, RY+=6, RZ-=4
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 119 set /A WIRE=1-!WIRE!
	if !KEY! == 100 set /A DIST+=50
	if !KEY! == 68 set /A DIST-=50
	if !KEY! == 82 set /A RANDVAL+=1
	if !KEY! == 114 set /A RANDVAL-=1&if !RANDVAL! lss 1 set RANDVAL=1
	if !KEY! == 32 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 150
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1
if %OBJINDEX% == 1 set FNAME=eye.obj& set MOD=4.0,4.0,4.0, 0,-132,0 1
