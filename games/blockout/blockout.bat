:: Blockout Server version: Mikael Sollenborn 2017

@echo off
cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12x | call %0 %* | cmdgfx_gdi.exe "" Sf0:0,0,220,110
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & bg font 6
set /a W=220,H=110
set /a F6W=W/2,F6H=H/2
mode %F6W%,%F6H% & cls
cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

set /a XMID=%W%/2, YMID=%H%/2
set DIST=0
set ASPECT=0.6666
set HISCORE=0&if exist hiscore.dat for /F "tokens=*" %%i in (hiscore.dat) do set HISCORE=%%i

set /a WW=4,WH=4,WD=8
set NOFBLOCKS=9
set NORMBLOCKS=5
set /a ODDBLOCKS=%NOFBLOCKS%-%NORMBLOCKS%
set PP=abcdefabcdef

set LINE=&set LINEF=
for /L %%a in (0,1,%WW%) do set LINE=!LINE!-
for /L %%a in (0,1,%WW%) do set LINEF=!LINEF!1

:: .
set P0=222
:: |__
set P1=112;122;222;322
:: |_
set P2=112;122;222
:: ||
set P3=222;322;232;332
:: _|_
set P4=122;222;322;212

:: -----
set P5=022;122;222;322;422
:: |--
set P6=112;122;222;322;132
:: A_
set P7=112;122;222;121
:: |_|
set P8=112;122;222;322;312

set /a NT=%NOFBLOCKS%-1&for /L %%a in (0,1,!NT!) do cmdwiz stringlen !P%%a!&set /A P%%aNOF=(!ERRORLEVEL!+1)/4&set P%%a_c=!PP:~%%a,1!

set /A PDIMM=4

set FN=piece.obj
set FL=bl-logo.obj

set /a Vx0=-1, Vy0=-1, Vz0=-1
set /a Vx1=1,  Vy1=-1, Vz1=-1
set /a Vx2=1,  Vy2=1,  Vz2=-1
set /a Vx3=-1, Vy3=1,  Vz3=-1
set /a Vx4=-1, Vy4=-1, Vz4=1
set /a Vx5=1,  Vy5=-1, Vz5=1
set /a Vx6=1,  Vy6=1,  Vz6=1
set /a Vx7=-1, Vy7=1,  Vz7=1

set /a F0_0=0, F0_1=3, F0_2=2, F0_3=1
set /a F1_0=5, F1_1=6, F1_2=7, F1_3=4
set /a F2_0=6, F2_1=5, F2_2=1, F2_3=2
set /a F3_0=3, F3_1=0, F3_2=4, F3_3=7
set /a F4_0=7, F4_1=6, F4_2=2, F4_3=3
set /a F5_0=5, F5_1=4, F5_2=0, F5_3=1

set /a SVX=-4,SVY=-4,SVZ=-2,XP=0,YP=0
set MULVAL=100
set /a ZMULVAL=%MULVAL%*8
set /a ZMUL2=%ZMULVAL%*2

goto OUTERLOOP

set FBG=bg.obj&del /Q !FBG!>nul 2>nul
for /L %%z in (0,%ZMUL2%,13000) do for /L %%a in (-5,2,5) do for /L %%b in (-5,2,5) do set /a X=%%b*%MULVAL%& set /a Y=%%a*%MULVAL%&set /a Z=-%%z&echo v !X! !Y! !Z!>>%FBG%
for /L %%a in (0,1,5) do set /a f1=%%a*6+1&set /a f2=%%a*6+1+5&set /a f3=%%a+1&set /a f4=%%a+1+30&echo f !f1!// !f2!//>>%FBG%&echo f !f3!// !f4!//>>%FBG%
for /L %%a in (0,1,7) do set /a f1=1+36*%%a&set /a f2=1+5+36*%%a&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,7) do set /a f1=1+36*%%a+30&set /a f2=1+5+36*%%a+30&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,7) do set /a f1=1+36*%%a&set /a f2=1+30+36*%%a&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,7) do set /a f1=1+36*%%a+5&set /a f2=1+30+36*%%a+5&echo f !f1!// !f2!//>>%FBG%

for /L %%a in (0,1,5) do set /a f1=1+%%a&set /a f2=1+%%a+36*7&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,5) do set /a f1=1+%%a+30&set /a f2=1+%%a+36*7+30&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,5) do set /a f1=1+6*%%a&set /a f2=1+6*%%a+36*7&echo f !f1!// !f2!//>>%FBG%
for /L %%a in (0,1,5) do set /a f1=1+6*%%a+5&set /a f2=1+6*%%a+36*7+5&echo f !f1!// !f2!//>>%FBG%

echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & 3d %FBG% 1,0 0,0,0 0,0,0 1,1,1,0,0,0 0,0,0,0 %XMID%,!YMID!,12500,%ASPECT% 2 0 ." c:0,0,%W%,%H%,1,0
echo "cmdgfx: " c:0,0,%W%,%H%,1,1

goto OUTERLOOP

set logo0=111--1-----11---11--1--1--11--1--1-11111
set logo1=1--1-1----1--1-1--1-1-1--1--1-1--1---1--
set logo2=111--1----1--1-1----11---1--1-1--1---1--
set logo3=1--1-1--1-1--1-1--1-1-1--1--1-1--1---1--
set logo4=111--1111--11---11--1--1--11---11----1--

del /Q %FL%>nul 2>nul
set NOF_B=0
cmdwiz stringlen %logo0%&set /A NOF=!errorlevel!-1&set /A NOFDIV=!NOF!/2
for /L %%j in (0,1,4) do (
	for /L %%i in (0,1,%NOF%) do (
	  set S=!logo%%j:~%%i,1!
		if not !S!==- (
		  set /A X=-!NOFDIV!+%%i,Y=%%j-2,Z=1
		  for %%a in (!X!) do for %%b in (!Y!) do for %%c in (!Z!) do (
			 for /L %%d in (0,1,7) do set /a vx=!Vx%%d!+!X!*2&set /a vx=!vx!*%MULVAL% & set /a vy=!Vy%%d!+!Y!*2&set /a vy=!vy!*%MULVAL%-%MULVAL%/2 & set /a vz=!Vz%%d!+!Z!&set /a vz=!vz!*%MULVAL%&echo v !vx! !vy! !vz!>>%FL%
			 for %%e in (!NOF_B!) do for /L %%f in (0,1,1) do set /a f0=!F%%f_0!+%%e*8+1&set /a f1=!F%%f_1!+%%e*8+1&set /a f2=!F%%f_2!+%%e*8+1&set /a f3=!F%%f_3!+%%e*8+1&echo f !f0!// !f1!// !f2!// !f3!// >>%FL%
		  )
		  set /A NOF_B+=1
		)
	)
)
for /L %%a in (0,1,4) do set logo%%a=

:OUTERLOOP

set /a GAMEOVER=0, SCORE=0, ADDVAL=10, ZD=0, CNT=0
set /a RX=0,RY=0,RZ=0

set STOP=&set ESCKEY=
 
copy /Y background.gxy capture-1.gxy >nul 2>nul

echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & image capture-1.gxy 2 0 0 -1 0,0 & 3d %FL% 3,-1 !RX!,!RY!,!RZ! -60,1520,0 1,2,1,0,0,0 0,0,0,0 %XMID%,!YMID!,20000,%ASPECT% a 0 b1 2 0 b1" f0
echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & box 2 0 fa 0,0,28,19 & & text e 0 0 Press_SPACE_to_play\n\n\c0\-Press_ESC_to_quit 6,2 & text 9 0 0 \a0\-\-\-INGAME_KEYS:\r\n\n\70Cursor_Keys\r_-_Move\n\n\70Z/z_\r_-_Rotate_Z\n\n\70X/x_\r_-_Rotate_X\n\n\70C/c_\r_-_Rotate_Y\n\n\70SPACE\r_-_Drop 6,7" f6:40,29,29,20

:IDLELOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	echo "cmdgfx: fbox 2 0 20 0,0,%W%,%H% & image capture-1.gxy 2 0 0 -1 0,0 & 3d %FL% 3,-1 !RX!,!RY!,!RZ! -60,1520,0 1,2,1,0,0,0 0,0,0,0 %XMID%,!YMID!,20000,%ASPECT% a 0 b1 2 0 b1" Ff0:0,0,%W%,50

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 
	
	if !K_DOWN! == 1 (
		if !KEY! == 32 set STOP=1
		if !KEY! == 27 set STOP=1&set ESCKEY=1
	)
		
	if !CNT! lss 480 set /A RX+=12
	if !CNT! gtr 480 set /A RY+=12
	if !CNT! gtr 840 set /A CNT=-1&set RX=0&set RY=0
	set /A CNT+=1
	set /a KEY=0
)
if not defined STOP goto IDLELOOP
if defined ESCKEY goto OUTOF

call :NEXTBLOCK
set P=!P%P_I%!
set PNOF=!P%P_I%NOF!
set /a RX=0,RY=0,RZ=0

for /L %%a in (-1,1,%WD%) do for /L %%b in (0,1,%WH%) do set LINE%%a_%%b=!LINE!
set /A WDB=%WD%+1
for /L %%a in (%WDB%,1,%WDB%) do for /L %%b in (0,1,%WH%) do set LINE%%a_%%b=!LINEF!
for /L %%a in (0,1,%WDB%) do set CL%%a=0

echo W16>inputflags.dat

call :MKBLOCKS

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%p in (!P_I!) do (

	set /A X=!XP!*%MULVAL%*2
	set /A Y=!YP!*%MULVAL%*-2
	set COL=!P%%p_c!
	set /a "BI=(!ZD!-450) / (%ZMUL2%)"
	set /a "DD=(!ZD!-450) %% (%ZMUL2%)" & if !DD! lss 100 if !DD! geq 0 for %%a in (!BI!) do if !CL%%a!==0 set CL%%a=1&call :ISCOLLIDE 0 0 0 %%a
	set ERR=&if !VALID!==0 set ERR=box f 0 db 0,0,219,109

	echo "cmdgfx: image capture-1.gxy 2 0 0 -1 0,0 & 3d %FN% 3,-1 !RX!,!RY!,!RZ! !X!,!Y!,0 1,1,1,0,0,!ZD! 0,800,0,0 %XMID%,!YMID!,!DIST!,%ASPECT% !COL! 0 fe & text e 0 0 Score:_!SCORE!_\e0(!HISCORE!) 2,1 & !ERR!" FDf0:0,0,%W%,%H%

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul ) 

	set /A ZD+=!ADDVAL!

	if !GAMEOVER!==1 set STOP=1

	if !K_DOWN! == 1 (
		if !KEY! == 120 call :ROT X 1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 88 call :ROT X -1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 99 call :ROT Y 1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 67 call :ROT Y -1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 122 call :ROT Z 1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 90 call :ROT Z -1&if !VALID!==1 call :MKBLOCKS
		if !KEY! == 32 set ADDVAL=90

		if !KEY! == 331 set /A B=!MINX!+!XP!&if !B! gtr 0 for %%a in (!BI!) do call :ISCOLLIDE 2 -1 0 %%a&if !VALID!==1 set /A XP-=1
		if !KEY! == 333 set /A B=!MAXX!+!XP!&if !B! lss !PDIMM! for %%a in (!BI!) do call :ISCOLLIDE 2 1 0 %%a&if !VALID!==1 set /A XP+=1
		if !KEY! == 328 set /A B=!MINY!+!YP!&if !B! gtr 0 for %%a in (!BI!) do call :ISCOLLIDE 2 0 -1 %%a&if !VALID!==1 set /A YP-=1
		if !KEY! == 336 set /A B=!MAXY!+!YP!&if !B! lss !PDIMM! for %%a in (!BI!) do call :ISCOLLIDE 2 0 1 %%a&if !VALID!==1 set /A YP+=1

		if !KEY! == 115 call :DEBUG
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 27 set STOP=1
	)
	
	set /a KEY=0
)
if not defined STOP goto LOOP

echo W12>inputflags.dat

if !GAMEOVER!==0 goto OUTERLOOP
for /l %%a in (1,1,50) do echo "cmdgfx: text f 0 0 G_A_M_E___O_V_E_R\n\n\n\n\c0\-\-\-PRESS_A_KEY 6,4" f2:41,34,29,14
cmdwiz getch
echo "cmdgfx: " f0:0,0,%W%,%H%
goto OUTERLOOP

:OUTOF
echo "cmdgfx: quit"
echo Q>inputflags.dat
echo %HISCORE%>hiscore.dat
del /Q %FN%>nul 2>nul
del /Q %FBG%>nul 2>nul
del /Q capture-1.gxy>nul 2>nul
del /Q lay?.obj>nul 2>nul
endlocal
cmdwiz showcursor 1
bg font 6
mode 80,50 & cls
goto :eof



:MKBLOCKS
set NOF_B=0
set /A MAXX=-69,MINX=69,MAXY=-69,MINY=69,MAXZ=-69,MINZ=69
set /A NOF=!PNOF!-1
set OUT=""
for /L %%i in (0,1,%NOF%) do (
  set /A X=%%i*4,Y=%%i*4+1,Z=%%i*4+2
  for %%a in (!X!) do for %%b in (!Y!) do for %%c in (!Z!) do (
    set ZT=!P:~%%c,1!&set YT=!P:~%%b,1!&set XT=!P:~%%a,1!
    for /L %%d in (0,1,7) do set /a vx=!SVX!+!Vx%%d!+!XT!*2&set /a vx=!vx!*%MULVAL% & set /a vy=!SVY!+!Vy%%d!+!YT!*2&set /a vy=!vy!*%MULVAL% & set /a vz=!SVZ!+!Vz%%d!+!ZT!*2&set /a vz=!vz!*%ZMULVAL%&set OUT="!OUT:~1,-1! echo v !vx! !vy! !vz! & "
    for %%e in (!NOF_B!) do for /L %%f in (0,1,5) do set /a f0=!F%%f_0!+%%e*8+1&set /a f1=!F%%f_1!+%%e*8+1&set /a f2=!F%%f_2!+%%e*8+1&set /a f3=!F%%f_3!+%%e*8+1&set OUT="!OUT:~1,-1! echo f !f0!// !f1!// !f2!// !f3!// &"
  )
  if !XT! gtr !MAXX! set MAXX=!XT!
  if !XT! lss !MINX! set MINX=!XT!
  if !YT! gtr !MAXY! set MAXY=!YT!
  if !YT! lss !MINY! set MINY=!YT!
  if !ZT! gtr !MAXZ! set MAXZ=!ZT!
  if !ZT! lss !MINZ! set MINZ=!ZT!
  set /A NOF_B+=1
)

set OUT="%OUT:~1,-2%"
(%OUT:~1,-1%)>%FN%
set OUT=

for /L %%a in (1,1,3) do set /A B=!MINX!+!XP!&if !B! lss 0 set /A XP+=1
for /L %%a in (1,1,3) do set /A B=!MAXX!+!XP!&if !B! gtr !PDIMM! set /A XP-=1
for /L %%a in (1,1,3) do set /A B=!MINY!+!YP!&if !B! lss 0 set /A YP+=1
for /L %%a in (1,1,3) do set /A B=!MAXY!+!YP!&if !B! gtr !PDIMM! set /A YP-=1
goto :eof


:ROT
set /A NOF=!PNOF!-1
set PT=%P%
set P=
for /L %%i in (0,1,%NOF%) do (
  set /A X=%%i*4,Y=%%i*4+1,Z=%%i*4+2
  for %%a in (!X!) do for %%b in (!Y!) do for %%c in (!Z!) do (
    set ZT=!PT:~%%c,1!&set YT=!PT:~%%b,1!&set XT=!PT:~%%a,1!
	 if %1==Z (
  	   if "%2"=="1" set /A XT=4-!XT!
	   if "%2"=="-1" set /A YT=4-!YT!
	   set P=!P!!YT!!XT!!ZT!;
	 )
	 if %1==X (
  	   if "%2"=="1" set /A XT=4-!XT!
	   if "%2"=="-1" set /A ZT=4-!ZT!
	   set P=!P!!ZT!!YT!!XT!;
	 )
	 if %1==Y (
  	   if "%2"=="1" set /A YT=4-!YT!
	   if "%2"=="-1" set /A ZT=4-!ZT!
	   set P=!P!!XT!!ZT!!YT!;
	 )
  )
)
call :ISCOLLIDE 2 0 0 %BI%
if %VALID%==0 set P=%PT%
goto :eof


:RENDERFILLED
set PAL=123456789

echo "cmdgfx: image background.gxy 2 0 0 -1 0,0" n

for /L %%a in (%WD%,-1,0) do for /L %%t in (1,1,2) do set BC=!PAL:~%%a,1!&for /L %%b in (0,1,%WH%) do for /L %%c in (0,1,%WW%) do set S=!LINE%%a_%%b:~%%c,1!&if not !S!==- set /a "movx=(-2+%%c)*200, movy=(2-%%b)*200, movz=10900-(%WD%-%%a)*1600" & echo "cmdgfx: 3d cube%%t.obj 0,-1 0,0,0 !movx!,!movy!,!movz! 1,1,1,0,0,0 1,800,0,100 %XMID%,!YMID!,!DIST!,%ASPECT% !BC! 0 db !BC! 0 db !BC! 0 b1 !BC! 0 b1 !BC! 0 b1 !BC! 0 b1" n

echo "cmdgfx: text e 0 0 Score:_!SCORE!_\e0(!HISCORE!) 2,1" Dec:0,0,%W%,%H%,1,1
goto :eof


:ISCOLLIDE
set VALID=1
set PT=%P%
set /A NOF=!PNOF!-1
for /L %%i in (0,1,%NOF%) do (
  set /A XPP=%%i*4,YPP=%%i*4+1,ZPP=%%i*4+2
  for %%a in (!XPP!) do for %%b in (!YPP!) do for %%c in (!ZPP!) do (
    set ZT=!PT:~%%c,1!&set YT=!PT:~%%b,1!&set XT=!PT:~%%a,1!
    set /a XT+=%XP%+%2,YT+=%YP%+%3,ZT+=%4

	 if %1 == 0 set /a ZT+=1
	 if %1 == 2 set /a ZT+=1
    for %%m in (!XT!) do for %%n in (!YT!) do for %%o in (!ZT!) do (
      set S=!LINE%%o_%%n:~%%m,1!
		if !S!==1 if %1==0 call :COLLISION %4 & goto :eof
		if !S!==1 if %1==1 set GAMEOVER=1& goto :eof
		if !S!==1 if %1==2 set VALID=0& goto :eof
	 )
  )
)
goto :eof

:COLLISION
for /L %%i in (0,1,%NOF%) do (
  set /A XPP=%%i*4,YPP=%%i*4+1,ZPP=%%i*4+2
  for %%a in (!XPP!) do for %%b in (!YPP!) do for %%c in (!ZPP!) do (
    set ZT=!PT:~%%c,1!&set YT=!PT:~%%b,1!&set XT=!PT:~%%a,1!
    set /a XT+=%XP%,YT+=%YP%,ZT+=%1

    for %%m in (!XT!) do for %%n in (!YT!) do for %%o in (!ZT!) do (
      set S=!LINE%%o_%%n!
		set SN=
      for /L %%p in (0,1,4) do (
        if %%p==%%m set SN=!SN!1
        if not %%p==%%m set SN=!SN!!S:~%%p,1!
		)
      set LINE%%o_%%n=!SN!
	 )
  )
)

call :RENDERFILLED
set ZD=0&(for /L %%a in (0,1,%WDB%) do set CL%%a=0)&set /a ADDVAL=10+!SCORE!/200&call :NEXTBLOCK&set /A XP=0,YP=0&for %%a in (!P_I!) do set P=!P%%a!&set PNOF=!P%%aNOF!&call :MKBLOCKS

set SCOREPLUS=0
:CHKLOOP
for /L %%a in (%WD%,-1,0) do set /a ISFULL=1 & for /L %%b in (0,1,%WH%) do (if not !LINE%%a_%%b!==!LINEF! set ISFULL=0) & if !ISFULL!==1 if %%b==%WH% set /A SCORE+=100+!SCOREPLUS!&set /a SCOREPLUS+=400&call :REMOVE %%a& goto CHKLOOP
if !SCORE! gtr !HISCORE! set HISCORE=!SCORE!

if !SCOREPLUS! gtr 0 call :RENDERFILLED
call :ISCOLLIDE 1 0 0 0
goto :eof

:REMOVE
for /L %%a in (%1,-1,0) do set /a MV=%%a-1&for /L %%b in (0,1,%WH%) do for %%c in (!MV!) do set LINE%%a_%%b=!LINE%%c_%%b!
goto :eof

:NEXTBLOCK
set /A P_I=!RANDOM! %% (!NORMBLOCKS!+1)
if !P_I!==!NORMBLOCKS! set /a P_I+=!RANDOM! %% (!ODDBLOCKS!)
goto :eof

:DEBUG
cmdwiz setcursorpos 0 0
for /L %%a in (%WD%,-1,0) do for /L %%b in (0,1,%WH%) do echo z%%a,y%%b !LINE%%a_%%b!&if %%b == %WH% echo.
echo.
cmdwiz getch
