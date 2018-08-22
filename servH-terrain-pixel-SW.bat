@echo off
set /a F6W=175/2, F6H=80/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Terrain pixel SW (mM Dd r s Zz ENTER Cursorkeys)
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0unW10x | call %0 %* | cmdgfx_gdi "" TSfa:0,0,700,480Z400
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=175, H=80
set /a W*=4, H*=6
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -15

set /a "XMID=%W%/2+10, YMID=%H%/2-80"
set /a DIST=680, ROTMODE=1
set ASPECT=0.675
set /a RX=480,RY=-1624,RZ=152, ORGDIST=%DIST%
set /a TYSCALE=60000
 
set /a ACTIVE_KEY=0, OSX=35, OSY=15, OSZ=35
set /a TEX_OFFSET=-40000, A1=0, SCALE=0, AUTOROT=0
set OBJ=TestLand3-facedouble-SW.obj

call sindef.bat

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (

   echo "cmdgfx: fbox 0 0 fa 0,0,%W%,%H% & 3d objects/!OBJ! 0,-1,!TEX_OFFSET!,0,187000,!TYSCALE!,0,-10000 !RX!,!RY!,!RZ! 0,0,0 !OSX!,!OSY!,!OSZ!,0,0,0 1,-10000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 db & 3d objects/!OBJ! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !OSX!,!OSY!,!OSZ!,0,0,0 1,-10000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 1 0 db" !XTRAFLAG!F
	set XTRAFLAG=
	
	if !ROTMODE! == 0 set /a "RX+=0,RY+=0,RZ+=2"

	set /a A1+=2
	if !SCALE!==1 set /a "OSY=0+(%SINE(x):x=!A1!*31416/180%*18>>!SHR!)"
	if !AUTOROT!==1 set /a "RX=480+(%SINE(x):x=!A1!*31416/180%*100>>!SHR!)"

	set /a TEX_OFFSET+=300
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&rem set /a RX=0,RY=0,RZ=0
			if !KEY! == 109 set XTRAFLAG=D&set /a TYSCALE+=100000 & if !TYSCALE! gtr 1000000 set /a TYSCALE=60000 
			if !KEY! == 77 set XTRAFLAG=D&set /a TYSCALE-=100000 & if !TYSCALE! lss 60000 set /a TYSCALE=1000000 
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 114 set /a AUTOROT=1-AUTOROT
			if !KEY! == 115 set /a SCALE=1-SCALE, OSY=15
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 331 set /a RY+=4
			if !ACTIVE_KEY! == 333 set /a RY-=4
			if !ACTIVE_KEY! == 328 set /a RX+=4
			if !ACTIVE_KEY! == 336 set /a RX-=4
		)
		if !ACTIVE_KEY! == 122 set /a RZ+=4
		if !ACTIVE_KEY! == 90 set /a RZ-=4
		if !ACTIVE_KEY! == 100 set /a DIST+=30
		if !ACTIVE_KEY! == 68 set /a DIST-=30
   )
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
echo "cmdgfx: quit"
title input:Q
