@echo off
set /a W=220, H=100
set /a F6W=W/2, F6H=H/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title 3d test pixel palette (n/N Space w d/D b Enter+CursorKeys/z/Z)
set /a W*=4, H*=6
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW10x | call %0 %* | cmdgfx_gdi "" eSfa:0,0,%W%,%H% 000000,ffffff,f7f7ff,eeeeff,e7e7ff,ddddff,d7d7ff,ccccff,c7c7ff,bbbbff,aaaaff,9999ff,8888ff,7777ff,5555ff,3333dd 000000,2222cc,1111bb,1111aa,111199,000088,000077,000066,000055,000044,000033,000022,000011,000011,000011,000011,000011,000011
set __=
set W=&set H=&set F6W=&set F6H=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -16

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=800, DRAWMODE=2, ROTMODE=0, SHOWHELP=0
set ASPECT=1

set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
set PAL1=1 b b2  2 b b2  3 b b1  4 b b0  5 0 db  6 7 b2  7 7 b1  8 0 db  9 7 b1  a 7 b2  b 0 db  c 1 b1 d 1 b0 e 0 db  f 0 b2  0 1 20 0 2 20 0 3 20 0 5 20 0 6 20 0 7 20 0 8 20 0 9 20 0 a 20 0 b 20 0 c 20 0 d 20 0 e 20 0 f 20
set PAL2=1 b b2  2 b b2  3 b b1  4 b b0  5 0 db  6 7 b2  7 7 b1  8 0 db  9 7 b1  a 7 b2  b 0 db  c 1 b1 d 1 b0 e 0 db  f 0 b2  0 1 20 0 2 20 0 3 20 0 5 20 0 6 20 0 7 20 0 8 20 0 9 20 0 a 20 0 b 20 0 c 20 0 d 20 0 e 20 0 f 20
set PAL3=b 0 db
set /A O0=-1,O1=0,O2=1,O3=-1,O1T=0
set PAL=!PAL%DRAWMODE%!
set HELPMSG=text b 0 0 n/N=object,_SPACE=mode,_RETURN=auto/manual(cursor,z/Z),_d/D=distance,_h=help 80,98
if !SHOWHELP!==1 set MSG=%HELPMSG%

set OBJINDEX=18
set NOFOBJECTS=22
call :SETOBJECT
set /a ACTIVE_KEY=0
set /a WIREMODE=0
if !WIREMODE!==0 set WIRE=skip

::echo "cmdgfx: " - 000000,ffffff,f7f7ff,eeeeff,e7e7ff,ddddff,d7d7ff,ccccff,c7c7ff,bbbbff,aaaaff,9999ff,8888ff,7777ff,5555ff,3333dd  000000,2222cc,2811bb,3011aa,401199,480088,400077,320066,280055,200044,180033,080022,000011,000011,000011,000011,000011,000011

set STOP=
:REP
for /L %%1 in (1,1,400) do if not defined STOP for %%o in (!DRAWMODE!) do (
	set /a WCOL=0&if !DRAWMODE!==3 if !WIREMODE!==1 set WCOL=b
	
	echo "cmdgfx: fbox 8 0 20 0,0,%W%,%H% & !MSG! & 3d objects\!FNAME! !DRAWMODE!,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !PAL! & !WIRE! 3d objects\!FNAME! 3,!O%%o! !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% !WCOL! 0 db" F
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	if !ROTMODE! == 0 set /a RX+=2, RY+=6, RZ-=4, XMID=%W%/2, YMID=%H%/2
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68 329 337 327 335) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 32 set /A DRAWMODE+=1&(if !DRAWMODE! gtr 3 set DRAWMODE=0)&for %%a in (!DRAWMODE!) do set PAL=!PAL%%a!
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
			if !KEY! == 111 set /A O1T=1-!O1T!,O2=1-!O2!&set O1=!O0!!O1T!
			if !KEY! == 98 set /A O0+=1&(if !O0! gtr 6 set O0=0)&set O1=!O0!!O1T!
			if !KEY! == 110 set /A OBJINDEX+=1&(if !OBJINDEX! geq %NOFOBJECTS% set /A OBJINDEX=0)&call :SETOBJECT
			if !KEY! == 78 set /A OBJINDEX-=1&(if !OBJINDEX! lss 0 set /A OBJINDEX=%NOFOBJECTS%-1)&call :SETOBJECT
			if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 119 set /A WIREMODE=1-!WIREMODE!&(if !WIREMODE!==0 set WIRE=skip)&(if !WIREMODE!==1 set WIRE=)
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)	
	)
	if !ACTIVE_KEY! gtr 0 (
		if !ROTMODE!==1 (
			if !ACTIVE_KEY! == 327 set /a XMID-=1
			if !ACTIVE_KEY! == 335 set /a XMID+=1
			if !ACTIVE_KEY! == 337 set /a YMID+=1
			if !ACTIVE_KEY! == 329 set /a YMID-=1
			if !ACTIVE_KEY! == 331 set /a RY+=8
			if !ACTIVE_KEY! == 333 set /a RY-=8
			if !ACTIVE_KEY! == 328 set /a RX+=8
			if !ACTIVE_KEY! == 336 set /a RX-=8
			if !ACTIVE_KEY! == 122 set /a RZ+=8
			if !ACTIVE_KEY! == 90 set /a RZ-=8
		)
		if !ACTIVE_KEY! == 100 set /a DIST+=20
		if !ACTIVE_KEY! == 68 set /a DIST-=20
   )
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q

goto :eof

:SETOBJECT
set ERR=
set PAL0=f 0 db  f b b1  b 0 db  b 7 b1  7 0 db  9 7 b1  9 0 db  9 1 b1  1 0 db  1 0 b1
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
if %OBJINDEX% == 18 set FNAME=fracttree.ply& set MOD=104,104,104, 0,0,0 1
if %OBJINDEX% == 19 set FNAME=hulk.obj& set MOD=240,240,240, 0,-2,0 1& set PAL0=0 0 db 0 0 b1
if %OBJINDEX% == 20 set FNAME=al.obj& set MOD=150,150,150, 0,0,0 0
if %OBJINDEX% == 21 set FNAME=eye.obj& set MOD=2.5,2.5,2.5, 0,-132,0 1& set PAL0=0 0 db 0 0 b1
for %%a in (!DRAWMODE!) do set PAL=!PAL%%a!
