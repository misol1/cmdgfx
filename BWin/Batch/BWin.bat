@echo off
cd "%~dp0"
rem if not "%~1"=="" if not defined __ mode 60,30 & tasklist /FI "IMAGENAME eq cmdgfx_gdi.exe" | find "cmdgfx_gdi.exe" >nul 2>nul
if not "%~1"=="" if not defined __ mode 60,30 & tasklist /FI "WINDOWTITLE eq BWin misol GUI 101" | find "cmd.exe" >nul 2>nul
if "%errorlevel%"=="0" if not "%~1"=="" if not defined __ call :PROCESS_NEWDROP %* & goto :eof
set /a W=120, H=75, WPAGES=3, WWW=W*WPAGES, HH=H*2, FONT=2, MAXTW=256, MAXTH=256
cmdwiz setfont %FONT% & mode %W%,%H% & cls & cmdwiz showcursor 0
if defined __ goto :START
cmdwiz getquickedit
set /a QE=%errorlevel%
cmdwiz setquickedit 0
set __=.
cmdgfx_input M30nxW30R | call %0 %* | cmdgfx_gdi "" Sf%FONT%:0,0,%WWW%,%HH%,%W%,%H%G%MAXTW%,%MAXTH%N250
set __=
cmdwiz setquickedit %QE%
set QE=&set W=&set H=&set WWW=&set HH=&set FONT=&set WPAGES=&set MAXTW=&set MAXTH=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
title BWin misol GUI 101
for %%i in (mode.com) do set MODECMD=%%~$PATH:i
for /F "tokens=1 delims==" %%v in ('set') do if /I not "%%v"=="W" if /I not "%%v"=="WWW" if /I not "%%v"=="H" if /I not "%%v"=="HH" if /I not "%%v"=="WPAGES" if /I not "%%v"=="FONT" if /I not "%%v"=="MAXTW" if /I not "%%v"=="MAXTH" if /I not "%%v"=="MODECMD" if /I not "%%v"=="SystemRoot"  if /I not "%%v"=="SystemDrive" set "%%v="
if exist centerwindow.bat call centerwindow.bat 0 -20

if exist NewDrop rd /S /Q NewDrop >nul 2>nul

set /a "MID_OFF_X=W+(WWW-W)/2"
set /a MID_OFF_Y=%H%, SEL_WIN=0, DRAG_MODE=0, WM=W-1, HM=H-1, KEY=0
set /a BORDER_TEXT_XP=5, BORDER_CLOSE_XP=5
set BKG=3 0 fa
set BORDER_COL=7 0
set TITLE_COL=7 0
set FOCUS_COL=f 0
set RESIZE_COL=f 0
set CLOSE_COL=7 0
set MAX_COL=7 0
set CLEAR_COL=0 0 20
set TEXT_COL=b 0
set SS0=skip& set SS1=
set PAL3D=f b b2 f b b2 f b b1 f b b0 b 0 db b 7 b2 b 7 b1 7 0 db 9 7 b1 9 7 b2 9 0 db 9 1 b1 9 1 b0 1 0 db 1 0 b2 1 0 b1 0 0 db
set IGNORE_SIZE=0

set /a NOF_WIN=3

if not "%~1"=="" set /a NOF_WIN=0 & call :PROCESS_NEWDROP %* & goto :SKIP_DEFINE_WINDOWS

:: WINDOW DEFINITIONS

set W1_NAME="Animation"
set /a W1_W=50, W1_H=40
set /a W1_X=7, W1_Y=28
set /a W1_XA=0, W1_YA=0
set /a W1_ACTIVE=1, W1_CLOSE=1, W1_SIZE=1, W1_CLEAR=1, W1_SCROLL=0, W1_MAXED=0, W1_EXP=0, W1_KB=0
set W1_INIT="set /a IMGI=0"
set W1_UPDATE="set /a IMGI=(IMGI+1) %% 20, REPL1=IMGI/2"
set W1_CONTENT="image img\spiral\REPL1.txt 8 0 # -1 OFF_X,OFF_Y 0 0 OFF_W,OFF_H"

set W2_NAME="Test Image"
set /a W2_W=40, W2_H=30
set /a W2_X=71, W2_Y=6
set /a W2_XA=1, W2_YA=1
set /a W2_ACTIVE=1, W2_CLOSE=1, W2_SIZE=1, W2_CLEAR=1, W2_SCROLL=0, W2_EXP=0, W2_KB=0
set W2_INIT=""
set W2_UPDATE=""
set W2_CONTENT="image img\apa.gxy 0 0 0 -1 OFF_X,OFF_Y 0 0 OFF_W,OFF_H"

set W3_NAME="centerwindow.bat"
set /a W3_W=52, W3_H=16
set /a W3_X=63, W3_Y=55
set /a W3_XA=1, W3_YA=1
set /a W3_ACTIVE=1, W3_CLOSE=1, W3_SIZE=0, W3_CLEAR=1, W3_SCROLL=1, W3_EXP=0, W3_KB=0
set W3_INIT=""
set W3_UPDATE=""
set W3_CONTENT="image centerwindow.bat \b 0 0 -1 OFF_X,OFF_Y"

set W4_NAME="Plasma"
set /a W4_W=50, W4_H=35
set /a W4_X=10, W4_Y=4
set /a W4_XA=1, W4_YA=1
set /a W4_ACTIVE=1, W4_CLOSE=1, W4_SIZE=1, W4_CLEAR=1, W4_SCROLL=0, W4_EXP=0, W4_KB=0
set W4_INIT="set /a A1=0, A2=0"
set W4_UPDATE="set /a A1+=(A1+1) %% 20, A2+=(A2+3) %% 50, REPL1=A1, REPL2=A2"
set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
set W4_CONTENT="block 0 OFF_X,OFF_Y,OFF_W,OFF_H OFF_X,OFF_Y -1 0 0 !STREAM:~1,-1! random()*1.5+sin((x-REPL1/4)/80)*(y/2)+cos((y+REPL2/5)/35)*(x/3)"
set STREAM=

set W5_NAME="Doom"
set /a W5_W=50, W5_H=40
set /a W5_X=29, W5_Y=12
set /a W5_XA=0, W5_YA=-1
set /a W5_ACTIVE=1, W5_CLOSE=1, W5_SIZE=1, W5_CLEAR=1, W5_SCROLL=0, W5_EXP=0, W5_KB=0
set W5_INIT="set /a IMGI2=0"
set W5_UPDATE="set /a IMGI2=(IMGI2+1) %% 20, REPL1=IMGI2/10"
set W5_CONTENT="image img\uglyREPL1.pcx 0 0 # 14 OFF_X,OFF_Y 0 0 OFF_W,OFF_H"

set W6_NAME="3d Object"
set /a W6_W=50, W6_H=40
set /a W6_X=65, W6_Y=33
set /a W6_XA=0, W6_YA=0
set /a W6_ACTIVE=1, W6_CLOSE=1, W6_SIZE=1, W6_CLEAR=1, W6_SCROLL=0, W6_EXP=0, W6_KB=0
set W6_INIT="set /a RY=0"
set W6_UPDATE="set /a RY+=22, REPL1=RY, REPL2=MID_OFF_X, REPL3=MID_OFF_Y, REPL4=12000-(OFF_W*35)"
set W6_CONTENT="3d objects\shark.ply 2,1 REPL1,REPL1,0 0,0,0 2,2,2,0,0,0 0,0,0,0 REPL2,REPL3,REPL4,1 PAL3D"

set W7_NAME="Scroll"
set /a W7_W=35, W7_H=3
set /a W7_X=11, W7_Y=69
set /a W7_XA=1, W7_YA=1
set /a W7_ACTIVE=1, W7_CLOSE=1, W7_SIZE=0, W7_CLEAR=1, W7_SCROLL=0, W7_EXP=0, W7_KB=0
set W7_INIT="set /a SCROLLI=0"
set W7_UPDATE="set /a SCROLLI=(SCROLLI+1) %% 230, REPL1=OFF_X - SCROLLI / 3"
set W7_CONTENT="text a 0 0 ______________________________________Scrolling_without_\e0block\r_operation...____________________________________ REPL1,OFF_Y"

set W8_NAME="Time"
set /a W8_W=25, W8_H=5
set /a W8_X=1, W8_Y=1
set /a W8_XA=3, W8_YA=2
set /a W8_ACTIVE=1, W8_CLOSE=1, W8_SIZE=0, W8_CLEAR=1, W8_SCROLL=0, W8_EXP=2, W8_KB=0
set W8_INIT=""
set W8_UPDATE="set /a REPL1=OFF_X+12"
set W8_CONTENT="text b 0 0 ^!DATE^! OFF_X,OFF_Y & text f 0 0 ^!TIME:~0,8^! REPL1,OFF_Y"

:: END WINDOW DEFINITIONS

:SKIP_DEFINE_WINDOWS

for /l %%a in (1,1,!NOF_WIN!) do if not "!W%%a_MAXED!"=="1" ( set /a W%%a_MAXED=0 ) else ( set /a W%%a_XO=!W%%a_X!,W%%a_YO=!W%%a_Y!,W%%a_WO=!W%%a_W!,W%%a_HO=!W%%a_H!,W%%a_X=0, W%%a_Y=0,W%%a_W=!W!,W%%a_H=!H!,W%%a_WM=!W!-1,W%%a_HM=!H!-1,W%%a_MAXED=1 )

for /l %%a in (1,1,!NOF_WIN!) do set /a W%%a_WM=!W%%a_W!-1, W%%a_HM=!W%%a_H!-1,LAY%%a=%%a & cmdwiz stringlen !W%%a_NAME! & set /a W%%a_WMIN = !errorlevel! + 16 & set DOCMD=!W%%a_INIT:~1,-1!& (if "!DOCMD!"=="" set DOCMD=rem) & call :DOCMD
set /a CLEANWIN=!NOF_WIN!+1
for /l %%a in (%CLEANWIN%,1,50) do set W%%a_NAME=&set W%%a_INIT=&set W%%a_UPDATE=&set W%%a_CONTENT=&set W%%a_X=&set W%%a_Y=&set W%%a_W=&set W%%a_H=&set W%%a_XA=&set W%%a_YA=&set W%%a_ACTIVE=&set W%%a_CLOSE=&set W%%a_SIZE=&set W%%a_CLEAR=&set W%%a_MAXED=&set W%%a_SCROLL=&set W%%a_EXP=&set W%%a_KB=&set CLEANWIN=

:: Set window as topmost
rem cmdwiz setwindowpos k k topmost

:LOOP
for /L %%1 in (1,1,100) do if not defined STOP (
	set WINSTR=""
	if !NOF_WIN! gtr 0 for %%a in (!NOF_WIN!) do set /a FOCUSWIN=!LAY%%a!
	for /l %%z in (1,1,!NOF_WIN!) do (
		for %%a in (!LAY%%z!) do (
			if !W%%a_ACTIVE! == 1 (
				if !W%%a_MAXED!==1 set /a W%%a_W=W,W%%a_H=H,W%%a_WM=W-1,W%%a_HM=H-1
				set /a "E1=!W%%a_EXP! & 1, E2=(!W%%a_EXP! & 2)>>1, E4=(!W%%a_EXP! & 4)>>2" & if !E4!==1 set /a E1=-1
				
				set /a REPL1=0, REPL2=0, REPL3=0, REPL4=0
				set /a "DRAW_X=MID_OFF_X-!W%%a_W!/2, DRAW_Y=MID_OFF_Y-!W%%a_H!/2"
				set /a OFF_X=DRAW_X+!W%%a_XA!, OFF_Y=DRAW_Y+!W%%a_YA!, OFF_W=!W%%a_W!, OFF_H=!W%%a_H!
				if !E1!==0 set DOCMD=!W%%a_UPDATE:~1,-1!& (if "!DOCMD!"=="" set DOCMD=rem) & !DOCMD!
				if !E1!==1 set DOCMD=!W%%a_UPDATE!& (if !DOCMD!=="" set DOCMD="rem") & for %%s in (!W%%a_UPDATE!) do %%~s
				if !E4!==1 set DOCMD=!W%%a_UPDATE:~1,-1!& (if "!DOCMD!"=="" set DOCMD=rem) & call :DOCMD
				set /a SIZE=!W%%a_SIZE! & if !W%%a_MAXED!==1 set /a SIZE=0
				for %%x in (!DRAW_X!) do for %%y in (!DRAW_Y!) do for %%w in (!W%%a_W!) do for %%h in (!W%%a_H!) do (
					set CONTENT=!W%%a_CONTENT!
					for %%i in (!OFF_X!) do set CONTENT=!CONTENT:OFF_X=%%i!
					for %%i in (!OFF_Y!) do set CONTENT=!CONTENT:OFF_Y=%%i!
					set CONTENT=!CONTENT:OFF_W=%%w!
					set CONTENT=!CONTENT:OFF_H=%%h!
					for %%r in ("!REPL1!") do set CONTENT=!CONTENT:REPL1=%%~r!
					for %%r in ("!REPL2!") do set CONTENT=!CONTENT:REPL2=%%~r!
					for %%r in ("!REPL3!") do set CONTENT=!CONTENT:REPL3=%%~r!
					for %%r in ("!REPL4!") do set CONTENT=!CONTENT:REPL4=%%~r!
					set CONTENT=!CONTENT:PAL3D=%PAL3D%!
					set /a TEXTPOS=%%x + BORDER_TEXT_XP, CLOSEPOS=%%x + !W%%a_WM! - BORDER_CLOSE_XP, BORDER_RIGHT_X=%%x + !W%%a_WM!, BORDER_BOTTOM_Y=%%y + !W%%a_HM!, MAXPOS=CLOSEPOS-2
					set NAME=!W%%a_NAME: =_!
					set TCOL=!TITLE_COL! & if %%z == !NOF_WIN! set TCOL=!FOCUS_COL!
					for %%s in (!SIZE!) do for %%t in (!W%%a_SIZE!) do for %%q in (!W%%a_CLOSE!) do for %%c in (!W%%a_CLEAR!) do set BOX="box !BORDER_COL! cd %%x,%%y,!W%%a_WM!,!W%%a_HM! & box !BORDER_COL! ba %%x,%%y,0,!W%%a_HM! & box !BORDER_COL! ba !BORDER_RIGHT_X!,%%y,0,!W%%a_HM! & text !TCOL! 0 _!NAME:~1,-1!_ !TEXTPOS!,%%y & !SS%%q! text !CLOSE_COL! 0 _X_ !CLOSEPOS!,%%y & !SS%%t! text !MAX_COL! 0 _\gf2_ !MAXPOS!,%%y  & pixel !BORDER_COL! c9 %%x,%%y & pixel !BORDER_COL! bb !BORDER_RIGHT_X!,%%y & pixel !BORDER_COL! c8 %%x,!BORDER_BOTTOM_Y! & pixel !BORDER_COL! bc !BORDER_RIGHT_X!,!BORDER_BOTTOM_Y! & !SS%%s! pixel !RESIZE_COL! fe !BORDER_RIGHT_X!,!BORDER_BOTTOM_Y!"
					if !E2! == 0 set WINSTR="!WINSTR:~1,-1! & !SS%%c! fbox !CLEAR_COL! !DRAW_X!,!DRAW_Y!,%%w,%%h & !CONTENT:~1,-1! & !BOX:~1,-1! & block 0 %%x,%%y,!W%%a_W!,!W%%a_H! !W%%a_X!,!W%%a_Y!"
					if !E2! == 1 for %%s in (!CONTENT!) do set WINSTR="!WINSTR:~1,-1! & !SS%%c! fbox !CLEAR_COL! !DRAW_X!,!DRAW_Y!,%%w,%%h & %%~s & !BOX:~1,-1! & block 0 %%x,%%y,!W%%a_W!,!W%%a_H! !W%%a_X!,!W%%a_Y!"
				)
			)
		)
	)

	for %%i in (!W!) do set TBKG=!BKG:OFF_W=%%i!
	for %%i in (!H!) do set TBKG=!TBKG:OFF_H=%%i!
	for %%s in ("!TBKG!") do echo "cmdgfx: fbox %%~s & !WINSTR:~1,-1!" F
	set WINSTR=&set TBKG=&set BOX=&set CONTENT=&set DRAW_X=&set DRAW_Y=&set DOCMD=&set TCOL=&set REPL1=&set REPL2=&set REPL3=&set REPL4=
	set NAME=&set TEXTPOS=&set CLOSEPOS=&set BORDER_RIGHT_X=&set BORDER_BOTTOM_Y=&set MAXPOS=&set OFF_X=&set OFF_Y=&set OFF_W=&set OFF_H=
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22,24,26,28" %%A in ("!INPUT!") do ( set /a KEY=%%D, M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_WHEEL=%%L, SIZE_EVENT=%%M, SIZE_W=%%N, SIZE_H=%%O 2>nul ) 
	set INPUT=
	
	if !M_EVENT!==1 (
		if !M_LB!==1 (
			if !SEL_WIN! == 0 (
				set /a SEL_WIN=-1, SEL_INDEX=-1, CLOSE_WIN=-1, MAX_WIN=-1
				for /l %%z in (1,1,!NOF_WIN!) do (
					for %%a in (!LAY%%z!) do (
						if !W%%a_ACTIVE! == 1 (
							set /a BORDER_RIGHT_X=!W%%a_X!+!W%%a_WM!, BORDER_BOTTOM_Y=!W%%a_Y!+!W%%a_HM!
							set /a CLOSEPOS=!W%%a_X!+!W%%a_WM!-BORDER_CLOSE_XP+1, MAXPOS=CLOSEPOS-2
							if !M_X! geq !W%%a_X! if !M_Y! geq !W%%a_Y! if !M_X! leq !BORDER_RIGHT_X! if !M_Y! leq !BORDER_BOTTOM_Y! set /a SEL_WIN=%%a, SEL_INDEX=%%z & set /a DRAG_MODE=1-!W%%a_MAXED!
							if !W%%a_CLOSE! == 1 if !M_X! == !CLOSEPOS! if !M_Y! == !W%%a_Y! set /a SEL_WIN=-1, CLOSE_WIN=%%a
							if !W%%a_SIZE! == 1 if !W%%a_MAXED!==0 if !M_X! == !BORDER_RIGHT_X! if !M_Y! == !BORDER_BOTTOM_Y! set /a SEL_WIN=%%a, SEL_INDEX=%%z & set /a DRAG_MODE=0 & if !W%%a_MAXED!==0 set /a DRAG_MODE=2
							if !W%%a_SIZE! == 1 if !M_X! == !MAXPOS! if !M_Y! == !W%%a_Y! set /a SEL_WIN=%%a, SEL_INDEX=%%z, DRAG_MODE=0, MAX_WIN=%%a
						)
					)
				)
				if !SEL_WIN! gtr 0 for %%a in (!SEL_WIN!) do (
					set /a ORGMX=M_X, ORGMY=M_Y, ORGWX=!W%%a_X!, ORGWY=!W%%a_Y!, ORGWW=!W%%a_W!, ORGWH=!W%%a_H!
					if not !SEL_INDEX! == !NOF_WIN! (
						set /a STARTI=SEL_INDEX+1
						for /l %%i in ( !STARTI!,1,!NOF_WIN! ) do set /a CI=%%i-1 & for %%j in (!CI!) do set /a LAY%%j=!LAY%%i!
						set /a LAY!NOF_WIN!=SEL_WIN
					)
				)
				if !CLOSE_WIN! gtr 0 for %%a in (!CLOSE_WIN!) do set /a W%%a_ACTIVE=0 & for %%b in (!NOF_WIN!) do if %%a==!LAY%%b! call :TAB 1

				if !MAX_WIN! gtr 0 for %%a in (!MAX_WIN!) do if !W%%a_MAXED!==0 ( set /a W%%a_XO=!W%%a_X!,W%%a_YO=!W%%a_Y!,W%%a_WO=!W%%a_W!,W%%a_HO=!W%%a_H!,W%%a_X=0, W%%a_Y=0,W%%a_W=W,W%%a_H=H,W%%a_WM=W-1,W%%a_HM=H-1,W%%a_MAXED=1) else (set /a W%%a_X=!W%%a_XO!,W%%a_Y=!W%%a_YO!,W%%a_W=!W%%a_WO!,W%%a_H=!W%%a_HO!,W%%a_WM=!W%%a_WO!-1,W%%a_HM=!W%%a_HO!-1,W%%a_MAXED=0 & set W%%a_XO=&set W%%a_YO=&set W%%a_WO=&set W%%a_HO=)
				
			) else if !SEL_WIN! gtr 0 (
				if !DRAG_MODE! == 1 for %%a in (!SEL_WIN!) do set /a W%%a_X=ORGWX + M_X-ORGMX, W%%a_Y=ORGWY + M_Y-ORGMY
				if !DRAG_MODE! == 2 for %%a in (!SEL_WIN!) do set /a W%%a_W=ORGWW + M_X-ORGMX, W%%a_H=ORGWH + M_Y-ORGMY, W%%a_WM=ORGWW + M_X-ORGMX-1, W%%a_HM=ORGWH + M_Y-ORGMY-1 & (if !W%%a_H! lss 4 set /a W%%a_H=4, W%%a_HM=3) & (if !W%%a_W! lss !W%%a_WMIN! set /a W%%a_W=!W%%a_WMIN!, W%%a_WM=!W%%a_WMIN!-1) & (if !W%%a_H! gtr !H! set /a W%%a_H=H, W%%a_HM=H-1) & (if !W%%a_W! gtr !W! set /a W%%a_W=W, W%%a_WM=W-1) 
			)
		) else (
			set /a SEL_WIN=0, DRAG_MODE=0
		)
		
		if !M_WHEEL! neq 0 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a W%%i_YA-=!M_WHEEL!*2 & if !W%%i_YA! geq 1 set /a W%%i_YA=1
		
		set BORDER_RIGHT_X=&set BORDER_BOTTOM_Y=&set CLOSEPOS=&set MAXPOS=&set MAX_WIN=
	)

	if !KEY! gtr 0 (
		set /a KBHOG=0
		if !NOF_WIN! gtr 0 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do set /a KBHOG=!W%%i_KB! 
	
		if !KEY! == 9 if !KBHOG! lss 3 cmdwiz getkeystate shift > nul & call :TAB !errorlevel!
		if !KBHOG! == 0 (
			if !KEY! == 328 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 set /a W%%i_Y-=1, LIM=-!W%%i_H!+1 & if !W%%i_Y! leq !LIM! set /a W%%i_Y=!LIM!
			if !KEY! == 336 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 set /a W%%i_Y+=1 & if !W%%i_Y! geq !HM! set /a W%%i_Y=!HM!
			if !KEY! == 331 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 set /a W%%i_X-=1, LIM=-!W%%i_W!+1 & if !W%%i_X! leq !LIM! set /a W%%i_X=!LIM!
			if !KEY! == 333 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 set /a W%%i_X+=1 & if !W%%i_X! geq !WM! set /a W%%i_X=!WM!
			if !KEY! == 112 cmdwiz getch
		)
		
		if !KEY! == 329 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a W%%i_YA+=1 & if !W%%i_YA! geq 1 set /a W%%i_YA=1
		if !KEY! == 337 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a W%%i_YA-=1
		for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a TMP=-%MAXTH%+!W%%i_H! & if !W%%i_YA! lss !TMP! set /a W%%i_YA=!TMP!

		rem if !KEY! == 327 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a W%%i_XA+=1 & if !W%%i_XA! geq 1 set /a W%%i_XA=1
		rem if !KEY! == 335 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a W%%i_XA-=1
		rem for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_SCROLL!==1 set /a TMP=-%MAXTW%+!W%%i_W! & if !W%%i_XA! lss !TMP! set /a W%%i_XA=!TMP!
		
		if !KEY! == 27 set STOP=1
		
		if !KEY! == 411 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 if !W%%i_SIZE!==1 set /a W%%i_W-=1 & (if !W%%i_W! lss !W%%a_WMIN! set /a W%%i_W=!W%%a_WMIN!) & set /a W%%i_WM=!W%%i_W!-1
		if !KEY! == 413 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 if !W%%i_SIZE!==1 set /a W%%i_W+=1 & (if !W%%i_W! gtr !W! set /a W%%i_W=W) & set /a W%%i_WM=!W%%i_W!-1
		if !KEY! == 408 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 if !W%%i_SIZE!==1 set /a W%%i_H-=1 & (if !W%%i_H! lss 4 set /a W%%i_H=4) & set /a W%%i_HM=!W%%i_H!-1
		if !KEY! == 416 for %%a in (!NOF_WIN!) do for %%i in (!LAY%%a!) do if !W%%i_MAXED!==0 if !W%%i_SIZE!==1 set /a W%%i_H+=1 & (if !W%%i_H! gtr !H! set /a W%%i_H=H) & set /a W%%i_HM=!W%%i_H!-1
		
		set /a FSKEY=0 & (if !KEY! == 10 set /a FSKEY=1) & (if !KEY! == 13 if !KBHOG! lss 2 set /a FSKEY=1)
		if !FSKEY! == 1 (
			if "!OLDW!"=="" ( cmdwiz getwindowbounds x&set /a OLDWX=!errorlevel!&cmdwiz getwindowbounds y&set /a OLDWY=!errorlevel!&cmdwiz fullscreen 1 & set /a OLDW=W, OLDH=H & cmdwiz getconsoledim sw & set /a W=!errorlevel! + 1 & cmdwiz getconsoledim sh & set /a H=!errorlevel!+3 & set /a WWW=W*WPAGES, HH=H*2, WM=W-1, HM=H-1 & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
			) else ( cmdwiz fullscreen 0 & cmdwiz setwindowpos !OLDWX! !OLDWY! & set /a W=!OLDW!, H=!OLDH! & set /a WWW=W*WPAGES, HH=H*2, WM=W-1, HM=H-1 & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H! & set OLDW=&set OLDH=&set OLDWX=&set OLDWY=)
			set /a "MID_OFF_X=W+(WWW-W)/2"
			set /a IGNORE_SIZE=1
		)
		set FSKEY=

		if !KEY! == 371 if "!OLDW!"=="" set /a IGNORE_SIZE=1, W-=3 & (if !W! lss 60 set /a W=60) & set /a "WWW=W*WPAGES, WM=W-1, MID_OFF_X=W+(WWW-W)/2" & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
		if !KEY! == 372 if "!OLDW!"=="" set /a "IGNORE_SIZE=1, W+=3, WWW=W*WPAGES, WM=W-1, MID_OFF_X=W+(WWW-W)/2" & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
		if !KEY! == 397 if "!OLDW!"=="" set /a IGNORE_SIZE=1, H-=3 & (if !H! lss 40 set /a H=40) & set /a HH=H*2, HM=H-1, MID_OFF_Y=!H! & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
		if !KEY! == 401 if "!OLDW!"=="" set /a IGNORE_SIZE=1, H+=3, HH=H*2, HM=H-1, MID_OFF_Y=!H! & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
	)
	
	if !SIZE_EVENT!==1 (
		if !IGNORE_SIZE!==0 set /a "W=SIZE_W, H=SIZE_H, WWW=W*WPAGES, MID_OFF_X=W+(WWW-W)/2, HH=H*2, MID_OFF_Y=H" & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H! & cmdwiz showcursor 0
		set /a IGNORE_SIZE=0
	)

	if exist NewDrop\Done.txt call :NEWDROP
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
rd /S /Q _processed >nul 2>nul
echo "cmdgfx: quit"
title input:Q
goto :eof

:TAB
for /l %%n in (1,1,!NOF_WIN!) do (
	if %1 == 0 (
		set /a SEL_INDEX=1, SEL_WIN=!LAY1!
		for /l %%i in ( 2,1,!NOF_WIN! ) do set /a CI=%%i-1 & for %%j in (!CI!) do set /a LAY%%j=!LAY%%i!
		set /a LAY!NOF_WIN!=!SEL_WIN!, SEL_WIN=0
	) else (
		for %%i in (!NOF_WIN!) do set /a SEL_WIN=!LAY%%i!, STARTI=!NOF_WIN!-1
		for /l %%i in ( !STARTI!,-1,1 ) do set /a CI=%%i+1 & for %%j in (!CI!) do set /a LAY%%j=!LAY%%i!
		set /a LAY1=!SEL_WIN!, SEL_WIN=0
	)
	for %%i in (!NOF_WIN!) do for %%j in (!LAY%%i!) do if !W%%j_ACTIVE!==1 goto :eof
)
goto :eof

:NEWDROP
if not exist _processed mkdir _processed >nul 2>nul
set /a NEW_X=6, NEW_Y=6
for %%a in (NewDrop\*) do (
	set /a OW=W, OH=H
	set FULLSCREEN=
	set /a FS=1	& if "!OLDW!"=="" set /a FS=0
	if not "%%~nxa" == "Done.txt" (
		copy /Y "%%a" "_processed\%%~nxa" >nul 2>nul
		
		if "%%~xa"==".cfg" (
			for /f "tokens=* delims=" %%i in (%%a) do set line="%%i"& set DOCMD=!line:~1,-1!& !DOCMD!
		) else if "%%~xa"==".wav" ( 
			start /B cmdwiz playsound "%%~a"
		) else ( 
			set /a USEPOS=-1, INCW=0
			for /l %%b in (1,1,!NOF_WIN!) do if !W%%b_ACTIVE!==0 set /a USEPOS=%%b
			if !USEPOS!==-1 set /a NOF_WIN+=1, USEPOS=NOF_WIN, INCW=1
			
			for %%b in (!USEPOS!) do (
				set /a W%%b_W=50, W%%b_H=40, W%%b_X=!NEW_X!, W%%b_Y=!NEW_Y!, NEW_X+=2, NEW_Y+=2, W%%b_XA=1, W%%b_YA=1, W%%b_ACTIVE=1, W%%b_CLOSE=1, W%%b_SIZE=1, W%%b_CLEAR=1, W%%b_EXP=0, W%%b_KB=0
				set W%%b_INIT=""&set W%%b_UPDATE=""
				set SCALE=&set NOCODE=\&set /a W%%b_SCROLL=1
				(if /I "%%~xa"==".gxy" set SCALE=OFF_W,OFF_H)&(if /I "%%~xa"==".pcx" set SCALE=OFF_W,OFF_H)& if not "!SCALE!"=="" set /a W%%b_XA=0, W%%b_YA=0,W%%b_SCROLL=0&set NOCODE=
				set CONVNAME="%%~nxa"
				set CONVNAME=!CONVNAME: =~!
				set W%%b_NAME="%%~nxa"& set W%%b_CONTENT="image _processed\!CONVNAME:~1,-1! !NOCODE!!TEXT_COL! 0 -1 OFF_X,OFF_Y 0 0 !SCALE!"
				set /a W%%b_MAXED=0

				set /a IS3D=0 & (if /I "%%~xa"==".ply" set /a IS3D=1) & (if /I "%%~xa"==".plg" set /a IS3D=1) & (if /I "%%~xa"==".obj" set /a IS3D=1) 
				if !IS3D!==1 set W%%b_INIT="set /a RY%%b=0"& set W%%b_UPDATE="set /a RY%%b+=22, REPL1=RY%%b, REPL2=MID_OFF_X, REPL3=MID_OFF_Y, REPL4=12000-(OFF_W*35)"& set W%%b_CONTENT="3d _processed\!CONVNAME:~1,-1! 2,1 REPL1,REPL1,0 0,0,0 2,2,2,0,0,0 0,0,0,0 REPL2,REPL3,REPL4,1 PAL3D"
				
				if /I "%%~xa"==".met" for /f "tokens=* delims=" %%i in (%%a) do set line="%%i"&set line=!line:[]=%%b!& set DOCMD=!line:~1,-1!& !DOCMD!
				
				if not !W%%b_INIT!=="" set DOCMD=!W%%b_INIT:~1,-1!& call :DOCMD

				if "!W%%b_MAXED!"=="1" set /a W%%b_XO=!W%%b_X!,W%%b_YO=!W%%b_Y!,W%%b_WO=!W%%b_W!,W%%b_HO=!W%%b_H!,W%%b_X=0, W%%b_Y=0,W%%b_W=!W!,W%%b_H=!H!,W%%b_WM=!W!-1,W%%b_HM=!H!-1,W%%b_MAXED=1
				
				set /a W%%b_WM=!W%%b_W!-1, W%%b_HM=!W%%b_H!-1 & (if !INCW! == 1 set /a LAY%%b=%%b) & cmdwiz stringlen !W%%b_NAME! & set /a W%%b_WMIN = !errorlevel! + 16
			)
			
			set /a LAYCNT=1
			for /l %%i in (1,1,!NOF_WIN!) do (
				for %%j in (!LAY%%i!) do for %%k in (!LAYCNT!) do (
					if !W%%j_ACTIVE! == 1 if not %%j == !USEPOS! set /a LAY%%k=%%j, LAYCNT+=1
				)
			)
			set /a NOF_WIN=!LAYCNT! & set /a LAY!NOF_WIN!=!USEPOS!
			rem echo NOF_WIN:!NOF_WIN! USEPOS:!USEPOS! & (for /l %%i in (1,1,!NOF_WIN!) do echo !LAY%%i!) & cmdwiz getch
		)
	)
	
	set /a OR=0 & (if not !W!==!OW! set /a OR=1) & (if not !H!==!OH! set /a OR=1) 
	if !OR!==1 set /a "WWW=W*WPAGES, WM=W-1, MID_OFF_X=W+(WWW-W)/2, HH=H*2, HM=H-1, MID_OFF_Y=!H!" & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H! & if exist centerwindow.bat call centerwindow.bat 0 -20

	cmdwiz setwindowpos k k
	
	if not "!FULLSCREEN!" == "" (
		if "!FULLSCREEN!"=="1" ( if !FS!==0 cmdwiz getwindowbounds x&set /a OLDWX=!errorlevel!&cmdwiz getwindowbounds y&set /a OLDWY=!errorlevel!& cmdwiz fullscreen 1 & set /a OLDW=W, OLDH=H & cmdwiz getconsoledim sw & set /a W=!errorlevel! + 1 & cmdwiz getconsoledim sh & set /a H=!errorlevel!+3 & set /a WWW=W*WPAGES, HH=H*2, WM=W-1, HM=H-1 & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H!
		) else ( if !FS!==1 cmdwiz fullscreen 0 & cmdwiz setwindowpos !OLDWX! !OLDWY! & set /a W=!OLDW!, H=!OLDH! & set /a WWW=W*WPAGES, HH=H*2, WM=W-1, HM=H-1 & %MODECMD% !W!,!H! & echo "cmdgfx: " f%FONT%:0,0,!WWW!,!HH!,!W!,!H! & set OLDW=&set OLDH=&set OLDWX=&set OLDWY=)
		set /a "MID_OFF_X=W+(WWW-W)/2" & set FULLSCREEN=
	)
)

rd /S /Q NewDrop >nul 2>nul
set LAYCNT=&set NOCODE=&set USEPOS=&set line=&set IS3D=&set OR=&set NEW_X=&set NEW_Y=&set OW=&set OH=&set INCW=&set FS=&set DOCMD=
goto :eof

:PROCESS_NEWDROP
if "%~1" == "" goto :eof
mkdir NewDrop >nul 2>nul
:REP
copy /y "%~1" NewDrop> nul 2>nul
shift
if not "%~1" == "" goto :REP
echo Done>NewDrop\Done.txt
goto :eof

:DOCMD
%DOCMD%
