:: Parallax scrolling jumping game : Mikael Sollenborn 2016-17

@echo off
if defined __ goto :START
cls & cmdwiz showcursor 0
set __=.
call %0 %* | cmdgfx_gdi.exe "" SkOW20f0:0,0,240,110
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & bg font 6
set /a W=240, H=110
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
mode con rate=31 delay=0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set HISCORE=0&if exist hiscore.dat for /F "tokens=*" %%i in (hiscore.dat) do set /A HISCORE=%%i

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

:OUTERLOOP
set MIN_ADV_L1=60
set /A HILLS_L1=%W%/%MIN_ADV_L1% + 2
set /A WX=0
for /L %%b in (1,1,%HILLS_L1%) do set WL1_%%b=!WX!&set /A WLW1_%%b=!RANDOM!%%40+30&set /A WLH1_%%b=!WLW1_%%b!+!RANDOM!%%37&set /A WX+=!RANDOM! %% 60 + %MIN_ADV_L1%&set /A WLW1b_%%b=!WLW1_%%b!+5

set MIN_ADV_L2=60
set /A HILLS_L2=%W%/%MIN_ADV_L2% + 2
set /A WX=0
for /L %%b in (1,1,%HILLS_L2%) do set WL2_%%b=!WX!&set /A WLW2_%%b=!RANDOM!%%30+20&set /A WLH2_%%b=!WLW2_%%b!+!RANDOM!%%19+50&set /A WX+=!RANDOM! %% 60 + %MIN_ADV_L2%&set /A WLW2b_%%b=!WLW2_%%b!+2

set /A WMAX=%W%+100
set DIR=1
set PLXPOS=20
set /A PLXB=%PLXPOS%+18
set /A PLXB2=%PLXPOS%-19
set PLYPOS=85
set JMP=0&set JMPV=0
set DWN=0&set DWNV=0
set PLNAME=mario

set NOF_ENEMIES=3
set ENEMY_MUL=100
set ENEMY_MINDIST=60
set ENEMY_DISTRANGE=100
set /A EX=(%W%+30)
for /L %%a in (1,1,%NOF_ENEMIES%) do set /A ENEMY%%aX=!EX!*%ENEMY_MUL%&set /A EX+=%ENEMY_MINDIST% + (!RANDOM! %% %ENEMY_DISTRANGE%)&set /A EY=!RANDOM! %% 3&set /A ENEMY%%aY=88-(!EY! * 14)&set ENEMY%%aI=1&(if !EY! geq 1 set ENEMY%%aI=2)
set ENEMY_S=80
set ENEMY_SD=100
set ENEMY_MAXS=450
set SCORE=0

set CNT=0
set STOP=&set RESTARTGAME=
:SHOWLOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set L1=""
	set /A "ADD=!DIR!*(1+!CNT! %% 2)"
	for /L %%a in (1,1,%HILLS_L1%) do set /A WL1_%%a-=!ADD! & set CX=!WL1_%%a!& set L1="!L1:~1,-1! & fellipse 2 0 20 !CX!,98,!WLW1b_%%a!,!WLH1_%%a! & fellipse a 0 b1 !CX!,100,!WLW1_%%a!,!WLH1_%%a! & fellipse a 0 db !CX!,120,!WLW1_%%a!,!WLH1_%%a!"& set /A CX+=!WLW1_%%a!*!DIR! & set OUT=0&(if !DIR!==1 if !CX! lss -100 set OUT=1&set /A INDEX=%%a-1&if !INDEX! lss 1 set INDEX=%HILLS_L1%)&(if !DIR!==-1 if !CX! gtr %WMAX% set OUT=1&set /A INDEX=%%a+1&if !INDEX! gtr %HILLS_L1% set INDEX=1)&if !OUT!==1 for %%b in (!INDEX!) do set /A "WL1_%%a=!WL1_%%b! + !RANDOM!*!DIR! %% 60 + !MIN_ADV_L1!*!DIR!"&set /A "WLW1_%%a=!RANDOM!%%40+30"&set /A "WLW1b_%%a=!WLW1_%%a!+5"&set /A "WLH1_%%a=!WLW1_%%a! + !RANDOM! %% 37"

	set L2=""
	set /A "ADD=!DIR!*(1+!CNT! %% 1)"
	for /L %%a in (1,1,%HILLS_L2%) do set /A WL2_%%a-=!ADD! & set CX=!WL2_%%a!& set L2="!L2:~1,-1! & fellipse 2 0 20 !CX!,99,!WLW2b_%%a!,!WLH2_%%a! & fellipse 2 0 b0 !CX!,100,!WLW2_%%a!,!WLH2_%%a! & fellipse 2 0 db !CX!,110,!WLW2_%%a!,!WLH2_%%a!"& set /A CX+=!WLW2_%%a!*!DIR!& set OUT=0&(if !DIR!==1 if !CX! lss -100 set OUT=1&set /A INDEX=%%a-1&if !INDEX! lss 1 set INDEX=%HILLS_L2%)&(if !DIR!==-1 if !CX! gtr %WMAX% set OUT=1&set /A INDEX=%%a+1&if !INDEX! gtr %HILLS_L2% set INDEX=1)&if !OUT!==1 for %%b in (!INDEX!) do set /A "WL2_%%a=!WL2_%%b! + !RANDOM!*!DIR! %% 60 + !MIN_ADV_L2!*!DIR!"&set /A "WLW2_%%a=!RANDOM!%%30+20"&set /A "WLW2b_%%a=!WLW2_%%a!+2"&set /A "WLH2_%%a=!WLW2_%%a! + !RANDOM! %% 19 + 50"

	set PLY="" & set XFLIP=0&(if !DIR!==-1 set XFLIP=1)&set /A IMG=!CNT! %% 8/4+1&set PLY="image !PLNAME!!IMG!.gxy 0 0 0 -1 !PLXPOS!,!PLYPOS! !XFLIP!"

	set NMY=""& for /L %%a in (1,1,!NOF_ENEMIES!) do set /A ENEMY%%aX-=!ENEMY_S! + !ENEMY_SD!*!DIR!&set /A EX%%a=!ENEMY%%aX!/%ENEMY_MUL%&set NMY="!NMY:~1,-1! image e!ENEMY%%aI!_!IMG!.gxy 0 0 0 -1 !EX%%a!,!ENEMY%%aY! 1 & "&if !EX%%a! lss -30 set /A EY=!RANDOM! %% 3&set /A "ENEMY%%aY=88-(!EY! * 14)"&set ENEMY%%aI=1&(if !EY! geq 1 set ENEMY%%aI=2)&(if !DIR!==1 set /A SCORE+=1)&(if !SCORE! gtr !HISCORE! set HISCORE=!SCORE!)&set /A ENEMY_S+=2&(if !ENEMY_S! geq !ENEMY_MAXS! set ENEMY_S=!ENEMY_MAXS!)&set /A TMP=%%a+!NOF_ENEMIES!-1&(if !TMP! gtr !NOF_ENEMIES! set /A TMP=!TMP!-!NOF_ENEMIES!)&for %%b in (!TMP!) do set /A EXTEMP=!ENEMY%%bX!/%ENEMY_MUL%&set PL=0&set /A DIFF=%W%+30-!EXTEMP!&(if !DIFF! lss !ENEMY_MINDIST! set /A PL=!ENEMY_MINDIST!-!DIFF!)&set /A "ENEMY%%aX=((%W%+30)+!PL!+!RANDOM! %% !ENEMY_DISTRANGE!) * %ENEMY_MUL%"

	echo "cmdgfx: fbox 1 9 b2 0,0,%W%,10 & fbox 1 9 b1 0,3,%W%,10 & fbox 1 9 b0 0,9,%W%,%H% & !L2:~1,-1! & !L1:~1,-1! & fbox a 0 20 0,95,%W%,50 & fbox a e b2 0,96,%W%,50 & fbox a e b1 0,102,%W%,50 & !PLY:~1,-1! & !NMY:~1,-1! &  text 7 1 0 SCORE:_!SCORE!_(!HISCORE!) 2,1 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set /A PLYB=!PLYPOS!+16&set /A PLYB2=!PLYPOS!-15+!DWN!*10
	for /L %%a in (1,1,!NOF_ENEMIES!) do if !EX%%a! lss !PLXB! if !EX%%a! gtr !PLXB2! if !ENEMY%%aY! lss !PLYB! if !ENEMY%%aY! gtr !PLYB2! call :GAMEOVER & set /a STOP=1&if !GAMECHOICE! == 0 set /a RESTARTGAME=1

	if !DWN! == 1 set /A DWNV-=1&if !DWNV! lss 0 set DWN=0&set PLNAME=mario
	if !JMP! == 1 set /A PLYPOS-=!JMPV!/32*4&set /A JMPV-=4&if !JMPV! lss -64 set PLYPOS=85&set JMP=0

	if !KEY!==27 set STOP=1
	if !KEY!==331 set DIR=-1
	if !KEY!==333 set DIR=1
	if !KEY!==328 if !JMP!== 0 set JMPV=64&set JMP=1&set DWN=0&set DWNV=0&set PLNAME=mario
	if !KEY!==32 if !JMP!== 0 set JMPV=64&set JMP=1&set DWN=0&set DWNV=0&set PLNAME=mario
	if !KEY!==336 if !JMP!== 0 if !DWNV! lss 4 set /A DWNV=24 - !ENEMY_S!/47&set DWN=1&set PLNAME=mariosmall
	set /a KEY=0

	set /A ENEMY_MINDIST=60 + !ENEMY_S!/15
	set /A ENEMY_DISTRANGE=100 - !ENEMY_S!/15

	set /A CNT+=1
)
if not defined STOP goto SHOWLOOP
if defined RESTARTGAME goto OUTERLOOP

echo "cmdgfx: quit"
echo %HISCORE% >hiscore.dat
endlocal
mode 80,50
cls & bg font 6
goto :eof

:GAMEOVER
set GAMECHOICE=0
echo "cmdgfx: text c 0 0 .-----------------------.\n|_______________________|\n|\e0___G_A_M_E___O_V_E_R___\c0|\n|_______________________|\n|\d0____SPACE_TO_RESTART___\c0|\n|_______________________|\n|\80_____ESCAPE_TO_QUIT____\c0|\n|_______________________|\n_-----------------------_ 105,29"
cmdwiz getch
if not !ERRORLEVEL!==32 if not !ERRORLEVEL!==27 goto GAMEOVER
if !ERRORLEVEL!==27 set GAMECHOICE=1
goto :eof
