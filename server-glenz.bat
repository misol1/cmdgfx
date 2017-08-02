@echo off
bg font 1 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf1:0,0,160,80W10
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
call centerwindow.bat 0 -20

set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=4000, DRAWMODE=0, ROTMODE=0, RX=0,RY=0,RZ=0, SHOWHELP=1
set ASPECT=0.725

set PAL0=0 0 db  0 0 db  0 0 db 0 0 db 0 0 db  0 0 db   7 0 db  7 0 db  7 0 db  7 0 db  7 0 db 7 0 db
set PAL1_0=2 0 db  2 0 db  2 0 db 2 0 db 2 0 db  2 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_1=1 0 db  1 0 db  1 0 db 1 0 db 1 0 db  1 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_2=4 0 db  4 0 db  4 0 db 4 0 db 4 0 db  4 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_3=3 0 db  3 0 db  3 0 db 3 0 db 3 0 db  3 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_4=5 0 db  5 0 db  5 0 db 5 0 db 5 0 db  5 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db
set PAL1_5=6 0 db  6 0 db  6 0 db 6 0 db 6 0 db  6 0 db   8 0 db  8 0 db  8 0 db  8 0 db  8 0 db 8 0 db

set /a COLCNT=1, BITOP=1, SCALE=340

set FNAME=cube-g.ply
set MOD=250,250,250, 0,0,0 1
set MOD2=-250,-250,-250, 0,0,0 1

set HELPMSG=text 3 0 0 SPACE,b,S/s,ENTER,d/D,h 1,78
set MSG=%HELPMSG%
set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (
	echo "cmdgfx: fbox 0 8 08 0,0,%W%,%H% & !MSG! & 3d objects\%FNAME% 0,1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL1_%%c! & 3d objects\%FNAME% 0,!BITOP! !RX!,!RY!,!RZ! 0,0,0 -!SCALE!,-!SCALE!,-!SCALE!, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL0! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	if !ROTMODE! == 0 set /a RX+=2, RY+=6, RZ-=4
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
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
echo "cmdgfx: quit"
