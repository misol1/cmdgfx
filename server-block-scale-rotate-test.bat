@echo off
if not defined __ cmdwiz fullscreen 0
cmdwiz setfont 2 & mode 120,90 & cls & title Block scaling and rotation (cursor left/right)
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knuW10xR | call %0 %* | cmdgfx_gdi "" Sf2:0,0,360,90,120,90
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=120, H=90
call centerwindow.bat 0 -20

for /f "tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a NOF_SHIPS=10, BW=W+240, IX=W+200, CNT=0
for /l %%a in (1,1,!NOF_SHIPS!) do call :INIT_SHIP %%a

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

	set OUTP=""
	for /l %%a in (1,1,!NOF_SHIPS!) do set /a STRT%%a-=1 & (if !STRT%%a! leq 0 set /a X%%a+=!XA%%a!, Y%%a+=!YA%%a!) & (if !X%%a! gtr !W! call :INIT_SHIP %%a) & (if !X%%a! lss -!IW%%a! call :INIT_SHIP %%a) & (if !Y%%a! gtr !H! call :INIT_SHIP %%a) & (if !Y%%a! lss -!IW%%a! call :INIT_SHIP %%a) & set OUTP="!OUTP:~1,-1!&block 0 !IX!,0,31,19 !X%%a!,!Y%%a!,!IW%%a!,!IH%%a!,!RZ%%a! 41"

	set /a CNT+=1, II=!CNT!/20+1 & if !CNT! geq 40 set /a CNT=0
	echo "cmdgfx: fbox 9 0 A & image img/ship!II!.gxy 0 0 0 -1 !IX!,0 & !OUTP:~1,-1!" f2:0,0,!BW!,!H!,!W!,!H!
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 

	if "!RESIZED!"=="1" set /a "W=SCRW+1, BW=W+240, IX=W+200, H=SCRH+1" & cmdwiz showcursor 0
	
	if !K_DOWN! == 1 (
		if !KEY! == 331 if !NOF_SHIPS! gtr 1 set /a NOF_SHIPS-=1 
		if !KEY! == 333 set /a NOF_SHIPS+=1 & call :INIT_SHIP !NOF_SHIPS!
		if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 27 set STOP=1
	)
	set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:INIT_SHIP
set /a IW%1=31, IH%1=19, SCB=!RANDOM! %% 100
if !SCB! gtr 10 (
	set /a "IW%1 +=(!RANDOM! %% 60) - 15"
	set /a "CHG=!IW%1!*10000/31, IH%1=CHG*19/10000"
)	
set /a "STRT%1=!RANDOM! %% 50, SPD%1=!RANDOM! %% 2 + 1"	
set /a DIR=!RANDOM! %% 4
if !DIR!==0 set /a "RZ%1=0, XA%1=!SPD%1!, YA%1=0, X%1=-!IW%1!, Y%1=!RANDOM! %% (H) - !IH%1!/2"
if !DIR!==1 set /a "RZ%1=180, XA%1=-!SPD%1!, YA%1=0, X%1=W, Y%1=!RANDOM! %% (H) - !IH%1!/2"
if !DIR!==2 set /a "RZ%1=90, XA%1=0, YA%1=!SPD%1!, X%1=!RANDOM! %% (W) - !IW%1!/2, Y%1=-!IW%1!"
if !DIR!==3 set /a "RZ%1=270, XA%1=0, YA%1=-!SPD%1!, X%1=!RANDOM! %% (W) - !IW%1!/2, Y%1=H"
