:: Parallax scrolling : Mikael Sollenborn 2016

@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title Parallax hills
if defined __ goto :START
set /a F6W=240/2, F6H=110/2
mode %F6W%,%F6H%
set __=.
cmdgfx_input.exe knW20xR | call %0 %* | cmdgfx_gdi.exe "" Sf0:0,0,240,110
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=240, H=110
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call centerwindow.bat 0 -16

call :MAKE_HILLS
set /a WMAX=W+100, DIR=1, PLXPOS=20, PLYPOS=85, JMP=0, JMPV=0, DWN=0, DWNV=0, SHOWPLY=1, CNT=0

set STOP=
:SHOWLOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set L1=""
	set /a "ADD=DIR*(1+CNT %% 2)"
	for /L %%a in (1,1,!HILLS_L1!) do set /a WL1_%%a-=ADD, CX=!WL1_%%a!& set L1="!L1:~1,-1! & fellipse 2 0 20 !CX!,98,!WLW1b_%%a!,!WLH1_%%a! & fellipse a 0 b1 !CX!,100,!WLW1_%%a!,!WLH1_%%a! & fellipse a 0 db !CX!,120,!WLW1_%%a!,!WLH1_%%a!"& set /a CX+=!WLW1_%%a!*DIR, OUT=0&(if !DIR!==1 if !CX! lss -100 set /a OUT=1, INDEX=%%a-1 & if !INDEX! lss 1 set /a INDEX=HILLS_L1)&(if !DIR!==-1 if !CX! gtr !WMAX! set /a OUT=1, INDEX=%%a+1 & if !INDEX! gtr !HILLS_L1! set INDEX=1) & if !OUT!==1 for %%b in (!INDEX!) do set /a "WL1_%%a=!WL1_%%b! + !RANDOM!*DIR %% 60 + MIN_ADV_L1*DIR, WLW1_%%a=!RANDOM!%%40+30" & set /a "WLW1b_%%a=!WLW1_%%a!+5, WLH1_%%a=!WLW1_%%a!+!RANDOM! %% 37"

	set L2=""
	set /a "ADD=DIR*(1+CNT %% 1)"
	for /L %%a in (1,1,!HILLS_L2!) do set /a WL2_%%a-=ADD, CX=!WL2_%%a!& set L2="!L2:~1,-1! & fellipse 2 0 20 !CX!,99,!WLW2b_%%a!,!WLH2_%%a! & fellipse 2 0 b0 !CX!,100,!WLW2_%%a!,!WLH2_%%a! & fellipse 2 0 db !CX!,110,!WLW2_%%a!,!WLH2_%%a!"& set /a CX+=!WLW2_%%a!*DIR, OUT=0&(if !DIR!==1 if !CX! lss -100 set /a OUT=1, INDEX=%%a-1 & if !INDEX! lss 1 set /a INDEX=HILLS_L2)&(if !DIR!==-1 if !CX! gtr !WMAX! set /a OUT=1, INDEX=%%a+1 & if !INDEX! gtr !HILLS_L2! set INDEX=1) & if !OUT!==1 for %%b in (!INDEX!) do set /a "WL2_%%a=!WL2_%%b! + !RANDOM!*DIR %% 60 + MIN_ADV_L2*DIR, WLW2_%%a=!RANDOM!%%30+20" & set /a "WLW2b_%%a=!WLW2_%%a!+2, WLH2_%%a=!WLW2_%%a!+!RANDOM! %% 19+50"

	set PLY=""& if !SHOWPLY!==1 set /a XFLIP=0 & (if !DIR!==-1 set /a XFLIP=1) & set /a IMG=!CNT! %% 8/4+1 & set PLY="image img\mario!IMG!.gxy 0 0 0 -1 !PLXPOS!,!PLYPOS! !XFLIP!"

	echo "cmdgfx: fbox 1 9 b2 0,0,!W!,10 & fbox 1 9 b1 0,3,!W!,10 & fbox 1 9 b0 0,9,!W!,!H! & !L2:~1,-1! & !L1:~1,-1! & fbox a 0 20 0,95,!W!,50 & fbox a e b2 0,96,!W!,50 & fbox a e b1 0,102,!W!,150 & !PLY:~1,-1!" Ff0:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
		
	if "!RESIZED!"=="1" set /a "W=SCRW*2+2, H=SCRH*2+2, WMAX=W+100" & cmdwiz showcursor 0 & call :MAKE_HILLS

	if !JMP! == 1 set /A PLYPOS-=!JMPV!/32*4&set /A JMPV-=4&if !JMPV! lss -64 set PLYPOS=85&set JMP=0

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY!==27 set STOP=1
	if !KEY!==331 set /a DIR=-1
	if !KEY!==333 set /a DIR=1
	if !KEY!==328 if !JMP!== 0 set /a JMPV=64, JMP=1, DWN=0, DWNV=0
	if !KEY!==32 set /a SHOWPLY=1-!SHOWPLY!
	
	set /a KEY=0, CNT+=1
)
if not defined STOP goto SHOWLOOP

cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
endlocal
goto :eof

:MAKE_HILLS
set /a MIN_ADV_L1=60, HILLS_L1=W/MIN_ADV_L1 + 2, WX=0
for /L %%b in (1,1,%HILLS_L1%) do set /a WL1_%%b=WX, WLW1_%%b=!RANDOM! %% 40+30 & set /a "WLH1_%%b=!WLW1_%%b!+!RANDOM! %% 37, WX+=!RANDOM! %% 60 + MIN_ADV_L1, WLW1b_%%b=!WLW1_%%b!+5"

set /a MIN_ADV_L2=60, HILLS_L2=W/MIN_ADV_L2 + 2, WX=0
for /L %%b in (1,1,%HILLS_L2%) do set /a WL2_%%b=WX, WLW2_%%b=!RANDOM! %% 30+20 & set /a "WLH2_%%b=!WLW2_%%b!+!RANDOM! %% 19+50, WX+=!RANDOM! %% 60 + MIN_ADV_L2, WLW2b_%%b=!WLW2_%%b!+2"
set /a CNT=0
