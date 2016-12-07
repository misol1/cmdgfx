@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 0 & cls
set /a W=320, H=110
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set W=1280&set H=680

set /a RX=0, RY=0, RZ=0

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=500
set ASPECT=1.777
set DRAWMODE=0
set ROTMODE=0
set SHOWHELP=1

set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
set PAL1=f 0 db  f b b2  b 0 db  b 7 b1  b 7 b2  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0
set PAL2=f b b2  f b b0  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  1 0 b0
set PAL3=b 0 db
set /A O0=-1,O1=0,O2=0,O3=-1
set PAL=%PAL0%
set WIRE=1

set OBJINDEX=0
set NOFOBJECTS=4
call :SETOBJECT

set STOP=
:REP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%o in (!DRAWMODE!) do (
if !WIRE!==1 start "" /high /B cmdgfx_gdi "3d objects\!FNAME! !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" fa:0,0,%W%,%H%
if !WIRE!==0 start "" /high /B cmdgfx_gdi "3d objects\!FNAME! !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" fa:0,0,%W%,%H%
cmdwiz getch nowait
set KEY=!ERRORLEVEL!
if !ROTMODE! == 0 set /a RX+=2&set /a RY+=6&set /a RZ-=4
if !KEY! == 32 set /A DRAWMODE+=1&(if !DRAWMODE! gtr 3 set DRAWMODE=0)&call :SETCOL !DRAWMODE!
if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
if !KEY! == 100 set /A DIST+=50
if !KEY! == 68 set /A DIST-=50
if !KEY! == 111 set /A O1=1-!O1!,O2=1-!O2!
if !KEY! == 119 set /A WIRE=1-!WIRE!
if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cmdwiz setfont 6&mode 80,50&cls
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1
if %OBJINDEX% == 1 set FNAME=cube-t-ground.obj& set MOD=380,380,380, 0,0,0 1
if %OBJINDEX% == 2 set FNAME=al.obj& set MOD=140,140,140, 0,0,0 0
if %OBJINDEX% == 3 set FNAME=eye.obj& set MOD=2.5,2.5,2.5, 0,-132,0 1
call :SETCOL %DRAWMODE%
goto :eof

:SETCOL
set PAL=!PAL%1!
if %OBJINDEX% == 0 if %1==0 set PAL=0 0 db 0 0 b1 
if %OBJINDEX% == 1 if %1==0 set PAL=0 0 db 0 0 .
if %OBJINDEX% == 2 if %1==0 set PAL=9 0 db 7 0 b1 8 0 b0 b 0 db
if %OBJINDEX% == 3 if %1==0 set PAL=0 0 db 0 0 .
goto :eof
