@echo off
set /a F6W=200/2, F6H=90/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Sphere texture pixel (mM c t SPACE Dd r s Zz ENTER+Cursorkeys)
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10xR | call %0 %* | cmdgfx_gdi "" Sfa:0,0,800,540Z1000T
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=200, H=90
set /a W*=4, H*=6
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -15

set /a "XMID=%W%/2, YMID=%H%/2"
set /a DIST=11100, DRAWMODE=0, ROTMODE=0
set ASPECT=1
set /A RX=0,RY=0,RZ=0, ORGDIST=%DIST%

set /a ACTIVE_KEY=0, OS=23
set /a TEX_OFFSET=-3000, A1=0, A2=0, YDELT=2, XP=%XMID%, YP=%YMID%, XDELT=2, YSCALE=!OS!, SCALE=0, AUTOROT=1, XPMAX=W-80
set /a TRANSP=1, BS=0, CSS=0
set BACKSKIP=& set CHECKSKIP=
set /a TYSCALE=100000&set XTRAFLAG=

call sindef.bat

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a TC=!TRANSP!-1
   echo "cmdgfx: fbox 8 0 20 & !CHECKSKIP! 3d objects\checkerbox\plane0.obj 0,-1 0,0,!A1! 0,0,0 45,35,45,0,0,0 0,0,0,10 !XMID!,!YMID!,700,%ASPECT% 0 -8 db & !BACKSKIP! 3d objects/sphere-tex.obj !DRAWMODE!,!TC!,!TEX_OFFSET!,0,10000,!TYSCALE! !RX!,!RY!,!RZ! 0,0,0 -!OS!,-!YSCALE!,-!OS!,0,-132,0 1,0,0,10 !XP!,!YP!,!DIST!,%ASPECT% 0 0 . & 3d objects/sphere-tex.obj !DRAWMODE!,!TC!,!TEX_OFFSET!,0,10000,!TYSCALE! !RX!,!RY!,!RZ! 0,0,0 !OS!,!YSCALE!,!OS!,0,-132,0 1,0,0,10 !XP!,!YP!,!DIST!,%ASPECT% 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 1" F!XTRAFLAG!fa:0,0,!W!,!H!
	set XTRAFLAG=
	
	set /a "DIST=!ORGDIST!+(%SINE(x):x=!A1!*31416/180%*80>>!SHR!), YP=90+YMID-(%SINE(x):x=!A2!*31416/180%*170>>!SHR!)"

	if !ROTMODE! == 0 (
		if !SCALE!==1 set /a "YSCALE=17+(%SINE(x):x=!A1!*31416/180%*7>>!SHR!)"
		if !AUTOROT!==1 !set /a "RX=50+(%SINE(x):x=!A1!*31416/180%*120>>!SHR!)"
	)

	set /a A1+=2, A2+=YDELT, XP+=XDELT
	if !A2! gtr 180 set /a YDELT=-YDELT
	if !A2! lss 0 set /a YDELT=-YDELT
	if !XP! gtr !XPMAX! set /a XDELT=-XDELT & if !XDELT! gtr 0 set /a XDELT=-XDELT 
	if !XP! lss 70 set /a XDELT=-XDELT
	
	set /a TEX_OFFSET+=35
	if !TEX_OFFSET! gtr 74000 set /a TEX_OFFSET = -3000
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a W=SCRW*2*4+7, H=SCRH*2*6+11, XMID=W/2, YMID=H/2, XPMAX=W-80 & cmdwiz showcursor 0
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set /a RX=0,RY=0,RZ=0
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 114 set /a AUTOROT=1-AUTOROT, RX=0
			if !KEY! == 115 set /a SCALE=1-SCALE, YSCALE=!OS!
			if !KEY! == 116 set BACKSKIP=& set /a BS=1-BS & if !BS!==1 set BACKSKIP=skip
			if !KEY! == 99 set CHECKSKIP=& set /a CSS=1-CSS & if !CSS!==1 set CHECKSKIP=skip
			if !KEY! == 27 set STOP=1
			if !KEY! == 32 set /a TRANSP=1-TRANSP
			if !KEY! == 109 set XTRAFLAG=D&set /a TYSCALE+=100000 & if !TYSCALE! gtr 1000000 set /a TYSCALE=100000 
			if !KEY! == 77 set XTRAFLAG=D&set /a TYSCALE-=100000 & if !TYSCALE! lss 100000 set /a TYSCALE=1000000 
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 331 set /a RY+=8
			if !ACTIVE_KEY! == 333 set /a RY-=8
			if !ACTIVE_KEY! == 328 set /a RX+=8
			if !ACTIVE_KEY! == 336 set /a RX-=8
		)
		if !ACTIVE_KEY! == 122 set /a RZ+=8
		if !ACTIVE_KEY! == 90 set /a RZ-=8
		if !ACTIVE_KEY! == 100 set /a ORGDIST+=100
		if !ACTIVE_KEY! == 68 set /a ORGDIST-=100
   )
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
echo "cmdgfx: quit"
title input:Q
