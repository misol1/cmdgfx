@echo off
if defined __ goto :STARTDEMO %1
set __=.

cls & cmdwiz setfont 6
mode 80,50 & (if "%~2"=="M" cmdwiz showwindow maximize) & (if not "%~2"=="M" cmdwiz fullscreen 1) & cmdwiz setmousecursorpos 10000 100 & cmdwiz showmousecursor 0
cmdwiz getconsoledim sw
set /a W6=%errorlevel% + 1
cmdwiz getconsoledim sh
set /a H6=%errorlevel% + 3

if "%~2"=="M" goto :SIZEDONE
cmdwiz getdisplaydim w
set /a W6=%errorlevel%/8+1
cmdwiz getdisplaydim h
set /a H6=%errorlevel%/12+1

:SIZEDONE
if "%~2"=="U" set /a REALFS=1 & set TOP=U
set /a W=W6*2, H=H6*2
cls & cmdwiz showcursor 0

call %0 %* | cmdgfx_gdi "" ekOSf0:0,0,%W%,%H%W12%TOP%
set __=
cls
(if not "%~2"=="M" cmdwiz fullscreen 0) & cmdwiz showmousecursor 1 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof


:STATIC
setlocal ENABLEDELAYEDEXPANSION
start "" /B dlc.exe -p "tv-static-04.mp3">nul
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==path set "%%v="

set /a RX=2*53, RY=6*53, RZ=-4*53

set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=0, DIST=500,RANDVAL=3
set ASPECT=1.19948

set PAL=0 0 fe 0 0 b1 0 0 fe 0 0 b0

set /a OBJINDEX=1, NOFOBJECTS=2
set FNAME=eye.obj& set MOD=4.0,4.0,4.0, 0,-132,0 1

set t1=!time: =0!
set STOP=
:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 A 0,0,%W%,%H% & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & 3d objects\!FNAME! 3,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,-4000,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL! & block 0 0,0,%W%,%H% 0,0 -1 0 0 ? random()*!RANDVAL!+fgcol(y,y)" f0:0,0,%W%,%H%W30 000000,555555

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	if !KEY! == 27 set STOP=1
	
	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 5000 set STOP=1
	
	set /a RX+=2, RY+=6, RZ-=4
)
if not defined STOP goto REP

endlocal
taskkill.exe /F /IM dlc.exe>nul
goto :eof



:KALEIDO
setlocal ENABLEDELAYEDEXPANSION
set PATH=

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0, MODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.6665
set /a FNT=0, SCALE=20

set /a S1=66, S2=12, S3=30
set /a CUPOS=75, CUDIST=2200, CUZP=500, TRIDIST=3500, CHZP=400, BEZXM=200, GXYZP=900, ZOOMZP=900, GLZP=800, PXLZP=1200, OSZP=1100, SIDEDI=700, TORDI=1100, TDIST=700, TDISTADD=34, TDIST2=800, TDA2=90, TDIST3=700, TDA3=55, TDIST4=1000, TDA4=260
::W leq 1680
if %W% leq 428 set /a CUPOS=55, CUDIST=2600, CUZP=500, TRIDIST=3700, CHZP=340, BEZXM=160, GXYZP=760, ZOOMZP=790, GLZP=650, PXLZP=1100, OSZP=1030, SIDEDI=740, TORDI=1200, TDIST=900, TDISTADD=40, TDIST2=1000, TDA2=150, TDIST3=1100, TDA3=95, TDIST4=1000, TDA4=260
::W leq 1366(1280)
if %W% leq 348 set /a CUPOS=47, CUDIST=2900, CUZP=500, TRIDIST=5000, CHZP=290, BEZXM=130, GXYZP=630, ZOOMZP=750, GLZP=500, PXLZP=1000, OSZP=920, SIDEDI=840, TORDI=1450, TDIST=1000, TDISTADD=50, TDIST2=1300, TDA2=200, TDIST3=1500, TDA3=130, TDIST4=1000, TDA4=260
::W leq 1024
if %W% leq 264 set /a CUPOS=40, CUDIST=3200, CUZP=500, TRIDIST=5500, CHZP=280, BEZXM=120, GXYZP=600, ZOOMZP=700, GLZP=470, PXLZP=950, OSZP=900, SIDEDI=870, TORDI=1550, TDIST=1000, TDISTADD=50, TDIST2=1300, TDA2=200, TDIST3=1500, TDA3=130, TDIST4=1000, TDA4=260
::W leq 800
if %W% leq 208 set /a CUPOS=35, CUDIST=4000, CUZP=500, TRIDIST=7000, CHZP=210, BEZXM=100, GXYZP=450, ZOOMZP=500, GLZP=350, PXLZP=700, OSZP=750, SIDEDI=1000, TORDI=1850, TDIST=1300, TDISTADD=65, TDIST2=1500, TDA2=200, TDIST3=1500, TDA3=140, TDIST4=1000, TDA4=260
::W geq 1920
if %W% geq 520 set /a CUPOS=75, CUDIST=2100, CUZP=500, TRIDIST=2500, CHZP=600, BEZXM=280, GXYZP=1200, ZOOMZP=1300, GLZP=1100, PXLZP=2000, OSZP=1800, SIDEDI=500, TORDI=700, TDIST=500, TDISTADD=25, TDIST2=600, TDA2=110, TDIST3=500, TDA3=60, TDIST4=800, TDA4=260

set FN=objects\triBig.obj
if %H% leq 145 set FN=objects\triBig2.obj
if %H% leq 110 set FN=objects\tri.obj


set /a A1=155,A2=0,A3=0,A4=0,CNT=0
set /a TRANSP=0, TV=-1
set /a MONO=0 & set MONS=

set /a LIGHT=0, LTIME=1000, LA=0

set /a T_ON=0, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=5, TARZ=10, TARX=0, TXMID=%XMID%, TXMA=0
set TNAME=alphMisol.obj
set /a TORUS_ON=0

set /a CS=0,CCNT=0,C0=8,C1=7,CDIV=10,CW=0 & set /a CEND=2*!CDIV! & set C2=f&set C3=f&set C4=f
set /a CCNT=%CEND%, CS=2
set /a STEP=0
set MONOCOL=fe

set TMOD=0
if exist timeadjust.txt set /p TMOD=<timeadjust.txt

set STOP=
:LOOP
for /L %%_ in (1,1,300) do if not defined STOP (

	set /a A1+=2, A2+=3, A3-=1, A4+=10, TRZ=!CRZ!
	if !MODE!==0 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t3.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,%CUDIST%,%ASPECT% 1 0 db"
	if !MODE!==1 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t6.obj 5,!TV! !A1!,!A2!,!A3! 0,0,0 810,810,810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,%CUDIST%,%ASPECT% 1 0 db 9 0 db 2 0 db a 0 db 3 0 db b 0 db 4 0 db c 0 db 5 0 db d 0 db 6 0 db e 0 db"
	if !MODE!==2 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\spaceship.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 410,410,410,0,0,0 1,0,0,10 %CUPOS%,%CUPOS%,%CUDIST%,%ASPECT% 1 0 db"
	if !MODE!==3 set OUTP="fbox 7 0 20 0,0,%W%,%H% & 3d objects\cube-t-checkers.obj 6,!TV! !A1!,!A2!,!A3! 0,0,0 1810,1810,1810,0,0,0 0,0,0,10 %CUPOS%,%CUPOS%,%CUDIST%,%ASPECT% 0 0 db -1 -6 db 0 2 db 0 -8 db 0 -1 db"

	 for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d !FN! 1,-1 0,0,!TRZ! 0,0,0 !SCALE!,!SCALE!,!SCALE!,0,0,0 0,0,0,10 !XMID!,!YMID!,%TRIDIST%,!ASPECT! 0 0 db & 3d !FN! %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 !SCALE!,!SCALE!,!SCALE!,0,0,0 0,0,0,10 !XMID!,!YMID!,%TRIDIST%,!ASPECT! 0 0 db"&set /A TRZ+=%S3%*4
	
	set TTEXT=
	if !T_ON! == 1 (
		set /a TDIST+=!TDISTADD!
		set /a TXRZ+=!TARZ!,TXRX+=!TARX!,TXMID+=!TXMA!
		if !TXRZ! gtr 4320 if !TNAME!==alphMisol.obj set /a TXRZ=4320, TXRY+=10,TDIST-=!TDISTADD! 
		set TTEXT=3d objects\!TNAME! 5,!TCOLADD! !TXRX!,!TXRY!,!TXRZ! 0,0,0 3,3,3,0,0,0 0,0,0,10 !TXMID!,%YMID%,!TDIST!,%ASPECT% !TCOLADD! 0 db
	)
	
	set TORUS=
	if !TORUS_ON! == 1 (
		set TORUS=3d objects\torus.plg 1,0 !A4!,!CRZ!,!A2! 0,0,0 -1,-1,-1,0,0,0 0,0,0,0 %XMID%,%YMID%,%TORDI%,%ASPECT% f 0 db f b b2 b 0 db b 7 b2 b 7 b1 7 0 db 9 7 b1 9 7 b2 9 0 db 9 1 b1 9 1 b0 1 0 db 1 0 b2 1 0 b1 1 0 b0 1 0 b0 0 0 db 0 0 db
	)

	echo "cmdgfx: !OUTP:~1,-1! & !MONS! & !FADE! & skip text a 0 0 _!a!_ 1,1 & !TTEXT! & !TORUS! & skip text a 0 0 [FRAMECOUNT] 1,1 & skip text a 0 0 !W!_!H! 1,1" f!FNT!:0,0,!W!,!H!W16Z%CUZP%
	set OUTP=

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	set /a CRZ+=4, CNT+=1

	if !CS! gtr 0 (
		set /a CP=!CCNT!/!CDIV!,CCP=!CCNT!/!CDIV!+2 & for %%a in (!CP!) do for %%b in (!CCP!) do set FADE=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!C%%b!!C%%a!??
		if !CS!==2 set /a CCNT-=1&if !CCNT! lss 0 set /a CS=0&set FADE=
		if !CS!==1 set /a CCNT+=1&if !CCNT! gtr !CEND! set /a CCNT=!CEND!,CW+=1
		if !CW! gtr 10 set /a CW=0,CS=2, MODE+=1
	)
	
	if !LIGHT! == 1 for /F "tokens=1-8 delims=:.," %%a in ("!t2!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %LTIME% set /a KEY=109 & set t2=!time: =0!

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000"
	
	set /a a-=%TMOD%

 	if !STEP! == 0 if !a! geq 15000 set /a CS=1,TV=20,STEP+=1,CDIV=5 & set /a CEND=2*!CDIV! & set /a CCNT=0
	if !STEP! == 1 if !a! geq 30600 if !a! lss 31100 set MONS=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=c4??
	if !STEP! == 1 if !a! geq 31100 set /a LIGHT=1,STEP+=1,KEY=109 & set t2=!time: =0!
	if !STEP! == 2 if !a! geq 46000 echo "" F>%SF% & call :CHECKERBOX 0 & set /a STEP+=1,LIGHT=0&set MONS=
	if !STEP! == 3 if !a! geq 53800 echo "" F>%SF% & call :BEZCOL & set /a STEP+=1,LIGHT=0&set MONS=
	if !STEP! == 4 if !a! geq 61000 set /a LIGHT=1,STEP+=1,KEY=109 & set t2=!time: =0!&set MONOCOL=01&set LA=1
	if !STEP! == 5 if !a! geq 70000 set /a LIGHT=0,STEP+=1,KEY=0&set MONS=
	if !STEP! == 6 if !a! geq 76800 echo "" F>%SF% & call :GXYCUBE 3 -800 & set /a STEP+=1
	if !STEP! == 7 if !a! geq 84500 echo "" F>%SF% & call :OBJSORTED 1 & set /a STEP+=1
	if !STEP! == 8 if !a! geq 92000 echo "" F>%SF% & call :PLAYSEQ seq 2542 2597 & set /a STEP+=1
	if !STEP! == 9 if !a! geq 92000 echo "" F>%SF% & call :ZOOMER & set /a STEP+=1
	if !STEP! == 10 if !a! geq 92000 set /a MODE=2,T_ON=1,A1=155,A2=0,A3=0,CRZ=0,TV=-1 & set /a STEP+=1
	if !STEP! == 11 if !a! geq 138200 echo "" F>%SF% & call :SIDECUBE 3 %SIDEDI% & set /a MODE=0,STEP+=1,TV=-1, TDIST=%TDIST2%, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=%TDA2%, TARZ=11&set TNAME=alphCari.obj
	if !STEP! == 12 if !a! geq 146000 echo "" F>%SF% & call :GLENZ 1600 350 1 & set /a STEP+=1
	if !STEP! == 13 if !a! geq 146000 set /a MODE=1,TV=-1, TDIST=%TDIST3%, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=%TDA3%, TARZ=0 & set /a STEP+=1&set TNAME=alphLove.obj 
	if !STEP! == 14 if !a! geq 153000 echo "" F>%SF% & call :PIXELOBJ 0 800 & set /a STEP+=1,LIGHT=0&set MONS=&set /a T_ON=0,TV=20,TORUS_ON=1
	if !STEP! == 15 if !a! geq 169000 echo "" F>%SF% & call :GXYCUBE 3 800 & set /a STEP+=1,TORUS_ON=0
	if !STEP! == 16 if !a! geq 176600 echo "" F>%SF% & call :CHECKERBOX 4 & set /a STEP+=1
	if !STEP! == 17 if !a! geq 183800 echo "" F>%SF% & call :PIXELOBJ 2 800 & set /a STEP+=1
	
	if !STEP! == 18 if !a! geq 190000 set /a T_ON=1, TDIST=%TDIST4%, TXRX=0, TXRY=0, TXRZ=0, TCOLADD=6, TDISTADD=%TDA4%, TARZ=5&set TNAME=alphBail.obj & set /a STEP+=1
	if !STEP! == 19 if !a! geq 200000 set /a T_ON=0 & set /a STEP+=1
	
	if !KEY! == 112 cmdwiz getch
	
	if !CNT! gtr 1307 set /a A3+=1
	if !CNT! gtr 1400 set /a CNT=0
	if !KEY! == 109 set /A MONO=1-!MONO!&(if !MONO!==1 if !LA! gtr 0 set MONOCOL=0!LA!&set /a LA+=1)&(if !MONO!==1 set MONS=block 0 0,0,%W%,%H% 0,0 -1 0 0 ????=!MONOCOL!??)&(if !MONO!==0 set MONS=)
	if !KEY! == 27 set STOP=1

	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
goto :eof



:PLAYSEQ
setlocal ENABLEDELAYEDEXPANSION
echo "" F>%SF%
set t3=!time: =0!
set STOP=
set /a CNT=%2

set /a "XBP=%W%/2-189/2, YBP=%H%/2-80/2"
set /a "FXBP=%XBP%-15, FYBP=%YBP%-10"
if "%REALFS%"=="1" set EXTRA=&for /l %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
set /a H2=H+2

:PLREP
for /L %%_ in (1,1,300) do if not defined STOP (

	if "%REALFS%"=="" cmdgfx_gdi "image %1\!CNT!.gxy 0 0 0 -1 0,0 0 0 %W%,%H2% & skip block 0 0,0,%W%,%H2% 0,0 -1 0 0 ????=10?? & fbox 0 0 b2 %FXBP%,%FYBP%,219,97 & image %1\!CNT!.gxy 0 0 0 -1 %XBP%,%YBP% 0 0 189,80" W60kf0:0,0,%W%,%H2%
	if "%REALFS%"=="" set KEY=!ERRORLEVEL!

	if "%REALFS%"=="1" echo "cmdgfx: image %1\!CNT!.gxy 0 0 0 -1 0,0 0 0 %W%,%H2% & skip block 0 0,0,%W%,%H2% 0,0 -1 0 0 ????=10?? & fbox 0 0 b2 %FXBP%,%FYBP%,219,97 & image %1\!CNT!.gxy 0 0 0 -1 %XBP%,%YBP% 0 0 189,80 & skip %EXTRA% %EXTRA% %EXTRA% %EXTRA% %EXTRA%" zW60f0:0,0,%W%,%H2%
	if "%REALFS%"=="1" if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul	

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 27000 set /a STOP=1
	
	set /a CNT+=1
	if !CNT! gtr %3 set /a CNT=%2
	
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto PLREP
if "%REALFS%"=="1" echo "" F>%SF%
endlocal
goto :eof



:SIDECUBE
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=5, ROTMODE=0, DIST=1500, COLP=0, OBJ=1, CLEAR=1, ZPROJ=300
set CLS=&set STOP=
set ASPECT=0.665

set FNAME=sidecube.obj
set FNAME2=sidecube2.obj
set PAL=f 0 db f b b2 b 0 db b 7 b2 b 7 b1 7 0 db 9 7 b1 9 7 b2 9 0 db 9 1 b1 9 1 b0 1 0 db 1 0 b2 1 0 b1 1 0 b0 1 0 b0 0 0 db 0 0 db

set /a OBJ=%1, DIST=%2

:SCREP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a RX2+=3, RY2+=6, RZ2-=4	

	echo "cmdgfx: fbox 3 0 b0 0,0,%W%,%H% & fbox 0 0 20 3,3,62,40 & fbox 1 1 b0 80,0,90,%H% & fbox 0 0 20 94,4,60,50 & fbox 1 3 b0 0,48,79,41 & fbox 0 0 20 4,50,66,35 & 3d objects\cube.ply 2,0 !RY2!,!RX2!,!RZ2! 0,0,0 -200,-200,-200,0,0,0 1,0,0,10 35,25,4000,0.665 %PAL% & 3d objects\icosahedron.ply 1,0 !RY2!,!RZ2!,!RY2! 0,0,0 -230,-230,-230,0,0,0 0,0,0,10 125,30,2600,0.8 %PAL% & 3d objects\tetrahedron.ply 2,0 !RZ2!,!RX2!,0 0,0,0 -220,-220,-220,0,0,0 0,0,0,10 38,69,3600,0.6 %PAL% & 3d objects\!FNAME2! 0,-1 0,0,0 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,99999,1.3 0 0 db & !CLS! fbox 1 0 20 0,0,%W%,%H% & 3d objects\!FNAME2! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 380,380,380, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 4 0 db 4 0 db 1 0 db 1 0 db 2 0 db 2 0 db 3 0 db 3 0 db 5 0 db 5 0 db 0 0 db 0 0 db" Z%ZPROJ%f0:0,0,%W%,%H%W12

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 3950 set /a STOP=1
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul	
	
	set /a RX+=4, RY+=7, RZ-=5
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto SCREP
echo "" F>%SF%

endlocal
goto :eof



:PIXELOBJ
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a XMID=%W%/2,YMID=%H%/2,DIST=7000,DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.66
set COLS0=f 0 04 f 0 04 f 0 04 7 0 04 7 0 04 8 0 04 8 0 04 8 0 04 8 0 04 8 0 04 8 0 04 8 0 fe
set /a COLCNT=0, OBJCNT=%1
set OBJ0=torus&set OBJ1=sphere&set OBJ2=double-sphere

set STOP=
:PIXLOOP
for /L %%_ in (1,1,300) do if not defined STOP for %%o in (!OBJCNT!) do (
	echo "cmdgfx: fbox 7 0 20 0,0,%W%,%H% & 3d objects\plot-!OBJ%%o!.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 1.2,1.2,1.2,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% %COLS0%" f0:0,0,%W%,%H%W12Z%PXLZP%
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq %2 set /a STOP=1
	
	set /A CRZ+=5,CRX+=3,CRY-=4
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto PIXLOOP
echo "" F>%SF%

endlocal
goto :eof



:GLENZ
setlocal ENABLEDELAYEDEXPANSION
set /a CNT=0
set /a XMID=%W%/2,YMID=%H%/2
set /a DIST=%1,DRAWMODE=0,RX=0,RY=0,RZ=0
set ASPECT=0.66
set t3=!time: =0!

set PAL0=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 7 0 db 7 0 db 7 0 db 7 0 db 7 0 db 7 0 db
set PAL1=1 0 db 1 0 db 1 0 db 1 0 db 1 0 db 1 0 db 8 0 db 8 0 db 8 0 db 8 0 db 8 0 db 8 0 db
set /a COLCNT=%3, BITOP=1, SCALE=%2

set FNAME=cube-g.ply
set MOD=250,250,250, 0,0,0 1
set MOD2=-250,-250,-250, 0,0,0 1

set STOP=
:GLREP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 8 08 0,0,%W%,%H% & 3d objects\%FNAME% 0,1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL1! & 3d objects\%FNAME% 0,!BITOP! !RX!,!RY!,!RZ! 0,0,0 -!SCALE!,-!SCALE!,-!SCALE!, 0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL0!" f0:0,0,%W%,%H%W10Z%GLZP%

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
	
	set /a RX+=5, RY+=6, RZ-=4, CNT+=1, CNTMOD=CNT %% 15
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto GLREP

endlocal
echo "" F>%SF%
goto :eof


:BEZCOL
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=%BEZXM%/!DIV!, YMUL=%BEZXM%/2/!DIV!, SXMID=%W%/2,SYMID=%H%/2, SHR=13
set /a NOFLINES=100, LINEGAP=10, LNCNT=1, DCNT=0, REP=80, COL=10, CCYCLE=1, CCYCLELEN=20, STARTLINE=1
set /a ENDCYCLE=!CCYCLELEN!*16-1, CCNT=10*!CCYCLELEN!
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

set /a P1=-2,P2=2,P3=-1,P4=1,P5=-3,P6=-1,P7=3,P8=2,SC=-863,CC=-1570,SC2=-1120,CC2=-2522,SC3=-1496,CC3=2092,SC4=3099,CC4=3240

:BEZLOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC+=!P1!,CC+=!P2!,SC2+=!P3!,CC2+=!P4!,SC3+=!P5!,CC3+=!P6!,SC4+=!P7!,CC4+=!P8!"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a A1=%%a,A2=%%b & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a A1=%%a,A2=%%b & set /a "XPOS2=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a A1=%%a,A2=%%b & set /a "XPOS3=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS3=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a A1=%%a,A2=%%b & set /a "XPOS4=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS4=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"

	for %%a in (!DCNT!) do set LN!LCNT!=line !COL! 0 !DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	for /L %%a in (!STARTLINE!,%LINEGAP%,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	set /a STARTLINE+=1&if !STARTLINE! gtr %LINEGAP% set STARTLINE=1
	
	echo "cmdgfx: fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 1 0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 0 1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 1 1" W12
	
	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
		 
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	if !CCYCLE!==1 set /a CCNT+=1&(if !CCNT! gtr !ENDCYCLE! set /a CCNT=10*!CCYCLELEN!)&set /a COL=!CCNT!/!CCYCLELEN!
	set /a KEY=0
)
if not defined STOP goto BEZLOOP

echo "" F>%SF%
endlocal
goto :eof



:CHECKERBOX
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a DIST=800,FONT=0,ROTMODE=0,NOFOBJECTS=5,RX=0,RY=0,RZ=0,RZ2=160
set ASPECT=0.605

set /a XMID=%W%/2, YMID=%H%/2, OBJINDEX=%1
set OBJTEMP=box-temp%1.obj
set PLANETEMP=plane-temp%1.obj
call :SETOBJECT

:CBREP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 0 0 20 0,0,%W%,%H% & 3d objects\%PLANETEMP% 0,58 0,0,!RZ2! 0,0,0 45,45,45,0,0,0 0,0,0,10 %XMID%,%YMID%,650,%ASPECT% 0 !PLANEMOD! db & 3d objects\%OBJTEMP% !DRAWMODE!,!TRANSP! !RX!,!RY!,!RZ! 0,0,0 400,400,400,0,0,0 !CULL!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COL!" Z%CHZP%f%FONT%:0,0,%W%,%H%W16

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set /a RZ2-=6
	if !ROTMODE! == 0 set /a RX+=4, RY+=8, RZ-=5
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto CBREP

endlocal
echo "" F>%SF%
goto :eof

:SETOBJECT
set /a CULL=1, DRAWMODE=5, PLANEMOD=-8
if %OBJINDEX% == 0 set /a DRAWMODE=6 & set COL=0 -8 db 0 -8 db 0 0 db 0 0 db 0 -6 db 0 -6 db 0 -6 db 0 -6 db 0 -3 db 0 -3 db 0 -4 db 0 -4 db &set TRANSP=-1
if %OBJINDEX% == 4 set /a CULL=0, PLANEMOD=-1 & set COL=0 2 db 0 2 db 0 2 db 0 2 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db&set TRANSP=58
goto :eof



:GXYCUBE
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a "XMID=%W%/2,YMID=%H%/2"
set /a DIST=%2,DRAWMODE=5,ROTMODE=0,SHOWHELP=1
set ASPECT=0.675
set /A RX=0,RY=0,RZ=0

set /a NOFOBJECTS=5
set FNAME=cube-t6.obj& set MOD=400,400,400, 0,0,0 0&set O=20
set PAL=f 2 db f 2 db b 3 db b 3 db d 5 db d 5 db 7 4 db 7 4 db f 1 db f 1 db f 6 db f 6 db

set STOP=
:GXYREP
for /L %%1 in (1,1,300) do if not defined STOP (
   echo "cmdgfx: fbox 8 0 fa 0,0,%W%,%H% & !MSG! & 3d objects/!FNAME! !DRAWMODE!,!O! !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" W16Z%GXYZP%f0:0,0,%W%,%H%
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1
	
	set /a RX+=4,RY+=9,RZ-=6
	
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto GXYREP

endlocal
echo "" F>%SF%
goto :eof



:ZOOMER
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!
set /a XMID=%W%/2,YMID=%H%/2,RX=0,RY=0,RZ=0,DIST=1000
set ASPECT=0.66
set STOP=

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

set /a MUL=2000, MMID=2600, SHR=13, SC=0
echo "cmdgfx: "

:ZOOMLOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for %%a in (!SC!) do set /a A1=%%a & set /a "DIST=!MMID!+(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!), SC+=1, RZ+=10"

	echo "cmdgfx: 3d objects\plane-apa.obj 0,0 !RX!,!RY!,!RZ! 0,0,0 150,150,150,0,0,0 0,0,0,0 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 0" TW12Z%ZOOMZP%

	for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul
	
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto ZOOMLOOP
echo "" F>%SF%
endlocal
goto :eof




:OBJSORTED
setlocal ENABLEDELAYEDEXPANSION
set t3=!time: =0!

set /a XMID=%W%/2,YMID=%H%/2
set /a DRAWMODE=1,NOF=6,DIST=2500,MODE=%1
set ASPECT=0.66

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

set EC=0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db 0 0 db
set COL1=f b b2 b 0 db b 7 b2 b 7 b1 7 0 db 9 7 b1 9 7 b2 9 0 db 9 1 b1 9 1 b0 1 0 db 1 0 b2 1 0 b1 1 0 b0 1 0 b0 %EC%
set COL2=f a db f a b1 f a b0 a 7 b0 a 7 b1 a 7 b2 a 0 db a 0 db a 2 b1 a 2 b0 2 0 db 2 0 b2 2 0 b1 2 0 b0 2 0 b0 %EC%
set COL3=f c db f c b1 f c b0 c 7 b0 c 7 b1 c 7 b2 c 0 db c 0 db c 4 b1 c 4 b0 4 0 db 4 0 b2 4 0 b1 4 0 b0 4 0 b0 %EC%
set COL4=f d db f d b1 f d b0 d 7 b0 d 7 b1 d 7 b2 d 0 db d 0 db d 5 b1 d 5 b0 5 0 db 5 0 b2 5 0 b1 5 0 b0 5 0 b0 %EC%
set COL5=f e db f e b1 f e b0 e 7 b0 e 7 b1 e 7 b2 e 0 db e 0 db e 6 b1 e 6 b0 6 0 db 6 0 b2 6 0 b1 6 0 b0 6 0 b0 %EC%
set COL6=f b db f 7 b1 f 7 b1 f 8 b1 7 0 db 7 8 b1 7 8 b2 7 0 db 7 8 b2 7 8 b0 8 0 db 8 0 b2 8 0 b1 8 0 b0 8 0 b0 %EC%

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

	for /L %%a in (1,1,!NOF!) do set /a ZI=1,ZV=!ZPP21!&for /L %%b in (2,1,!NOF!) do (if !ZPP2%%b! gtr !ZV! set ZI=%%b&set ZV=!ZPP2%%b!)&if %%b==!NOF! for %%c in (!ZI!) do set /a XR%%c+=!XRA%%c!,YR%%c+=!YRA%%c!&set CRSTR="!CRSTR:~1,-1!&3d objects\elephav.obj !DRAWMODE!,1 !XR%%c!,!YR%%c!,0 !XPP2%%c!,!YPP2%%c!,!ZPP2%%c! 0.3,0.3,0.3,0,-360,0 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !COL%%c!"&set ZPP2%%c=-999999

	 for /F "tokens=1-8 delims=:.," %%a in ("!t3!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000" & if !a! geq 4000 set /a STOP=1

	echo "cmdgfx: fbox 1 0 20 0,0,%W%,%H% & !CRSTR:~1,-1!" f0:0,0,%W%,%H%W15Z%OSZP%
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set /a XROT-=3, YROT+=2, ZROT+=1

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto OSLOOP

echo "" F>%SF%
endlocal
goto :eof



:STARTDEMO
setlocal ENABLEDELAYEDEXPANSION
set SF=servercmd.dat
taskkill.exe /F /IM dlc.exe>nul 2>nul
start "" /B dlc.exe -p "silence-1sec.mp3">nul
cmdwiz print "Cari Lekebusch_ - Obscurus Sanctus.mp3\ntv-static-04.mp3\nobjects\\Hulk.obj\nobjects\\elephav.obj\nimg\\ful.gxy\nimg\\apa.gxy\ncmdgfx.exe\ndlc.exe">cachelist.dat
cmdwiz cache cachelist.dat

if "%~1" == "" call :STATIC
if "%~1" == "S" call :STATIC
echo "fbox 0 0 20 0,0,%W%,%H%" Ff0 000000,000080>%SF%

start "" /B dlc.exe -p "Cari Lekebusch_ - Obscurus Sanctus.mp3">nul
cmdgfx_gdi "" f7w150
echo "cmdgfx: fbox 0 0 20 0,0,%W%,%H%" Ff0 000000,000080
echo "" F>%SF%
cmdgfx_gdi "" f7w500

for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if not %%v==SF if not %%v==REALFS if /I not %%v==path set "%%v="
set t1=!time: =0!

call :KALEIDO
:ENDIT
cmdwiz delay 100
echo "cmdgfx: quit"

endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
taskkill.exe /F /IM dlc.exe>nul
del /Q EL.dat cachelist.dat CGXMS.dat >nul 2>nul
