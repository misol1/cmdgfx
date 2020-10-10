:: Colorwrite test : Mikael Sollenborn 2016
@echo off
cmdwiz setfont 6 & mode 80,54 & cls & title Color write test
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW6xR | call %0 %* | cmdgfx_gdi "" Sf6:0,0,80,54
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a W=80, H=54

call centerwindow.bat 0 -16
call prepareScale.bat 6

set /a XMID=W/2, YMID=H/2, DIST=1000, DRAWMODE=0, CRX=0,CRY=0,CRZ=0, CNT=50, CHGW=0
set ASPECT=0.675
set COLS=a 2 ?  a 2 ?  9 0 ?  9 0 ?  c 4 ?  c 4 ?
set /a IH=H+4, IW=IH*138/100, IX=W/2-IW/2

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set CRSTR="fbox 7 0 20 & image img\emma.txt 7 0 0 -1 !IX!,0 0 0 !IW!,!IH!"
	if !CNT! gtr 200 if !CNT! lss 1200 set /a CRZ+=5,CRX+=3,CRY-=4, DIST+=4
	if !CNT! gtr 1050 if !CNT! lss 1200 set /a XMID-=1
	if !CNT! lss 1200 set CRSTR="!CRSTR:~1,-1! & 3d objects\cube.ply %DRAWMODE%,-1 !CRX!,!CRY!,!CRZ! 0,0,0 -150,-150,-150,0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% %COLS% "
	if !CNT! == 1200 set /a DIST=900, XMID=W/2 & title input:W10
	if !CNT! gtr 1200 set CRSTR="!CRSTR:~1,-1! & 3d objects\cube-t-hulk.obj %DRAWMODE%,-1 !CRX!,!CRY!,!CRZ! 0,0,0 350,350,350,0,0,0 1,0,0,10 !XMID!,!YMID!,!DIST!,%ASPECT% 0 0 ?"& set /a CRZ-=8,CRX+=5,CRY+=2

	echo "cmdgfx: !CRSTR:~1,-1!" Ff6:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%E, SCRW=%%F, SCRH=%%G 2>nul ) 

	if "!RESIZED!"=="1" set /a W=SCRW*rW/100+1, H=SCRH*rH/100+1, XMID=W/2, YMID=H/2, IH=H+4, IW=IH*138/100, IX=W/2-IW/2 & cmdwiz showcursor 0
	
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a CNT+=1, KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
