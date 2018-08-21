@echo off
set /a F6W=200/2, F6H=110/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Checkerbox auto-resize
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,200,110
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=110
call centerwindow.bat 0 -20

for /f "tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set TEXT="text 7 ? 0 SPACE,_ENTER(cursor),_D/d 1,108"
set /a ZP=200, DIST=700, ROTMODE=0, NOFOBJECTS=5, RX=0, RY=0, RZ=0, RZ2=160
set ASPECT=0.605

set /a XMID=%W%/2, YMID=%H%/2, OBJINDEX=0, ACTIVE_KEY=0
call :SETOBJECT

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 00 0,0,!W!,!H! & 3d objects\checkerbox\plane!OBJINDEX!.obj 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 !XMID!,!YMID!,700,%ASPECT% 0 !PLANEMOD! db & 3d objects\checkerbox\box!OBJINDEX!.obj !DRAWMODE!,!TRANSP! !RX!,!RY!,!RZ! 0,0,0 400,400,400,0,0,0 !CULL!,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !COL! & !TEXT:~1,-1!" FeZ%ZP%f0:0,0,!W!,!H!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 

	if "!RESIZED!"=="1" set /a W=SCRW*2+1, H=SCRH*2+1, XMID=W/2, YMID=H/2, HLPY=H-2 & cmdwiz showcursor 0 & set TEXT="text 7 ? 0 SPACE,_ENTER(cursor),_D/d 1,!HLPY!"
	
	set /a RZ2-=4
	if !ROTMODE! == 0 set /a RX+=2, RY+=5, RZ-=3
	
	if !K_DOWN! == 1 (
		for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
		if !KEY! == 13 set /a ROTMODE=1-!ROTMODE!&set /a RX=0, RY=0, RZ=0
		if !KEY! == 32 set /a "OBJINDEX=(!OBJINDEX! + 1) %% %NOFOBJECTS%"&call :SETOBJECT
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 27 set STOP=1
	)
	if !K_DOWN! == 0 (
		for %%a in (298 331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=0
	)
	
	if !ACTIVE_KEY! == 331 if !ROTMODE!==1 set /a RY+=6
	if !ACTIVE_KEY! == 333 if !ROTMODE!==1 set /a RY-=6
	if !ACTIVE_KEY! == 328 if !ROTMODE!==1 set /a RX+=6
	if !ACTIVE_KEY! == 336 if !ROTMODE!==1 set /a RX-=6
	if !ACTIVE_KEY! == 122 if !ROTMODE!==1 set /a RZ+=6
	if !ACTIVE_KEY! == 90 if !ROTMODE!==1 set /a RZ-=6
	if !ACTIVE_KEY! == 100 set /a DIST+=10
	if !ACTIVE_KEY! == 68 set /a DIST-=10

	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETOBJECT
set /a CULL=1, DRAWMODE=5, PLANEMOD=-8
if %OBJINDEX% == 0 set /a DRAWMODE=6 & set COL=0 -8 db 0 -8 db  0 0 db 0 0 db  0 -6 db 0 -6 db 0 -6 db 0 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1
if %OBJINDEX% == 1 set COL=1 -8 db 1 -8 db  1 0 db 1 0 db  3 -6 db 3 -6 db 3 -6 db 3 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1
if %OBJINDEX% == 2 set /a DRAWMODE=6 & set COL=0 0 db&set TRANSP=-1
if %OBJINDEX% == 3 set /a CULL=0 & set COL=6 4 db 6 4 db 2 2 db 2 2 db  0 2 db 0 2 db 6 5 db 6 5 db  6 6 db 6 6 db  3 6 db 3 6 db&set TRANSP=58
if %OBJINDEX% == 4 set /a CULL=0, PLANEMOD=-1 & set COL=0 2 db 0 2 db 0 2 db 0 2 db  0 0 db 0 0 db 0 0 db 0 0 db  0 0 db 0 0 db  0 0 db 0 0 db&set TRANSP=58
