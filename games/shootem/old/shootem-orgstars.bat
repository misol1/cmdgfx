:: Shootemup game based on MarioRun : Mikael Sollenborn 2017
@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0
set /a F6W=240/2, F6H=100/2
mode %F6W%,%F6H%
if defined __ goto :START
set __=.
del /Q inputflags.dat >nul 2>nul
cmdgfx_input.exe Am5unxW20 | call %0 %* | cmdgfx_gdi.exe "" Sf0:0,0,240,100
set __=
cmdwiz setfont 6 & cls & cmdwiz showcursor 1 & mode 80,50
mode con rate=31 delay=0
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=240, H=100
mode con rate=0 delay=10000
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set /a HISCORE=0 & if exist hiscore.dat for /F "tokens=*" %%i in (hiscore.dat) do set /a HISCORE=%%i

cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
cmdwiz getwindowbounds w & set WINW=!errorlevel!
cmdwiz getwindowbounds h & set WINH=!errorlevel!
set /a WPX=%SW%/2-%WINW%/2, WPY=%SH%/2-%WINH%/2-20
cmdwiz setwindowpos %WPX% %WPY%

set /a XMID=%W%/2, YMID=%H%/2
set /a TX=0, TX2=-2600
set /a NOF_STARS=60, SDIST=5500
set ASPECT=0.667
set COLS=f 0 db  f 0 db  f 0 db f 0 db  f 0 db f 0 db  7 0 db 7 0 db  7 0 db  7 0 db  7 0 db  7 0 db 7 0 db 7 0 db
set /a FCNT=0
:SETUPLOOP
	set WNAME=starfield%FCNT%.ply
	echo ply>%WNAME%
	echo format ascii 1.0 >>%WNAME%
	set /A NOF_V=%NOF_STARS%
	echo element vertex %NOF_V% >>%WNAME%
	echo element face %NOF_STARS% >>%WNAME%
	echo end_header>>%WNAME%

	for /L %%a in (1,1,%NOF_STARS%) do set /A vx=!RANDOM! %% 240 -120 & set /A vy=!RANDOM! %% 200 -100 & set /A vz=!RANDOM! %% 400-160 & echo !vx! !vy! !vz!>>%WNAME%
	set CNT=0&for /L %%a in (1,1,%NOF_STARS%) do set /A CNT1=!CNT!&set /A CNT+=1& echo 1 !CNT1! >>%WNAME%
	set /A FCNT+=1
if %FCNT% lss 2 goto SETUPLOOP

:OUTERLOOP
set /a PLXPOS=15, PLYPOS=40
set PLNAME=mario

set /a NOF_ENEMIES=8, ENEMY_MUL=100
set /a ENEMY_MINDIST=20, ENEMY_DISTRANGE=60, HITNOF_E1=4, HITNOF_E2=2
set /a EX=(%W%+30)
set /a ENEMY_S=180, ENEMY_S_RANGE=100
for /L %%a in (1,1,%NOF_ENEMIES%) do set /A ENEMY%%aX=!EX!*%ENEMY_MUL%, EX+=%ENEMY_MINDIST% + (!RANDOM! %% %ENEMY_DISTRANGE%)&set /A EY=!RANDOM! %% 3&set /A ENEMY%%aY=!RANDOM! %% 79 + 2&set /A ENEMY%%aS=!ENEMY_S! + !RANDOM! %% %ENEMY_S_RANGE%, E%%aHITS=%HITNOF_E1%, E%%aCOL=0, E%%aCNT=0, ENEMY%%aI=1&(if !EY! geq 1 set /a ENEMY%%aI=2, E%%aHITS=%HITNOF_E2%)
set /a ENEMY_MAXS=450, SPEEDINC=1
set BG=""
set BG="fbox 1 9 b2 0,0,%W%,10 & fbox 1 9 b1 0,3,%W%,10 & fbox 1 9 b0 0,9,%W%,%H% & fbox a 0 20 0,85,%W%,50 & fbox a e b2 0,86,%W%,50 & fbox a e b1 0,92,%W%,50"

set /a NOF_SHOTS=4, SHOT_SPEED=4
for /L %%a in (1,1,%NOF_SHOTS%) do set /A SHOT%%aA=0,SHOT%%aX=0,SHOT%%aY=0

for %%a in (331 333 328 336) do set /a ACTIVE_KEY%%a=0
set /a CNT=0, SCORE=0, ACTIVE_KEY=0
set EV_BASE=&set STOP=&set RESTARTGAME=
:SHOWLOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /A IMG=!CNT! %% 8/4+1 & set PLY="image !PLNAME!!IMG!.gxy 0 0 0 -1 !PLXPOS!,!PLYPOS! 0"

	set NMY=""& for /L %%a in (1,1,!NOF_ENEMIES!) do set /A ENEMY%%aX-=!ENEMY%%aS!&set /A EX%%a=!ENEMY%%aX!/%ENEMY_MUL%, E%%aCNT-=1&(if !E%%aCNT! lss 0 set E%%aCOL=0)&set NMY="!NMY:~1,-1! image e!ENEMY%%aI!_!IMG!.gxy 0 !E%%aCOL! 0 -1 !EX%%a!,!ENEMY%%aY! 1 & "&if !EX%%a! lss -30 set /A EY=!RANDOM! %% 3&set /A "ENEMY%%aY=!RANDOM! %% 79 + 2"&set /A ENEMY%%aS=!ENEMY_S! + !RANDOM! %% %ENEMY_S_RANGE%, E%%aHITS=%HITNOF_E1%, ENEMY%%aI=1&(if !EY! geq 1 set /a ENEMY%%aI=2,E%%aHITS=%HITNOF_E2%)&set /A ENEMY_S+=%SPEEDINC%&(if !ENEMY_S! geq !ENEMY_MAXS! set ENEMY_S=!ENEMY_MAXS!)&set /A TMP=%%a+!NOF_ENEMIES!-1&(if !TMP! gtr !NOF_ENEMIES! set /A TMP=!TMP!-!NOF_ENEMIES!)&for %%b in (!TMP!) do set /A EXDIST=!ENEMY%%bX!/%ENEMY_MUL%&set PL=0&set /A DIFF=%W%+30-!EXDIST!&(if !DIFF! lss !ENEMY_MINDIST! set /A PL=!ENEMY_MINDIST!-!DIFF!)&set /A "ENEMY%%aX=((%W%+30)+!PL!+!RANDOM! %% !ENEMY_DISTRANGE!) * %ENEMY_MUL%"&set /A EX%%a=9999999

	set SHOTS=""& for /L %%a in (1,1,!NOF_SHOTS!) do if !SHOT%%aA! == 1 set /a SHOT%%aX+=!SHOT_SPEED!&set SHOTS="!SHOTS:~1,-1! fellipse f 0 db !SHOT%%aX!,!SHOT%%aY!,5,3 & "&if !SHOT%%aX! gtr 260 set /a SHOT%%aA=0	
	
	echo "cmdgfx: fbox 0 0 20 0,0,%W%,%H% & %BG:~1,-1% & 3d starfield0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,%ASPECT% !COLS! & 3d starfield1.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,%ASPECT% !COLS! & !PLY:~1,-1! & !NMY:~1,-1! & !SHOTS:~1,-1! & text 7 1 0 SCORE:_!SCORE!_(!HISCORE!) 2,1"

	set /A PLXB=!PLXPOS!+18, PLXB2=!PLXPOS!-19
	set /A PLYB=!PLYPOS!+16, PLYB2=!PLYPOS!-15
	for /L %%a in (1,1,!NOF_ENEMIES!) do if !EX%%a! lss !PLXB! if !EX%%a! gtr !PLXB2! if !ENEMY%%aY! lss !PLYB! if !ENEMY%%aY! gtr !PLYB2! call :GAMEOVER & set /a STOP=1&if !GAMECHOICE! == 0 set /a RESTARTGAME=1

	for /L %%b in (1,1,%NOF_SHOTS%) do if !SHOT%%bA! == 1 for /L %%a in (1,1,!NOF_ENEMIES!) do if !SHOT%%bA! == 1 set /a "EXR=!EX%%a!+26, EYR=!ENEMY%%aY!+18" & if !SHOT%%bX! gtr !EX%%a! if !SHOT%%bX! lss !EXR! if !SHOT%%bY! gtr !ENEMY%%aY! if !SHOT%%bY! lss !EYR! set /a "SHOT%%bA=0, E%%aHITS-=1, E%%aCNT=5" & (if !E%%aHITS! leq 0 set /a "ENEMY%%aX=-99999, SCORE+=1")& set E%%aCOL=-f &if !SCORE! gtr !HISCORE! set /a HISCORE=!SCORE!
	
	set STOPCHK=
	for /L %%2 in (1,1,8) do if not defined STOPCHK (
		set /p INPUT=
		for /f "tokens=1,2,4,6" %%A in ("!INPUT!") do ( set EV_BASE=%%A& set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )

		if "!EV_BASE!"=="END_EVENTS" set /a STOPCHK=1
		
		if !K_DOWN! == 1 (
			for %%a in (331 333 328 336) do if !KEY! == %%a set /a ACTIVE_KEY%%a=1
			
			if !KEY! == 32 set /a SHLEFT=1 & for /L %%a in (1,1,%NOF_SHOTS%) do if !SHLEFT!==1 if !SHOT%%aA!==0 set /a SHLEFT=0,SHOT%%aA=1,SHOT%%aX=!PLXPOS!+14,SHOT%%aY=!PLYPOS!+10

			if !KEY! == 27 set STOP=1
		)
		if !K_DOWN! == 0 (
			for %%a in (331 333 328 336) do if !KEY! == %%a set /a ACTIVE_KEY%%a=0
		)
	)
	if !ACTIVE_KEY328!==1 set /a PLYPOS-=2 & if !PLYPOS! lss 3 set /a PLYPOS=3
	if !ACTIVE_KEY336!==1 set /a PLYPOS+=2 & if !PLYPOS! gtr 77 set /a PLYPOS=77
	if !ACTIVE_KEY331!==1 set /a PLXPOS-=2 & if !PLXPOS! lss 15 set /a PLXPOS=15
	if !ACTIVE_KEY333!==1 set /a PLXPOS+=2 & if !PLXPOS! gtr 150 set /a PLXPOS=150

	set /A TX-=12 & if !TX! lss -2600 set TX=2600
	set /A TX2-=12 & if !TX2! lss -2600 set TX2=2600
	set /A CNT+=1
)
if not defined STOP goto SHOWLOOP
if defined RESTARTGAME goto OUTERLOOP

echo "cmdgfx: quit"
echo Q>inputflags.dat
echo %HISCORE% >hiscore.dat
endlocal
del /Q starfield?.ply
goto :eof

:GAMEOVER
set /a GAMECHOICE=0
echo "cmdgfx: text c 0 0 .-----------------------.\n|_______________________|\n|\e0___G_A_M_E___O_V_E_R___\c0|\n|_______________________|\n|\d0____ENTER_TO_RESTART___\c0|\n|_______________________|\n|\80_____ESCAPE_TO_QUIT____\c0|\n|_______________________|\n_-----------------------_ 105,29"
cmdwiz getch
if not !ERRORLEVEL!==13 if not !ERRORLEVEL!==27 goto GAMEOVER
if !ERRORLEVEL!==27 set GAMECHOICE=1
goto :eof
