@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls
set /a W=200, H=90
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a W*=4, H*=6, RX=0, RY=0, RZ=0

set /a XMID=%W%/2&set /a YMID=%H%/2
set /a DRAWMODE=0, ROTMODE=0, DIST=500,WIRE=0,RANDVAL=5
set ASPECT=1.19948

set PAL=0 0 db 0 0 b1 

set OBJINDEX=0
set NOFOBJECTS=2
call :SETOBJECT

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
if !WIRE!==0 start "" /high /B cmdgfx_gdi "fbox 0 0 A 0,0,%W%,%H% & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & block 0 0,0,%W%,%H% 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" fa:0,0,%W%,%H%
if !WIRE!==1 start "" /high /B cmdgfx_gdi "3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & block 0 0,0,%W%,%H% 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" fa:0,0,%W%,%H%

cmdwiz getch nowait

set KEY=!ERRORLEVEL!
if !ROTMODE! == 0 set /a RX+=2&set /a RY+=6&set /a RZ-=4
if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
if !KEY! == 119 set /A WIRE=1-!WIRE!
if !KEY! == 100 set /A DIST+=50
if !KEY! == 68 set /A DIST-=50
if !KEY! == 82 set /A RANDVAL+=1
if !KEY! == 114 set /A RANDVAL-=1&if !RANDVAL! lss 1 set RANDVAL=1
if !KEY! == 111 set /A O1=1-!O1!,O2=1-!O2!
if !KEY! == 32 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cmdwiz delay 150
bg font 6&mode 80,50&cls
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1
if %OBJINDEX% == 1 set FNAME=eye.obj& set MOD=4.0,4.0,4.0, 0,-132,0 1
