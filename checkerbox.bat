@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls
set /a W=200, H=110
if not "%~1" == "" set /a W=120, H=70
mode %W%,%H%
for /f "tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set TEXT=text 7 ? 0 SPACE,_ENTER(cursor),_D/d 1,108
set /a ZP=200, DIST=700, FONT=0, ROTMODE=0, NOFOBJECTS=5, RX=0, RY=0, RZ=0, RZ2=160
set ASPECT=0.605

if not "%~1" == "" set /a W*=4, H*=6, ZP=500, NOFOBJECTS=3 &set TEXT=&set FONT=a&set ASPECT=0.9075

set /a XMID=%W%/2, YMID=%H%/2, OBJINDEX=0
set OBJTEMP=box-temp.obj
set PLANETEMP=plane-temp.obj
call :SETOBJECT
::cmdwiz gettime&set ORGT=!errorlevel!

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	start "" /B /high cmdgfx_gdi "3d %PLANETEMP% 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 %XMID%,%YMID%,700,%ASPECT% 0 !PLANEMOD! db & 3d %OBJTEMP% !DRAWMODE!,!TRANSP! !RX!,!RY!,!RZ! 0,0,0 400,400,400,0,0,0 !CULL!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COL! & %TEXT%" Z%ZP%f%FONT%:0,0,%W%,%H%
	rem start "" /B /high cmdgfx_gdi "fbox 0 0 20 0,0,200,200 & 3d %PLANETEMP% 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 %XMID%,%YMID%,700,%ASPECT% 0 !PLANEMOD! db &  & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,400,%ASPECT% 0 0 db & %TEXT%" Z%ZP%f%FONT%:0,0,%W%,%H%

	cmdgfx "" nkW10
	set /a KEY=!ERRORLEVEL!, RZ2-=4
	if !ROTMODE! == 0 set /a RX+=2, RY+=5, RZ-=3
	if !KEY! == 13 set /a ROTMODE=1-!ROTMODE!&set /a RX=0, RY=0, RZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /a RY+=15
	if !KEY! == 333 if !ROTMODE!==1 set /a RY-=15
	if !KEY! == 328 if !ROTMODE!==1 set /a RX+=15
	if !KEY! == 336 if !ROTMODE!==1 set /a RX-=15
	if !KEY! == 122 if !ROTMODE!==1 set /a RZ+=15
	if !KEY! == 90 if !ROTMODE!==1 set /a RZ-=15
	if !KEY! == 100 set /a DIST+=50
	if !KEY! == 68 set /a DIST-=50
	if !KEY! == 32 set /a "OBJINDEX=(!OBJINDEX! + 1) %% %NOFOBJECTS%"&call :SETOBJECT
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP
::cmdwiz gettime&set /A TLAPSE=(!errorlevel!-%ORGT%)/100&set /a FPS=3000/!TLAPSE!&echo !FPS! fps&pause&pause

endlocal
del /Q plane-temp.obj box-temp.obj > nul 2>nul
bg font 6 & cls
mode 80,50
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
