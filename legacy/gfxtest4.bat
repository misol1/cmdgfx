@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 6 & cls
set /a W=80, H=50
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat
set /a RX=0, RY=0, RZ=0

set /a XMID=%W%/2, YMID=%H%/2
set DIST=5500
set ASPECT=0.7083
set DRAWMODE=2
set ROTMODE=0
set SHOWHELP=1

set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
set PAL1=f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db
set PAL2=f b b2  f b b2  f b b2  f b b0  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  0 0 db  0 0 db  
::set PAL2=f b b2  f b b0  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db 0 0 db
set PAL3=b 0 db
set /A O0=0,O1=0,O2=0,O3=-1,O1T=0
set PAL=!PAL%DRAWMODE%!
set HELPMSG=text 3 0 0 n/N=object,_SPACE=mode,_RETURN=auto/manual(cursor,z/Z),_d/D=distance,_h=help 2,48
set MSG=%HELPMSG%

set OBJINDEX=13
set NOFOBJECTS=20
call :SETOBJECT
set RENDERER=&set REND=1

set STOP=
:REP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%o in (!DRAWMODE!) do (
cmdgfx!RENDERER! "fbox 8 0 . 0,0,79,49 & !MSG! & 3d objects\!FNAME! !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" k!ERR!
set KEY=!ERRORLEVEL!
if !ROTMODE! == 0 set /a RX+=2&set /a RY+=6&set /a RZ-=4
if !KEY! == 32 set /A DRAWMODE+=1&(if !DRAWMODE! gtr 3 set DRAWMODE=0)&for %%a in (!DRAWMODE!) do set PAL=!PAL%%a!
if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
if !KEY! == 100 set /A DIST+=100
if !KEY! == 68 set /A DIST-=100
if !KEY! == 111 set /A O1T=1-!O1T!,O2=1-!O2!&set O1=!O0!!O1T!
if !KEY! == 98 set /A O0+=1&(if !O0! gtr 6 set O0=0)&set O1=!O0!!O1T!
if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cls
goto :eof

:SETOBJECT
set ERR=
if %OBJINDEX% == 0 set FNAME=tetrahedron.ply& set MOD=-250,-250,-250, 0,0,0 1
if %OBJINDEX% == 1 set FNAME=cube.ply& set MOD=-250,-250,-250, 0,0,0 1
if %OBJINDEX% == 2 set FNAME=icosahedron.ply& set MOD=-400,-400,-400, 0,0,0 1
if %OBJINDEX% == 3 set FNAME=shark.ply& set MOD=400,400,400, 0,0,0 1
if %OBJINDEX% == 4 set FNAME=elephav.obj& set MOD=1,1,1, 0,-360,0 1
if %OBJINDEX% == 5 set FNAME=airplane.ply& set MOD=1,1,1, -900,-600,-130 1
if %OBJINDEX% == 6 set FNAME=ant.ply& set MOD=40,40,40, 0,0,0 1
if %OBJINDEX% == 7 set FNAME=dolphins.ply& set MOD=2,2,2, 0,0,0 1
if %OBJINDEX% == 8 set FNAME=scissors.ply& set MOD=120,120,120, -5,0,0 1
if %OBJINDEX% == 9 set FNAME=steeringweel.ply& set MOD=2,2,2, 0,0,0 1
if %OBJINDEX% == 10 set FNAME=teapot.ply& set MOD=160,160,160, 0,-0.3,-0.8 0
if %OBJINDEX% == 11 set FNAME=trashcan.ply& set MOD=11,11,11, 0,0,0 0
if %OBJINDEX% == 12 set FNAME=urn2.ply& set MOD=300,300,300, 0,0,0 1
if %OBJINDEX% == 13 set FNAME=torus.plg& set MOD=-1.3,-1.3,-1.3, 0,0,0 0
if %OBJINDEX% == 14 set FNAME=sphere.plg& set MOD=-1.8,-1.8,-1.8, 0,0,0 0
if %OBJINDEX% == 15 set FNAME=springy1.plg& set MOD=-0.23,-0.23,-0.23, 0,0,0 0
if %OBJINDEX% == 16 set FNAME=chopper.plg& set MOD=-0.3,-0.3,-0.3, 0,-800,-800 1
if %OBJINDEX% == 17 set FNAME=humanoid_quad.obj& set MOD=40,40,40, -1.25,0,-8.7 1
if %OBJINDEX% == 18 set FNAME=fracttree.ply& set MOD=100,100,100, 0,0,0 1
if %OBJINDEX% == 19 set FNAME=al.obj& set MOD=150,150,150, 0,0,0 0&set ERR=e
::set FNAME=..\dev\objs\mountains.obj& set MOD=4,4,4, 0,0,0 0
::set FNAME=..\dev\objs\spaceship2.obj& set MOD=2.5,2.5,2.5, 0,0,0 1
::set FNAME=..\dev\objs\ufo.obj& set MOD=0.015,0.015,0.015, 0,0,0 0
