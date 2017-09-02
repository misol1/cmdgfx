@echo off
bg font 8 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12x | call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -20

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.75
set COLS_0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 .  8 0 fa
set COLS_1=f 0 04   f 0 04   b 0 .  9	 0 .   9 0 .   9 0 .  1 0 .  1 0 .  1 0 .   1 0 .   1 0 fa
set /a COLCNT=0, OBJCNT=0
set HELP=text 9 0 0 S\nP\nA\nC\nE\n\n\80t\no\n\ns\nw\ni\nt\nc\nh\n\no\nb\nj\ne\nc\nt\n 157,56
set OBJ0=plot-torus&set OBJ1=plot-sphere&set OBJ2=plot-double-sphere&set OBJ3=plot-cube&set OBJ4=linecube
set SCALE0=1.2,1.2,1.2
set SCALE1=120,120,120
set SCALE2=520,520,520
set SCALE=%SCALE0%

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do for %%o in (!OBJCNT!) do (
	echo "cmdgfx: fbox 7 0 20 0,0,%W%,%H% & 3d objects\!OBJ%%o!.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 !SCALE!,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLS_%%c! & %HELP%" F

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 

	set /A CRZ+=5,CRX+=3,CRY-=4
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 13 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
	if !KEY! == 32 set SCALE=%SCALE0%& set /A OBJCNT+=1& (if !OBJCNT!==3 set SCALE=%SCALE1%) & (if !OBJCNT!==4 set SCALE=%SCALE2%) & if !OBJCNT! gtr 4 set /a OBJCNT=0
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
