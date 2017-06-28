@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls & cmdwiz showcursor 0
set /a W=200, H=90
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a "XMID=%W%/2, YMID=%H%/2"
set /a DIST=2000, DRAWMODE=5, ROTMODE=0, SHOWHELP=1
set ASPECT=0.675
set /A RX=0,RY=0,RZ=0

set HELPMSG=text 3 0 0 N/n\-D/d 2,88
set MSG=%HELPMSG%

set /a OBJINDEX=0, NOFOBJECTS=5
call :SETOBJECT
set RENDERER=_gdi&set REND=0

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
   cmdgfx!RENDERER! "fbox 8 0 fa 0,0,%W%,%H% & !MSG! & 3d objects/!FNAME! !DRAWMODE!,!O! !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" kf0                  
   set KEY=!ERRORLEVEL!
   if !ROTMODE! == 0 set /a RX+=2,RY+=6,RZ-=4
   if not !KEY! == 0 (
      if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a RX=0,RY=0,RZ=0
      if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
      if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
      if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
      if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
      if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
      if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
      if !KEY! == 100 set /A DIST+=100
      if !KEY! == 68 set /A DIST-=100
      if !KEY! == 32 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
      if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
      if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
      if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
      if !KEY! == 112 cmdwiz getch
      if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
      if !KEY! == 27 set STOP=1
   )
)
if not defined STOP goto REP

endlocal
bg font 6
mode 80,50 & cls & cmdwiz showcursor 1
goto :eof

:SETOBJECT
if %OBJINDEX% == 0 set FNAME=cube-t5.obj& set MOD=400,400,400, 0,0,0 0&set O=20
if %OBJINDEX% == 1 set FNAME=cube-t4.obj&set MOD=400,400,400, 0,0,0 0&set O=78
if %OBJINDEX% == 2 set FNAME=cube-t3.obj& set MOD=400,400,400, 0,0,0 1&set O=-1
if %OBJINDEX% == 3 set FNAME=cube-t6.obj& set MOD=400,400,400, 0,0,0 0&set O=20
if %OBJINDEX% == 4 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1&set O=-1
call :SETCOL %DRAWMODE%
goto :eof

:SETCOL
if %OBJINDEX% == 0 set PAL=f 0 db f 0 db a 0 db a 0 db 0 0 db 0 0 db 0 0 db 0 0 db  f 1 db f 1 db  e 0 db e 0 db
if %OBJINDEX% == 1 set PAL=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  7 0 db 7 0 db  d 0 db d 0 db
if %OBJINDEX% == 2 set PAL=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  f 1 db f 1 db  e 0 db e 0 db
if %OBJINDEX% == 3 set PAL=f 2 db f 2 db b 3 db b 3 db d 5 db d 5 db 7 4 db 7 4 db  f 1 db f 1 db  f 6 db f 6 db
if %OBJINDEX% == 4 set PAL=0 0 db 0 0 b1 
