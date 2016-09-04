@echo off
setlocal ENABLEDELAYEDEXPANSION
set W=160&set H=80&cmdwiz setfont 1
mode con lines=%H% cols=%W%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=4000
set ASPECT=1.45
set DRAWMODE=0
set ROTMODE=0
set /A RX=0,RY=0,RZ=0
set SHOWHELP=1

set PAL0=0 0 db  0 0 db  0 0 db 0 0 db 0 0 db  0 0 db   7 0 db  7 0 db  7 0 db  7 0 db  7 0 db 7 0 db
set PAL1_0=2 0 db  2 0 db  2 0 db 2 0 db 2 0 db  2 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_1=1 0 db  1 0 db  1 0 db 1 0 db 1 0 db  1 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_2=4 0 db  4 0 db  4 0 db 4 0 db 4 0 db  4 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_3=3 0 db  3 0 db  3 0 db 3 0 db 3 0 db  3 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_4=5 0 db  5 0 db  5 0 db 5 0 db 5 0 db  5 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_5=6 0 db  6 0 db  6 0 db 6 0 db 6 0 db  6 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db

set COLCNT=1
set BITOP=1
set SCALE=250

set FNAME=cube-g.ply
set MOD=250,250,250, 0,0,0 1
set MOD2=-250,-250,-250, 0,0,0 1

set HELPMSG=text 3 0 0 SPACE=color,_b=bit_operation,_S/s=scale_second,_RETURN=auto/manual(cursor_keys,z/Z),_d/D=distance,_p=pause,_h=help 22,78
set MSG=%HELPMSG%

set STOP=
:REP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP for %%c in (!COLCNT!) do (
cmdgfx "fbox 0 8 08 0,0,%W%,%H% & !msg! & 3d objects\%FNAME% 0,1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL1_%%c! & 3d objects\%FNAME% 0,!BITOP! !RX!,!RY!,!RZ! 0,0,0 -!SCALE!,-!SCALE!,-!SCALE!, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL0!" k
set KEY=!ERRORLEVEL!
if !ROTMODE! == 0 set /a RX+=2&set /a RY+=6&set /a RZ-=4
if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
if !KEY! == 115 set /A SCALE-=10
if !KEY! == 83 set /A SCALE+=10
if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 5 set COLCNT=0
if !KEY! == 100 set /A DIST+=100
if !KEY! == 68 set /A DIST-=100
if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
if !KEY! == 98 set /A BITOP+=1&(if !BITOP! gtr 7 set BITOP=0)
if !KEY! == 112 cmdwiz getch
if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
