@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls
set /a W=80, H=50
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=5500
set ASPECT=1.13333
set DRAWMODE=0
set ROTMODE=0
set SHOWHELP=1

set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
set PAL1=f 0 db  f b b2  b 0 db  b 7 b1  b 7 b2  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  0 0 db  0 0 db
set PAL2=f b b2  f b b0  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  1 0 b0 0 0 db  0 0 db  
set PAL3=b 0 db
set /A O0=-1,O1=0,O2=0,O3=-1
set PAL=%PAL0%
set HELPMSG=text 3 0 0 n/N=object,_SPACE=mode,_RETURN=auto/manual(cursor,z/Z),_d/D=distance,_h=help 2,48
set MSG=%HELPMSG%

set OBJINDEX=0
set NOFOBJECTS=3
call :SETOBJECT
set RENDERER=&set REND=1

set STOP=
:REP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%o in (!DRAWMODE!) do (
cmdgfx!RENDERER! "fbox 8 0 . 0,0,79,49 & !MSG! & 3d objects\!FNAME! !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" k
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
if !KEY! == 100 set /A DIST+=100
if !KEY! == 68 set /A DIST-=100
if !KEY! == 111 set /A O1=1-!O1!,O2=1-!O2!
if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
if !KEY! == 112 cmdwiz getch
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cls
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=cube-t.obj& set MOD=380,380,380, 0,0,0 1
if %OBJINDEX% == 1 set FNAME=cube-t2.obj& set MOD=400,400,400, 0,0,0 1
if %OBJINDEX% == 2 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1
call :SETCOL %DRAWMODE%
goto :eof

:SETCOL
set PAL=!PAL%1!
if %OBJINDEX% == 0 if %1==0 set PAL=0 0 db
if %OBJINDEX% == 1 if %1==0 set PAL=0 0 db
if %OBJINDEX% == 2 if %1==0 set PAL=0 0 db 0 0 b1 
goto :eof
