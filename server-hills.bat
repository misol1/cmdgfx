:: Parallax scrolling : Mikael Sollenborn 2016

@echo off
bg font 0 & cls & cmdwiz showcursor 0
if defined __ goto :START
mode 240,110
set __=.
call %0 %* | cmdgfx_gdi.exe "" SkOW20f0
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
cls & bg font 0
set /a W=240, H=110
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra
del /Q EL.dat >nul 2>nul

call centerwindow.bat 0 -16

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
set /a SHOWPLY=1

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

	set PLY=""& if !SHOWPLY!==1 set XFLIP=0&(if !DIR!==-1 set XFLIP=1)&set /A IMG=!CNT! %% 8/4+1&set PLY="image img\!PLNAME!!IMG!.gxy 0 0 0 -1 !PLXPOS!,!PLYPOS! !XFLIP!"

	echo "cmdgfx: fbox 1 9 b2 0,0,%W%,10 & fbox 1 9 b1 0,3,%W%,10 & fbox 1 9 b0 0,9,%W%,%H% & !L2:~1,-1! & !L1:~1,-1! & fbox a 0 20 0,95,%W%,50 & fbox a e b2 0,96,%W%,50 & fbox a e b1 0,102,%W%,50 & !PLY:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set /A PLYB=!PLYPOS!+16&set /A PLYB2=!PLYPOS!-15+!DWN!*10

	if !JMP! == 1 set /A PLYPOS-=!JMPV!/32*4&set /A JMPV-=4&if !JMPV! lss -64 set PLYPOS=85&set JMP=0

	if !KEY!==27 set STOP=1
	if !KEY!==331 set DIR=-1
	if !KEY!==333 set DIR=1
	if !KEY!==328 if !JMP!== 0 set JMPV=64&set JMP=1&set DWN=0&set DWNV=0&set PLNAME=mario
	if !KEY!==32 set /a SHOWPLY=1-!SHOWPLY!
	set /a KEY=0

	set /A CNT+=1
)
if not defined STOP goto SHOWLOOP

echo "cmdgfx: quit"
endlocal
