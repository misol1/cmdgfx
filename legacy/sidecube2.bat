@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls
set /a W=180, H=90
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=1500, CLEAR=1, OBJ=0
set ASPECT=0.665
set CLS=

set FNAME=sidecube.obj
set PAL=f 0 db f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db
set PAL2=f 0 db  f e b2  e 0 db  f 7 b2  f 7 b1  7 f b2  a 7 b1  a 7 b2  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db
set PAL3=f 0 db  f e b2  e 0 db  7 7 b2  7 7 b1  7 7 b2  a 7 b1  a 7 b2  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db

set STREAM="01??=00db,11??=60b1,21??=60db,31??=e6b1,41??=e6db,51??=e6db,61??=efb1,71??=feb1,81??=fedb,91??=feb1,a1??=efb1,b1??=e6db,c1??=e6b1,d1??=60db,e1??=60b1,f1??=00db,08??=00db,18??=20b1,28??=20db,38??=a2b1,48??=a2db,58??=a2db,68??=afb1,78??=afb1,88??=fadb,98??=fadb,a8??=afb1,b8??=a2db,c8??=a2b1,d8??=20db,e8??=20b1,f8??=00db,05??=00db,15??=40b1,25??=40db,35??=c4b1,45??=c4db,55??=c4db,65??=c7b1,75??=7cdb,85??=7fb1,95??=7cdb,a5??=c7b1,b5??=c4db,c5??=c4b1,d5??=40db,e5??=40b1,f5??=00db,0???=00db,1???=10b1,2???=10db,3???=91b1,4???=91db,5???=9bb2,6???=9bb1,7???=b9db,8???=bfb1,9???=9bb0,a???=9bb2,b???=91db,c???=91b1,d???=10db,e???=10b1,f???=00db"

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a RX2+=3, RY2+=6, RZ2-=4, COLCNT+=1,COLCNT2+=3
	
	if !OBJ! == 0 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 3 8 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -180,-180,-180,0,0,0 1,0,0,10 35,70,4000,0.665 %PAL2% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & block 0 0,0,69,48 0,0 -1 0 0 %STREAM% sin((x-!COLCNT!/3)/40)*y+cos((y+!COLCNT2!/4)/15)*(x/3)  &  3d objects\!FNAME! 3,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 db & " Z300f0:0,0,%W%,%H%

	if !OBJ! == 1 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 0 8 20 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -180,-180,-180,0,0,0 1,0,0,10 35,70,4000,0.665 %PAL3% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & block 0 0,0,69,48 0,0 -1 0 0 %STREAM% sin((x-!COLCNT!/3)/40)*y+cos((y+!COLCNT2!/4)/15)*(x/3)  &  3d objects\!FNAME! 3,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 . 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 4 0 db 4 0 db   0 0 db 0 0 db   0 0 db 0 0 db   0 0 db 0 0 db   4 0 db  4 0 db   0 0 db   0 0 db & " Z300f0:0,0,%W%,%H%
	
	
	cmdgfx "" nW12k
	
	set KEY=!ERRORLEVEL!
	if !ROTMODE! == 0 set /a RX+=3, RY+=6, RZ-=4
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!, RX=0,RY=0,RZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
	if !KEY! == 32 set /A OBJ+=1&if !OBJ! gtr 1 set /a OBJ=0
	if !KEY! == 98 set /A CLEAR=1-!CLEAR!&(if !CLEAR!==0 set CLS=skip)&(if !CLEAR!==1 set CLS=)
	if !KEY! == 67 set /A DIST=-800
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
bg font 6 & mode 80,50 & cls
