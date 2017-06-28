@echo off
bg font 0 & mode 200,110 & cls
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe M5nuW10x | call %0 %* | cmdgfx_gdi "" Sf0:0,0,200,110
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=110
if not "%~1" == "" set /a W=120, H=70
mode con rate=31 delay=0
for /f "tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set TEXT=text 7 ? 0 SPACE,_ENTER(cursor),_D/d 1,108
set /a ZP=200, DIST=700, FONT=0, ROTMODE=0, NOFOBJECTS=5, RX=0, RY=0, RZ=0, RZ2=160
set ASPECT=0.605

if not "%~1" == "" set /a W*=4, H*=6, ZP=500, NOFOBJECTS=3 &set TEXT=&set FONT=a&set ASPECT=0.9075

set /a XMID=%W%/2, YMID=%H%/2, OBJINDEX=0
set OBJTEMP=box-temp.obj
set PLANETEMP=plane-temp.obj
call :SETOBJECT
set DELOBJCACHE=
set /a ACTIVE_KEY=0

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 00 0,0,%W%,%H% & 3d %PLANETEMP% 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 %XMID%,%YMID%,700,%ASPECT% 0 !PLANEMOD! db & 3d %OBJTEMP% !DRAWMODE!,!TRANSP! !RX!,!RY!,!RZ! 0,0,0 400,400,400,0,0,0 !CULL!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COL! & %TEXT%" e!DELOBJCACHE!Z%ZP%f%FONT%:0,0,%W%,%H%
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	set DELOBJCACHE=
	set /a RZ2-=4
	if !ROTMODE! == 0 set /a RX+=2, RY+=5, RZ-=3
	
	if !K_DOWN! == 1 (
		for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
		if !KEY! == 13 set /a ROTMODE=1-!ROTMODE!&set /a RX=0, RY=0, RZ=0
		if !KEY! == 32 set /a "OBJINDEX=(!OBJINDEX! + 1) %% %NOFOBJECTS%"&call :SETOBJECT&set DELOBJCACHE=D
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 27 set STOP=1
	)
	if !K_DOWN! == 0 (
		for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=0
	)
	
	if !ACTIVE_KEY! == 331 if !ROTMODE!==1 set /a RY+=6
	if !ACTIVE_KEY! == 333 if !ROTMODE!==1 set /a RY-=6
	if !ACTIVE_KEY! == 328 if !ROTMODE!==1 set /a RX+=6
	if !ACTIVE_KEY! == 336 if !ROTMODE!==1 set /a RX-=6
	if !ACTIVE_KEY! == 122 if !ROTMODE!==1 set /a RZ+=6
	if !ACTIVE_KEY! == 90 if !ROTMODE!==1 set /a RZ-=6
	if !ACTIVE_KEY! == 100 set /a DIST+=20
	if !ACTIVE_KEY! == 68 set /a DIST-=20

	set /a KEY=0
)
if not defined STOP goto REP

endlocal
del /Q plane-temp.obj box-temp.obj > nul 2>nul
echo "cmdgfx: quit"
echo Q>inputflags.dat
goto :eof


:SETOBJECT
set /a CULL=1, DRAWMODE=5, PLANEMOD=-8
if %OBJINDEX% == 0 set /a DRAWMODE=6 & set COL=0 -8 db 0 -8 db  0 0 db 0 0 db  0 -6 db 0 -6 db 0 -6 db 0 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 1 set COL=1 -8 db 1 -8 db  1 0 db 1 0 db  3 -6 db 3 -6 db 3 -6 db 3 -6 db  0 -3 db 0 -3 db  0 -4 db 0 -4 db &set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 2 set /a DRAWMODE=6 & set COL=0 0 db&set TRANSP=-1& call :CHANGETEXTURE %PLANETEMP% plane.obj& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj
if %OBJINDEX% == 3 set /a CULL=0 & set COL=6 4 db 6 4 db 2 2 db 2 2 db  0 2 db 0 2 db 6 5 db 6 5 db  6 6 db 6 6 db  3 6 db 3 6 db&set TRANSP=58& call :CHANGETEXTURE %PLANETEMP% plane.obj checkers2 checkers& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj checkers checkers3
if %OBJINDEX% == 4 set /a CULL=0, PLANEMOD=-1 & set COL=0 2 db 0 2 db 0 2 db 0 2 db  0 0 db 0 0 db 0 0 db 0 0 db  0 0 db 0 0 db  0 0 db 0 0 db&set TRANSP=58& call :CHANGETEXTURE %PLANETEMP% plane.obj checkers2 checkers& call :CHANGETEXTURE %OBJTEMP% cube-t-checkers.obj checkers checkers2 #usemtl usemtl
goto :eof

:CHANGETEXTURE <OUTFILE> <INFILE> <INSTR> <OUTSTR> <INSTR2> <OUTSTR2>  <INSTR3> <OUTSTR3>
del /Q %1 > nul 2>nul
for /F "tokens=*" %%a in (objects\%2) do set LINE=%%a&(if not "%4"=="" set LINE=!LINE:%3=%4!)&(if not "%6"=="" set LINE=!LINE:%5=%6!)&(if not "%8"=="" set LINE=!LINE:%7=%8!)&echo !LINE!>> %1
