@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Z-sorted objects
if defined __ goto :START
set __=.
cmdgfx_input.exe knW13x |call %0 %* | cmdgfx_gdi "" Sf1:0,0,160,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
set /a F8W=W/2, F8H=H/2
mode %F8W%,%F8H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -20

set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=1, NOF=6, DIST=2500, MODE=0
set ASPECT=0.75

call sindef.bat

set /A XP1=0,YP1=0,ZP1=-250
set /A XP2=0,YP2=0,ZP2=250
set /A XP3=250,YP3=0,ZP3=0
set /A XP4=-250,YP4=0,ZP4=0
set /A XP5=0,YP5=-250,ZP5=0
set /A XP6=0,YP6=250,ZP6=0

set /a XRA1=5, YRA1=8, XRA2=1,YRA2=-7, XRA3=-5,YRA3=5, XRA4=-10,YRA4=-4, XRA5=3,YRA5=-12, XRA6=5,YRA6=9
set /A XROT=0,YROT=0,ZROT=0, XMUL=14000

set OBJ0=icosahedron.ply&set OBJ1=elephav.obj
set SCALE0=-131,-131,-131,0,0,0
set SCALE1=0.3,0.3,0.3,0,-360,0

call :SETCOLS

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""

	set /a "srx=(%SINE(x):x=!XROT!*31416/180%*!XMUL!>>!SHR!),XRC=!XROT!+90"
	set /a "crx=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	set /a "sry=(%SINE(x):x=!YROT!*31416/180%*!XMUL!>>!SHR!),XRC=!YROT!+90"
	set /a "cry=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)

	set /a "srz=(%SINE(x):x=!ZROT!*31416/180%*!XMUL!>>!SHR!),XRC=!ZROT!+90"
	set /a "crz=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2%%a=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2%%a=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP2%%a=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14), ZPP2%%a*=4"

	for %%i in (!MODE!) do for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set /a XR%%c+=!XRA%%c!,YR%%c+=!YRA%%c!&set CRSTR="!CRSTR:~1,-1!&3d objects\!OBJ%%i! !DRAWMODE!,1 !XR%%c!,!YR%%c!,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! !SCALE%%i! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999
	
	echo "cmdgfx: fbox 1 0 20 0,0,200,100 & !CRSTR:~1,-1! & text 7 0 20 SPACE 1,78" Ff1

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	set /a XROT-=3, YROT+=2, ZROT+=1

	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 6 set NOF=6
	if !KEY! == 32 set /a MODE=1-!MODE!
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETCOLS
set COL1=f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL2=f a db  f a b1  f a b0  a 7 b0  a 7 b1  a 7 b2  a 0 db  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL3=f c db  f c b1  f c b0  c 7 b0  c 7 b1  c 7 b2  c 0 db  c 0 db  c 4 b1 c 4 b0 4 0 db  4 0 b2  4 0 b1  4 0 b0  4 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL4=f d db  f d b1  f d b0  d 7 b0  d 7 b1  d 7 b2  d 0 db  d 0 db  d 5 b1 d 5 b0 5 0 db  5 0 b2  5 0 b1  5 0 b0  5 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL5=f e db  f e b1  f e b0  e 7 b0  e 7 b1  e 7 b2  e 0 db  e 0 db  e 6 b1 e 6 b0 6 0 db  6 0 b2  6 0 b1  6 0 b0  6 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL6=f b db  f 7 b1  f 7 b1  f 8 b1  7 0 db  7 8 b1  7 8 b2  7 0 db  7 8 b2 7 8 b0 8 0 db  8 0 b2  8 0 b1  8 0 b0  8 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
