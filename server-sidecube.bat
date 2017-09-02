@echo off
bg font 6
set /a F6W=180/2, F6H=90/2
mode %F6W%,%F6H% & cls
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe m0nuW9x | call %0 %* | cmdgfx_gdi "" Sf0:0,0,180,90
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=180, H=90
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -18

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=1500, COLP=0, OBJ=2, CLEAR=1
set CLS=
set ASPECT=0.665

set FNAME=sidecube.obj
set FNAME2=sidecube2.obj
set PAL=f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db
set PAL2=f 0 db  f e b2  e 0 db  f 7 b2  f 7 b1  7 f b2  a 7 b1  a 7 b2  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db
set PAL3=f 0 db  f e b2  e 0 db  7 7 b2  7 7 b1  7 7 b2  a 7 b1  a 7 b2  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db

set STREAM="01??=00db,11??=60b1,21??=60db,31??=e6b1,41??=e6db,51??=e6db,61??=efb1,71??=feb1,81??=fedb,91??=feb1,a1??=efb1,b1??=e6db,c1??=e6b1,d1??=60db,e1??=60b1,f1??=00db,08??=00db,18??=20b1,28??=20db,38??=a2b1,48??=a2db,58??=a2db,68??=afb1,78??=afb1,88??=fadb,98??=fadb,a8??=afb1,b8??=a2db,c8??=a2b1,d8??=20db,e8??=20b1,f8??=00db,05??=00db,15??=40b1,25??=40db,35??=c4b1,45??=c4db,55??=c4db,65??=c7b1,75??=7cdb,85??=7fb1,95??=7cdb,a5??=c7b1,b5??=c4db,c5??=c4b1,d5??=40db,e5??=40b1,f5??=00db,0???=00db,1???=10b1,2???=10db,3???=91b1,4???=91db,5???=9bb2,6???=9bb1,7???=b9db,8???=bfb1,9???=9bb0,a???=9bb2,b???=91db,c???=91b1,d???=10db,e???=10b1,f???=00db"

set HELPMSG=text 3 0 0 SPACE\-D/d\-b\-c\-ENTER\-\g1e\g1f\g11\g10\-h 2,88
set MSG=%HELPMSG%
set /a SHOWHELP=1

set /a ACTIVE_KEY=0

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a RX2+=3, RY2+=6, RZ2-=4, COLCNT+=1,COLCNT2+=3

	set RGBPAL=- -
	
	if !OBJ! == 0 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 1 0 b0 80,0,90,%H% & fbox 1 3 b0 0,48,79,41 & skip fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 4,-1 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 1 0 db 1 0 db  1 0 b1  1 0 b1  1 9 b1  1 9 b1 & 3d objects\icosahedron.ply 4,-1 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 b 3 b2  b 1 b1  9 3 b1  b 9 b1  b 0 db  9 0 b1  9 0 db  9 1 b1  1 0 db  1 0 b1  a 9 b0& 3d objects\tetrahedron.ply 4,-1 !RZ2!,!RX2!,0 0,0,0 -160,-160,-160,0,0,0 0,0,0,10 38,69,2600,0.6  b 3 db  f 7 b1  1 0 db  b 9 b1 &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db"
	
	if !OBJ! == 1 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 0 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db"
	
	if !OBJ! == 2 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 3 0 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db"
	
	if !OBJ! == 3 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 1 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT%  4 0 db 4 0 db   1 0 db 1 0 db   2 0 db 2 0 db   3 0 db 3 0 db   5 0 db  5 0 db   0 0 db   0 0 db"

	if !OBJ! == 4 set RGBPAL=000000,ffffff,ffff00,400000 000000,ffffff,ffffff,110000 & set OUT="fbox 1 3 b1 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 3 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b2 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 3 3 db"

	if !OBJ! == 5 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 3 8 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -180,-180,-180,0,0,0 1,0,0,10 35,70,4000,0.665 %PAL2% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & block 0 0,0,69,48 0,0 -1 0 0 %STREAM:~1,-1% sin((x-!COLCNT!/3)/40)*y+cos((y+!COLCNT2!/4)/15)*(x/3)  &  3d objects\!FNAME! 3,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 db & "

	if !OBJ! == 6 set OUT="fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 0 8 20 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -180,-180,-180,0,0,0 1,0,0,10 35,70,4000,0.665 %PAL3% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & block 0 0,0,69,48 0,0 -1 0 0 %STREAM:~1,-1% sin((x-!COLCNT!/3)/40)*y+cos((y+!COLCNT2!/4)/15)*(x/3)  &  3d objects\!FNAME! 3,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 4 0 db 4 0 db   0 0 db 0 0 db   0 0 db 0 0 db   0 0 db 0 0 db   4 0 db  4 0 db   0 0 db   0 0 db & "
		
	echo "cmdgfx: !OUT:~1,-1! & !MSG!" FZ300f0:0,0,%W%,%H% !RGBPAL!
	
	if !ROTMODE! == 0 set /a RX+=3, RY+=6, RZ-=4
		
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	if !K_EVENT! == 1 (
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336 122 90 100 68) do if !KEY! == %%a set /a ACTIVE_KEY=!KEY!
			if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!, RX=0,RY=0,RZ=0
			if !KEY! == 32 set /A OBJ+=1&if !OBJ! gtr 6 set /a OBJ=0
			if !KEY! == 98 set /A CLEAR=1-!CLEAR!&(if !CLEAR!==0 set CLS=skip)&(if !CLEAR!==1 set CLS=)
			if !KEY! == 99 set /a TMPV=!DIST!,DIST=-600 & if !TMPV!==-600 set /a DIST=1500
			if !KEY! == 112 cmdwiz getch
			if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			set /a ACTIVE_KEY=0
		)	
	)
	if !ACTIVE_KEY! == 331 if !ROTMODE!==1 set /a RY+=6
	if !ACTIVE_KEY! == 333 if !ROTMODE!==1 set /a RY-=6
	if !ACTIVE_KEY! == 328 if !ROTMODE!==1 set /a RX+=6
	if !ACTIVE_KEY! == 336 if !ROTMODE!==1 set /a RX-=6
	if !ACTIVE_KEY! == 122 if !ROTMODE!==1 set /a RZ+=6
	if !ACTIVE_KEY! == 90 if !ROTMODE!==1 set /a RZ-=6
	if !ACTIVE_KEY! == 100 set /a DIST+=20
	if !ACTIVE_KEY! == 68 set /a DIST-=20
	
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
