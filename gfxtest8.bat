@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz showcursor 0 & cmdwiz setfont 6 & cls
set /a W=80, H=50
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set /a W*=8, H*=12

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2&set /a YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=700
set ASPECT=1.133

set OBJINDEX=0
set NOFOBJECTS=2
call :SETOBJECT

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	cmdgfx_gdi "3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 db" kZ500fa:0,0,%W%,%H%
	set KEY=!ERRORLEVEL!
	if !ROTMODE! == 0 set /a RX+=2&set /a RY+=6&set /a RZ-=4
	if !KEY! == 32 set /a DRAWTMP=!DRAWMODE! & (if !DRAWTMP! == 0 set DRAWMODE=5) & (if !DRAWTMP! == 5 set DRAWMODE=0)
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
	if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

cmdgfx_gdi "pixel 0 0 0 0,0" & endlocal
cmdwiz showcursor 1 & cls
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=cube-t-ground.obj& set MOD=400,400,400, 0,0,0 1
if %OBJINDEX% == 1 set FNAME=cube-t2.obj& set MOD=400,400,400, 0,0,0 1
