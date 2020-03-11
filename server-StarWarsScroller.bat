@echo off
set /a F6W=175/2, F6H=80/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Star Wars scroller (s/S m/M CursorKeys/z/Z Enter p)
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0unW10xR | call %0 %* | cmdgfx_gdi "" t4TSfa:0,0,700,480Z300 000000,202000,505000,c0c000
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
set /a DIST=480, ROTMODE=1, RX=180,RY=0,RZ=0, ACTIVE_KEY=0
set /a TEY_OFFSET=-35500, TEY_DELTA=30, TXSCALE=100000, ZVAL=300
set ASPECT=0.675
set SCOLS=f 0 . f 0 .  7 0 .  8 0   8 0   8 0
set /a BFADE=1
call :SETFADE

set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (

   echo "cmdgfx: fbox 0 0 fa & 3d objects\starfield200_0.ply 1,1 0,0,0 0,0,0 10,15,10,0,0,0 0,0,0,10 !XMID!,!YMID!,200,%ASPECT% %SCOLS% & 3d objects/plane-StarWars.obj 5,0,0,!TEY_OFFSET!,!TXSCALE!,40000 !RX!,!RY!,!RZ! 0,0,0 30,50,1,0,0,0 0,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 db & !FADE:~1,-1!" !XTRAFLAG!Z!ZVAL!FSfa:0,0,!W!,!H!
	set XTRAFLAG=
	
	if !ROTMODE! == 0 set /a "RX+=0,RY+=0,RZ+=2"

	set /a TEY_OFFSET+=!TEY_DELTA!
	if !TEY_OFFSET! gtr 65000 set /a TEY_OFFSET = -35000
	if !TEY_OFFSET! lss -38000 set /a TEY_OFFSET = 65000
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul ) 

	if "!RESIZED!"=="1" set /a W=SCRW*2*4+1, H=SCRH*2*6+1, XMID=W/2, YMID=H/2, BFADE=0 & cmdwiz showcursor 0
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!& set /a RX=180,RY=0,RZ=0
			if !KEY! == 109 set XTRAFLAG=D&set /a TXSCALE+=100000 & if !TXSCALE! gtr 600000 set /a TXSCALE=100000 
			if !KEY! == 77 set XTRAFLAG=D&set /a TXSCALE-=100000 & if !TXSCALE! lss 100000 set /a TXSCALE=600000 
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 102 set /a BFADE=1-!BFADE! & call :SETFADE
			if !KEY! == 114 set /a AUTOROT=1-AUTOROT
			if !KEY! == 115 set /a SCALE=1-SCALE, OSY=15
			if !KEY! == 115 set /a TEY_DELTA-=10
			if !KEY! == 83 set /a TEY_DELTA+=10
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)
	)
	if !ACTIVE_KEY! gtr 0 (
		if !ACTIVE_KEY! == 331 set /a RY+=4
		if !ACTIVE_KEY! == 333 set /a RY-=4
		if !ACTIVE_KEY! == 328 set /a RX+=4
		if !ACTIVE_KEY! == 336 set /a RX-=4
		if !ACTIVE_KEY! == 122 set /a RZ+=4
		if !ACTIVE_KEY! == 90 set /a RZ-=4
   )
	if !BFADE!==1 (
		set /a FOK=0
		if !RX!==180 if !RY!==0 if !RZ!==0 set /a FOK=1
		if !FOK!==0 set /a BFADE=0 & call :SETFADE
	)
	
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
echo "cmdgfx: quit"
title input:Q
goto :eof

:SETFADE
if %BFADE% == 1 set FADE="block 0 200,72,300,2 200,72 -1 0 0 e???=1???,6???=0??? & block 0 200,74,300,2 200,74 -1 0 0 e???=2???,6???=1??? & block 0 200,76,300,2 200,76 -1 0 0 e???=6???,6???=2??? & block 0 200,78,300,3 200,78 -1 0 0 e???=3???"
if %BFADE% == 0 set FADE=""
