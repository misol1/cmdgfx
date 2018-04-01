@echo off
goto STARTDEMO %1

:STATIC
setlocal ENABLEDELAYEDEXPANSION
start "" /B dlc.exe -p "tv-static-04.mp3">nul
set /a W=220, H=110
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==path set "%%v="

set /a W*=4, H*=6, RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2, DIST=500, RANDVAL=5
set ASPECT=1.199

set PAL=0 0 db 0 0 b1 

set /a OBJINDEX=1, NOFOBJECTS=2
set FNAME=eye.obj& set MOD=4.0,4.0,4.0, 0,-132,0 1

set t1=!time: =0!
set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	start "" /high /B cmdgfx_gdi "fbox 0 0 A 0,0,%W%,%H% & 3d objects\!FNAME! 0,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & block 0 0,0,%W%,%H% 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" fa:0,0,%W%,%H%

	cmdgfx "" knW24

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 5000 set STOP=1
	
	set KEY=!ERRORLEVEL!
	set /a RX+=2, RY+=6, RZ-=4
)
if not defined STOP goto REP

endlocal
taskkill.exe /F /IM dlc.exe>nul
goto :eof



:KALEIDO
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=110
set PATH=

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665
set /a FNT=0, SCALE=20

set /a S1=66, S2=12, S3=30
set FN=objects\tri.obj

set /a A1=155, A2=0, A3=0, A4=0, CNT=0
set /a TRANSP=0, TV=-1
set /a MONO=0 & set MONS=

set /a LIGHT=0, LTIME=1000, LA=0

set /a TDIST=1000, T_ON=0, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=5, TDISTADD=60, TARZ=8, TARX=0, TXMID=%XMID%, TXMA=0
set TNAME=alphMisol.obj
set /a TORUS_ON=0

set /a CS=0,CCNT=0,C0=8,C1=7,CDIV=10,CW=0 & set /a CEND=2*!CDIV! & set C2=f&set C3=f&set C4=f
set /a CCNT=%CEND%, CS=2
set /a STEP=0
set MONOCOL=fe

rem set /a MODE=2, T_ON=1
rem set /a TV=20

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2+=2, A3-=1, A4+=7, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t6.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,4000,%ASPECT% 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 410,410,410,0,0,0 1,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==4 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\hulk.obj %DRAWMODE%,-1 !A1!,!A2!,!A3! 0,0,0 210,210,210,0,-2,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db"
	if !MODE!==5 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==6 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"
	if !MODE!==7 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 35,35,!DIST!,%ASPECT% 1 0 db"
	if !MODE!==8 set OUTP="fbox 7 0 20 0,0,!W!,!H! & 3d objects\cube-t-checkers.obj 6,!TV!	!A1!,!A2!,!A3! 0,0,0 -281,-281,-281,0,0,0 1,0,0,10 150,150,!DIST!,!ASPECT! 0 -8 db 0 -2 db  0 0 db 0 0 db  0 -6 db 0 -5 db 0 -6 db 0 -2 db  0 -3 db 0 -1 db  0 -7 db 0 -4 db"

	for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d !FN! 1,-1 0,0,!TRZ! 0,0,0 !SCALE!,!SCALE!,!SCALE!,0,0,0 0,0,0,10 !XMID!,!YMID!,7000,!ASPECT! 0 0 db & 3d !FN! %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 !SCALE!,!SCALE!,!SCALE!,0,0,0 0,0,0,10 !XMID!,!YMID!,7000,!ASPECT! 0 0 db"&set /A TRZ+=%S3%*4
	
	set TTEXT=
	if !T_ON! == 1 (
		set /a TDIST+=!TDISTADD!
		set /a TXRZ+=!TARZ!,TXRX+=!TARX!,TXMID+=!TXMA!
		if !TXRZ! gtr 4320 if !TNAME!==alphMisol.obj set /a TXRZ=4320, TXRY+=8,TDIST-=!TDISTADD! 
		set TTEXT=3d objects\!TNAME! 5,!TCOLADD! !TXRX!,!TXRY!,!TXRZ! 0,0,0 3,3,3,0,0,0 0,0,0,10 !TXMID!,%YMID%,!TDIST!,%ASPECT% !TCOLADD! 0 db
	)
	
	set TORUS=
	if !TORUS_ON! == 1 (
		set TORUS=3d objects\torus.plg 1,0 !A4!,!CRZ!,!A2! 0,0,0 -1,-1,-1,0,0,0 0,0,0,0 %XMID%,%YMID%,1500,%ASPECT% f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db
	)
	
	start /B /High cmdgfx_gdi "!OUTP:~1,-1! & !MONS! & !FADE! & skip text a 0 0 _!a!_ 1,1 & !TTEXT! & !TORUS!" f!FNT!:0,0,!W!,!H!
	cmdgfx "" knW12
	set KEY=!ERRORLEVEL!
	if !KEY! == 112 cmdwiz getch

	set /a CRZ+=3, CNT+=1

	if !CS! gtr 0 (
		set /a CP=!CCNT!/!CDIV!,CCP=!CCNT!/!CDIV!+2 & for %%a in (!CP!) do for %%b in (!CCP!) do set FADE=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!C%%b!!C%%a!??
		if !CS!==2 set /a CCNT-=1&if !CCNT! lss 0 set /a CS=0&set FADE=
		if !CS!==1 set /a CCNT+=1&if !CCNT! gtr !CEND! set /a CCNT=!CEND!,CW+=1
		if !CW! gtr 10 set /a CW=0,CS=2, MODE+=1
	)
	
	if !LIGHT! == 1 for /F "tokens=1-8 delims=:.," %%a in ("!t2!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %LTIME% set /a KEY=109 & set t2=!time: =0!

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000"
 	if !STEP! == 0 if !a! geq 15000 set /a CS=1,TV=20,STEP+=1,CDIV=5 & set /a CEND=2*!CDIV! & set /a CCNT=0
	if !STEP! == 1 if !a! geq 30600 if !a! lss 31100 set MONS=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=c4??
	if !STEP! == 1 if !a! geq 31100 set /a LIGHT=1,STEP+=1,KEY=109 & set t2=!time: =0!
	if !STEP! == 2 if !a! geq 46000 call :PLASMA 2 & set /a STEP+=1,LIGHT=0&set MONS=
	if !STEP! == 3 if !a! geq 53800 call :PLASMA 5 & set /a STEP+=1,LIGHT=0&set MONS=
	if !STEP! == 4 if !a! geq 61000 set /a LIGHT=1,STEP+=1,KEY=109 & set t2=!time: =0!&set MONOCOL=01&set LA=1
	if !STEP! == 5 if !a! geq 70000 set /a LIGHT=0,STEP+=1,KEY=0&set MONS=
	if !STEP! == 6 if !a! geq 76800 call :PLASMA 3 & set /a STEP+=1
	if !STEP! == 7 if !a! geq 84500 call :MATRIX 1 0 & set /a STEP+=1
	if !STEP! == 8 if !a! geq 92000 call :PLAYSEQ seq 2542 2597 & set /a STEP+=1
	if !STEP! == 9 if !a! geq 92000 call :WAVE 3 10 4000 & set /a STEP+=1
	if !STEP! == 10 if !a! geq 92000 set /a MODE=2,T_ON=1,A1=155,A2=0,A3=0,CRZ=0,TV=-1 & set /a STEP+=1
	if !STEP! == 11 if !a! geq 138200 call :SIDECUBE & set /a MODE=3,STEP+=1,TV=-1, TDIST=1000, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=120, TARZ=8&set TNAME=alphCari.obj
	if !STEP! == 12 if !a! geq 146000 call :OBJSORTED 1 & set /a STEP+=1
	if !STEP! == 13 if !a! geq 146000 set /a MODE=1,TV=-1, TDIST=1000, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=90, TARZ=0 & set /a STEP+=1&set TNAME=alphLove.obj 
	if !STEP! == 14 if !a! geq 153000 call :PIXELOBJ 0 800 & set /a STEP+=1,LIGHT=0&set MONS=&set /a T_ON=0,TV=20,TORUS_ON=1
	if !STEP! == 15 if !a! geq 169000 call :WAVE 1 11 4000 & set /a STEP+=1,TORUS_ON=0
	if !STEP! == 16 if !a! geq 176600 call :PLASMA 6 & set /a STEP+=1
	if !STEP! == 17 if !a! geq 183800 call :PIXELOBJ 2 800 & set /a STEP+=1
	
	if !STEP! == 18 if !a! geq 190000 set /a T_ON=1, TDIST=1000, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=160, TARZ=3&set TNAME=alphBail.obj & set /a STEP+=1
	if !STEP! == 19 if !a! geq 200000 set /a T_ON=0 & set /a STEP+=1

	rem	if !STEP! == 13 if !a! geq 146000 set /a ASPECT=1,MODE=8,W=880,H=660,XMID=W/2,YMID=H/2,TV=-1,DIST=600,SCALE=90 & set /a STEP+=1 &set FNT=a&set FN=objects\tri2.obj
	
	rem if !KEY! == 32 echo !a! >> apanson 
	
	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 109 set /A MONO=1-!MONO!&(if !MONO!==1 if !LA! gtr 0 set MONOCOL=0!LA!&set /a LA+=1)&(if !MONO!==1 set MONS=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!MONOCOL!??)&(if !MONO!==0 set MONS=)
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
goto :eof



:PLAYSEQ
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set STOP=
set /a CNT=%2

:PLREP
for /L %%_ in (1,1,300) do if not defined STOP (

	cmdgfx_gdi "image %1\!CNT!.gxy 0 0 0 -1 10,13 0 0 126,60" W60kf1:0,0,147,83
	set KEY=!ERRORLEVEL!
	if !KEY! == 27 set STOP=1

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 27000 set /a STOP=1
	
	set /a CNT+=1
	if !CNT! gtr %3 set /a CNT=%2
)
if not defined STOP goto PLREP

endlocal
goto :eof



:SIDECUBE
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=1500, COLP=0, OBJ=1, CLEAR=1
set ASPECT=0.665

set FNAME=sidecube.obj
set FNAME2=sidecube2.obj
set PAL=f 0 db  f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db

rem set /a DIST=-600, OBJ=3
set /a OBJ=3, DIST=1000

:SCREP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a RX2+=3, RY2+=6, RZ2-=4	

	if !OBJ! == 0 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 1 0 b0 80,0,90,%H% & fbox 1 3 b0 0,48,79,41 & skip fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 4,-1 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 1 0 db 1 0 db  1 0 b1  1 0 b1  1 9 b1  1 9 b1 & 3d objects\icosahedron.ply 4,-1 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 b 3 b2  b 1 b1  9 3 b1  b 9 b1  b 0 db  9 0 b1  9 0 db  9 1 b1  1 0 db  1 0 b1  a 9 b0& 3d objects\tetrahedron.ply 4,-1 !RZ2!,!RX2!,0 0,0,0 -160,-160,-160,0,0,0 0,0,0,10 38,69,2600,0.6  b 3 db  f 7 b1  1 0 db  b 9 b1 &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 0 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 1 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 0 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 2 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 3 0 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLP! 0 db" Z300f0:0,0,%W%,%H%
	
	if !OBJ! == 3 start /B /HIGH cmdgfx_gdi "fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 1 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT%  4 0 db 4 0 db   1 0 db 1 0 db   2 0 db 2 0 db   3 0 db 3 0 db   5 0 db  5 0 db   0 0 db   0 0 db" Z300f0:0,0,%W%,%H%

	if !OBJ! == 4 start /B /HIGH cmdgfx_gdi "fbox 1 3 b1 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 3 b1 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b2 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6  %PAL% &  3d objects\!FNAME! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db &  !CLS! fbox 1 0 20 0,0,%W%,%H% &  3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 3 3 db" Z300f0:0,0,%W%,%H% 	000000,ffffff,ffff00,400000 000000,ffffff,ffffff,110000

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 3950 set /a STOP=1
	
	cmdgfx "" nW12k
	
	set KEY=!ERRORLEVEL!
	if !ROTMODE! == 0 set /a RX+=4, RY+=7, RZ-=5
	if !KEY! == 32 set /A OBJ+=1&if !OBJ! gtr 4 set /a OBJ=0
	if !KEY! == 99 set /A COLP=4-!COLP!
	if !KEY! == 98 set /A CLEAR=1-!CLEAR!&(if !CLEAR!==0 set CLS=skip)&(if !CLEAR!==1 set CLS=)
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 67 set /A DIST=-600
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto SCREP

endlocal
goto :eof



:PLASMA
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set /a W=220,H=110

set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

set /a MODE=%1, XMUL=300, YMUL=280, SHR=13, A1=155, A2=0, RANDPIX=20, COLCNT3=0, FADEIN=0, FADEVAL=0, WH=%W%/2
set ASPECT=0.58846
set HELP=
if !MODE! == 2 set /a RANDPIX=30

:PLLOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	if !RANDPIX! gtr 3 set /a RANDPIX-=1

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), RX+=7,RY+=12,RZ+=2, COLCNT3-=1, FADEIN+=!FADEVAL!/2, FADEVAL+=1

	if !MODE! == 0 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*(x/3)" f0:0,0,%W%,%H%
	if !MODE! == 1 set /a A1+=1, A2-=3 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/1)/160)*(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10) & !HELP! & 3d objects\hulk.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 110,55,1600,%ASPECT% 0 0 0  0 0 0  0 0 1 0 0 0" f0:0,0,%W%,%H% 
	if !MODE! == 2 set /a A1+=1, A2-=1 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/1.5)/160)*(cos(x/(y+30))*8)*sin((y+!COLCNT2!/5)/65)*(tan((y+x)/500)*10)" f0:0,0,%W%,%H%
	if !MODE! == 3 set /a A1+=1, A2-=1 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/2)/110)*(cos(x/(y+30))*8)*sin((y+!COLCNT2!/5)/65)*(sin((y+x)/100)*10)" f0:0,0,%W%,%H%
   if !MODE! == 4 set /a A1+=4, A2-=2 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/4)/110)*((x/19-y/6)*1)*sin((y+!COLCNT2!/5)/65)*((x-y)/10) & !HELP!& 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,%ASPECT% 0 6 ?" f0:0,0,%W%,%H%
   if !MODE! == 5 set /a A1+=2, A2+=1 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/10)/110)*88*sin((y+!COLCNT2!/5)/65)*98 & !HELP!& 3d objects\hulk.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 130,51,1600,%ASPECT% 0 9 0  0 9 0  0 9 1 0 9 0" f0:0,0,%W%,%H%
	if !MODE! == 6 set /a A1+=1, A2-=1 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/2)/60)*(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10)" f0:0,0,%W%,%H%
	if !MODE! == 7 set /a A1+=1, A2-=3 & start "" /high /B cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin(tan((x+!COLCNT!/1)/60)/(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10))*15 & !HELP! & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 170,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,1200,%ASPECT% 0 0 db & 3d objects\plane-block2.obj 5,-1 !RZ!,!RX!,75 -40,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,600,%ASPECT% 0 0 db" f0:0,0,%W%,%H%

	cmdgfx "" nW12
	set KEY=!errorlevel!

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
		
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 7 set MODE=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 104 set HELP=
	if !KEY! == 328 set /a RANDPIX+=1
	if !KEY! == 336 set /a RANDPIX-=1 & if !RANDPIX! lss 0 set RANDPIX=0
	if !KEY! == 13 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto PLLOOP

endlocal
goto :eof


:MATRIX
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set W=55&set /a WW=!W!*2
cls
cmdwiz setbuffersize %WW% 160
set CNT=0&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set HX!CNT!=%%a&set /a CNT+=1

set COL=%2&set P0=0123456789a&set P1=0133456789b&set P2=0143456789c&set P3=0153456789d&set P4=0163456789e
cmdgfx "fbox a 0 00 0,0,%WW%,160" f7
set STREAM="??00=??00,??40=2?41,??41=a000,??80=2?81,??81=a000,??c0=2?c1,??c1=a?00,????=??++"
set STREAM2="??00=??00,"
for /L %%a in (0,1,192) do set /a "RAND=!RANDOM! %% 200"&set /a "CH1=!RAND! / 16,CH2=!RAND! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set STREAM2="!STREAM2:~1,-1!??!HX%%e!!HX%%f!=??31,"
set STREAM2="%STREAM2:~1,-1%????=??30"

:MLOOP
for /L %%_ in (1,1,300) do if not defined STOP for %%c in (!COL!) do (
	set OUT=""
	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 8,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel a 0 !C1!!C2! !X!,0&pixel a 0 !C1!!C3! !X!,1&pixel f 0 !C1!!C2! !X!,2&"
	for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel a 0 00 !X!,0&pixel a 0 00 !X!,1&"

	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 8,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel 2 0 !C1!!C2! !X!,80"
	for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,80&"

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
	
	if %1 == 1 cmdgfx "!OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 -1 0 0 %STREAM2:~1,-1%& block 0 %W%,2,%W%,75 0,0 00 0 0 %STREAM2:~1,-1%" pkW16 !P%%c!
	
	if %1 == 2 cmdgfx "!OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 & block 0 %W%,2,%W%,75 0,0 00" pkW16 !P%%c!
	
	set KEY=!errorlevel!
	if !KEY! == 32 set /A COL+=1&if !COL! gtr 4 set COL=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto MLOOP

cmdwiz setbuffersize 55 55 & cls
endlocal
goto :eof


:PIXELOBJ
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set /a W=147, H=83

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.75
set COLS0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 .  8 0 fa
set /a COLCNT=0, OBJCNT=%1
set HELP=
set OBJ0=torus&set OBJ1=sphere&set OBJ2=double-sphere

set STOP=
:PIXLOOP
for /L %%_ in (1,1,300) do if not defined STOP for %%o in (!OBJCNT!) do (
	start "" /B /high cmdgfx_gdi "fbox 7 0 20 0,0,%W%,%H% & 3d objects\plot-!OBJ%%o!.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 1.2,1.2,1.2,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% %COLS0% & %HELP% " f1:0,0,%W%,%H%
	cmdgfx "" nkW12
	set KEY=!ERRORLEVEL!

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %2 set /a STOP=1
	
	set /A CRZ+=5,CRX+=3,CRY-=4
	if !KEY! == 32 set /A OBJCNT+=1&if !OBJCNT! gtr 2 set OBJCNT=0
)
if not defined STOP goto PIXLOOP

endlocal
goto :eof


:WAVE
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set FNT=1

set /a W=147, H=83

set /a XC=0, YC=0, XCP=9, YCP=11, MODE=%1
set /a BXA=37, BYA=22

set /a BGCOL=0, IC=%2, CC=15

set /a CNT=0 & for %%a in (myface.txt evild.txt ugly0.pcx mario1.gxy emma.txt glass.txt fract.txt checkers.gxy mm.txt wall.pcx apa.gxy ful.gxy) do set I!CNT!=%%a & set /a CNT+=1

:WAVEREP
for /L %%_ in (1,1,300) do if not defined STOP for %%i in (!IC!) do for %%c in (!CC!) do (

  set BKG="fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & image img\!I%%i! %%c 0 0 e 180,0 0 0 198,105"

  if !MODE!==0 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/100+x/!BXA!+y/!BYA!)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==1 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+205+sin(!XC!/100+x/!BYA!+y/!BXA!)*10 10+y+cos(!YC!/100+x/!BXA!+y/!BYA!)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==2 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BYA!+y/!BXA!)*10 10+y+sin(!YC!/150+x/200+y/!BXA!+y/!BYA!)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==3 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/300+y/60+x/!BYA!+x/!BXA!)*10 10+y+sin(!YC!/150+x/50+y/!BXA!+y/!BYA!)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==4 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BXA!*0.4+y/!BYA!*0.4)*10 10+y+cos(!YC!/100+x/!BXA!*0.4+y/!BYA!*0.4)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==5 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BXA!*3+y/!BYA!*2)*6 10+y+cos(!YC!/100+x/!BXA!*2+y/!BYA!*2)*4 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==6 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+tan(!YC!/100+x/!BXA!*40+y/!BYA!*40)*1 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==7 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/100+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/40+x/!BXA!*5+y/!BYA!*8)*tan(!YC!/700+x/!BXA!*0.3+y/!BYA!*0.3)*2 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==8 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? x+215+sin(!XC!/90+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/20+x/5+y/4)*tan(!YC!/1700+cos(!XC!/600)*x/90+sin(!YC!/700)*y/70)+sin(!XC!/400-!YC!/220)*8 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  if !MODE!==9 start /B /HIGH cmdgfx_gdi "!BKG:~1,-1! & block 0 0,0,380,105 0,0 -1 0 0 ? ? y+x/20+170+sin(!XC!/300+x/!BXA!+y/!BYA!)*10 10+y+cos(!YC!/225+x/!BXA!+y/!BYA!)*10 from 0,0,147,83" f%FNT%:0,0,380,105,147,83
  
  	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %3 set /a STOP=1

  cmdgfx_gdi "" knW12
  set /a KEY=!errorlevel!
  if !KEY! == 13 set /a MODE+=1&if !MODE! gtr 9 set /a MODE=0
  if !KEY! == 32 set /a IC+=1&if !IC! geq %CNT% set /a IC=0
  if !KEY! == 99 set /a CC+=1&if !CC! gtr 15 set /a CC=1
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!
)
if not defined STOP goto WAVEREP

endlocal
goto :eof


:OBJSORTED
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a W=147, H=83
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=1, NOF=6, DIST=2500, MODE=%1
set ASPECT=0.75

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

set /A XP1=0,YP1=0,ZP1=-250
set /A XP2=0,YP2=0,ZP2=250
set /A XP3=250,YP3=0,ZP3=0
set /A XP4=-250,YP4=0,ZP4=0
set /A XP5=0,YP5=-250,ZP5=0
set /A XP6=0,YP6=250,ZP6=0

set /a XRA1=5, YRA1=8, XRA2=1,YRA2=-7, XRA3=-5,YRA3=5, XRA4=-10,YRA4=-4, XRA5=3,YRA5=-12, XRA6=5,YRA6=9
set /A XROT=0,YROT=0,ZROT=0, XMUL=14000, SHR=13

set COL1=f b b2  b 0 db  b 7 b2  b 7 b1  7 0 db  9 7 b1  9 7 b2  9 0 db  9 1 b1 9 1 b0 1 0 db  1 0 b2  1 0 b1  1 0 b0  1 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL2=f a db  f a b1  f a b0  a 7 b0  a 7 b1  a 7 b2  a 0 db  a 0 db  a 2 b1 a 2 b0 2 0 db  2 0 b2  2 0 b1  2 0 b0  2 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL3=f c db  f c b1  f c b0  c 7 b0  c 7 b1  c 7 b2  c 0 db  c 0 db  c 4 b1 c 4 b0 4 0 db  4 0 b2  4 0 b1  4 0 b0  4 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL4=f d db  f d b1  f d b0  d 7 b0  d 7 b1  d 7 b2  d 0 db  d 0 db  d 5 b1 d 5 b0 5 0 db  5 0 b2  5 0 b1  5 0 b0  5 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL5=f e db  f e b1  f e b0  e 7 b0  e 7 b1  e 7 b2  e 0 db  e 0 db  e 6 b1 e 6 b0 6 0 db  6 0 b2  6 0 b1  6 0 b0  6 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db
set COL6=f b db  f 7 b1  f 7 b1  f 8 b1  7 0 db  7 8 b1  7 8 b2  7 0 db  7 8 b2 7 8 b0 8 0 db  8 0 b2  8 0 b1  8 0 b0  8 0 b0  0 0 db  0 0 db  0 0 db 0 0 db 0 0 db 0 0 db 0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db  0 0 db

set STOP=
:OSLOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""

	set /a "srx=(%SINE(x):x=!XROT!*31416/180%*!XMUL!>>!SHR!),XRC=!XROT!+90"
	set /a "crx=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	set /a "sry=(%SINE(x):x=!YROT!*31416/180%*!XMUL!>>!SHR!),XRC=!YROT!+90"
	set /a "cry=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)

	set /a "srz=(%SINE(x):x=!ZROT!*31416/180%*!XMUL!>>!SHR!),XRC=!ZROT!+90"
	set /a "crz=(%SINE(x):x=!XRC!*31416/180%*!XMUL!>>!SHR!)
	
	for /L %%a in (1,1,!NOF!) do set /A "YPP=((!crx!*!YP%%a!)>>14)+((!srx!*!ZP%%a!)>>14),ZPP=((!crx!*!ZP%%a!)>>14)-((!srx!*!YP%%a!)>>14)" & set /A "XPP=((!cry!*!XP%%a!)>>14)+((!sry!*!ZPP!)>>14),ZPP2%%a=((!cry!*!ZPP!)>>14)-((!sry!*!XP%%a!)>>14)" & set /A "XPP2%%a=((!crz!*!XPP!)>>14)+((!srz!*!YPP!)>>14),YPP2%%a=((!crz!*!YPP!)>>14)-((!srz!*!XPP!)>>14), ZPP2%%a*=4"

	if !MODE! == 0 for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set /a XR%%c+=!XRA%%c!,YR%%c+=!YRA%%c!&set CRSTR="!CRSTR:~1,-1!&3d objects\icosahedron.ply !DRAWMODE!,1 !XR%%c!,!YR%%c!,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! -131,-131,-131,0,0,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	if !MODE! == 1 for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set /a XR%%c+=!XRA%%c!,YR%%c+=!YRA%%c!&set CRSTR="!CRSTR:~1,-1!&3d objects\elephav.obj !DRAWMODE!,1 !XR%%c!,!YR%%c!,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 0.3,0.3,0.3,0,-360,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	 for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1

	start "" /B /High cmdgfx_gdi.exe "fbox 1 0 20 0,0,200,100 & !CRSTR:~1,-1!" f1:0,0,%W%,%H%
	cmdgfx.exe "" nkW15
	set KEY=!ERRORLEVEL!

	set /a XROT-=3, YROT+=2, ZROT+=1

	if !KEY! == 331 set /A NOF-=1&if !NOF! lss 2 set NOF=2
	if !KEY! == 333 set /A NOF+=1&if !NOF! gtr 6 set NOF=6
	if !KEY! == 32 set /a MODE=1-!MODE!
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto OSLOOP

endlocal
goto :eof


:CENTERWINDOW
cmdwiz getdisplaydim w
set SW=%errorlevel%
cmdwiz getdisplaydim h
set SH=%errorlevel%
cmdwiz getwindowbounds w
set WINW=%errorlevel%
cmdwiz getwindowbounds h
set WINH=%errorlevel%
set /a WPX=%SW%/2-%WINW%/2,WPY=%SH%/2-%WINH%/2
if not "%1"=="" set /a WPX+=%1
if not "%2"=="" set /a WPY+=%2
cmdwiz setwindowpos %WPX% %WPY%
goto :eof

:STARTDEMO
setlocal ENABLEDELAYEDEXPANSION
set /a W=55, H=55
cls & cmdwiz setfont 7 & cmdwiz showcursor 0
mode %W%,%H%
call :CENTERWINDOW 0 -20
cmdgfx_gdi "" f7
taskkill.exe /F /IM dlc.exe>nul 2>nul
start "" /B dlc.exe -p "silence-1sec.mp3">nul
cmdwiz print "Cari Lekebusch_ - Obscurus Sanctus.mp3\ntv-static-04.mp3\nobjects\Hulk.obj\nobjects\elephav.obj\nimg\\ful.gxy\nimg\\apa.gxy\ncmdgfx.exe\ndlc.exe">cachelist.dat
cmdwiz cache cachelist.dat

if "%~1" == "" call :STATIC

start "" /B dlc.exe -p "Cari Lekebusch_ - Obscurus Sanctus.mp3">nul
cmdgfx_gdi "" f7w150
cmdgfx_gdi "" f7w500

for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==path set "%%v="
set t1=!time: =0!

call :KALEIDO
endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
taskkill.exe /F /IM dlc.exe>nul
del /Q EL.dat cachelist.dat CGXMS.dat >nul 2>nul
