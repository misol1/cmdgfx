@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 0 & cls
set /a W=180, H=90
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=1500, COLP=0, OBJ=1, CLEAR=1
set CLS=
set ASPECT=0.665

set FNAME=sidecube.obj
set FNAME2=sidecube2.obj
set PAL=f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a RX2+=3, RY2+=6, RZ2-=4	

	if !OBJ! == 0 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 1 0 b0 80,0,90,%H% & fbox 1 3 b0 0,48,79,41 & skip fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 4,-1 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 1 0 db 1 0 db  1 0 b1  1 0 b1  1 9 b1  1 9 b1 & 3d objects\icosahedron.ply 4,-1 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 b 3 b2  b 1 b1  9 3 b1  b 9 b1  b 0 db  9 0 b1  9 0 db  9 1 b1  1 0 db  1 0 b1  a 9 b0& 3d objects\tetrahedron.ply 4,-1 !RZ2!,!RX2!,0 0,0,0 -160,-160,-160,0,0,0 0,0,0,10 38,69,2600,0.6  b 3 db  f 7 b1  1 0 db  b 9 b1 &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 0 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 1 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 0 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 2 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 3 0 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 3 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 1 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT%  4 0 db 4 0 db   1 0 db 1 0 db   2 0 db 2 0 db   3 0 db 3 0 db   5 0 db  5 0 db   0 0 db   0 0 db" Z300f0:0,0,%W%,%H%

	if !OBJ! == 4 start /B /HIGH cmdgfx_gdi "fbox 1 3 b1 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 3 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b2 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 3 3 db" Z300f0:0,0,%W%,%H% 	000000,ffffff,ffff00,400000 000000,ffffff,ffffff,110000
	
	cmdgfx "" nW10k
	
	set KEY=!ERRORLEVEL!
	if !ROTMODE! == 0 set /a RX+=3, RY+=6, RZ-=4
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!, RX=0,RY=0,RZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
	if !KEY! == 32 set /A OBJ+=1&if !OBJ! gtr 4 set /a OBJ=0
	if !KEY! == 99 set /A COLP=4-!COLP!
	if !KEY! == 98 set /A CLEAR=1-!CLEAR!&(if !CLEAR!==0 set CLS=skip)&(if !CLEAR!==1 set CLS=)
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 67 set /A DIST=-600
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
