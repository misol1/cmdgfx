@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 8 & cls & cmdwiz showcursor 0
set /a W=160, H=80
set /a W8=W/2, H8=H/2
mode %W8%,%H8%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
call centerwindow.bat 0 -15

set /a XMID=%W%/2, YMID=%H%/2, DIST=5300, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0, OW=10, COLCNT=0
set ASPECT=0.75
set COLS_0=f 0 db   f 7 b1  7	 0 db   7 8 b1   8 0 db  8 0 db  8 0 b1  8 0 b1   8 0 b1   8 0 b1  8 0 b1  8 0 b1
set COLS_1=c 0 db

set WNAME=objects\pixelcube.ply
if exist %WNAME% goto :SKIPGEN
set CNT=0&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /A CNT+=1
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNT%\nelement face %CNT%\nend_header\n" > %WNAME%
for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /a J1=!RANDOM!%%10-5,J2=!RANDOM!%%10-5,J3=!RANDOM!%%10-5 & echo %%c.!J1! %%b.!J2! %%a.!J3! >>%WNAME%
set /a CNT=-1&for /L %%a in (-%OW%,1,%OW%) do for /L %%b in (-%OW%,1,%OW%) do for /L %%c in (-%OW%,1,%OW%) do set /a CNT+=1&echo 1 !CNT! >>%WNAME%

:SKIPGEN
call sindef.bat

set /a XMUL=2200, CNT=0, BOU=0, SC=50, CRX=12, CRY=47, XPOS=200
	
set t1=!time: =0!
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d),a+=(a>>31)&8640000"
	if !a! geq 1 (
		set /a CNT+=1 & if !CNT! gtr 300 set /a BOU=1
		if !BOU!==1 set /a SC+=3
		set /a "DIST=(%SINE(x):x=!SC!*31416/180%*!XMUL!>>!SHR!) + 3000"
		if !XPOS! gtr %XMID% set /a XPOS-=1
		
		rem & image img\myface.txt 1 0 0 -1 27,0 0 0 104,%H%
		start /B /High cmdgfx_gdi "fbox 7 0 20 0,0,%W%,%H% & 3d %WNAME% %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 10,10,10,0,0,0 0,0,0,60 !XPOS!,%YMID%,!DIST!,%ASPECT% !COLS_%%c!" f1:0,0,%W%,%H%kO

		if exist EL.dat set /p KEY=<EL.dat 2>nul & del /Q EL.dat >nul 2>nul & if "!KEY!" == "" set KEY=0
				
		set /a CRZ+=7,CRX+=5,CRY-=4

		if !KEY! == 112 cmdwiz getch
		if !KEY! == 32 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
		if !KEY! == 100 set /A DIST+=100
		if !KEY! == 68 set /A DIST-=100
		if !KEY! == 27 set STOP=1
		set /a KEY=0
		set t1=!time: =0!
	)
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
rem del /Q %WNAME%
