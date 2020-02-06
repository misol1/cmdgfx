@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 8
set /a W=160, H=80
set /a W8=W/2, H8=H/2
mode %W8%,%H8%
cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="
call centerwindow.bat 0 -15

set /a XMID=%W%/2,YMID=%H%/2
set /a DIST=2000, DRAWMODE=0, BKG=0, NOF=6
set /A CRX=0,CRY=0,CRZ=0,CRZ2=0
set ASPECT=0.75
set BITOP=3

call sindef.bat

set OW=16
set /A CNT=360 / %OW%
set /A CNTV=%CNT%+1
set WNAME=circle.ply
cmdwiz print "ply\nformat ascii 1.0\nelement vertex %CNTV%\nelement face 1\nend_header\n">%WNAME%

set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a S=%%a,COS=S+90 & set /a "XPOS=(%SINE(x):x=!S!*31416/180%*%MUL%>>%SHR%)" & set /A "YPOS=(%SINE(x):x=!COS!*31416/180%*%MUL%>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

set /A COL1=1,   COL2=2,  COL3=4,  COL4=8,  COL5=12,  COL6=10
set /A PX1=129,  PX2=-40,  PX3=-150, PX4=150,  PX5=-120, PX6=0
set /A PY1=10,   PY2=-160, PY3=100,  PY4=-100, PY5=100,  PY6=0
set /A PZ1=-200, PZ2=-150, PZ3=600,  PZ4=-140, PZ5=300,  PZ6=0
set OP=XOR

set t1=!time: =0!
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d),a+=(a>>31)&8640000"
	if !a! geq 1 (
		set CRSTR=""
		for /L %%a in (1,1,3) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% !DRAWMODE!,!BITOP! !CRX!,!CRY!,!CRZ! 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"
		for /L %%a in (4,1,6) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% !DRAWMODE!,!BITOP! !CRX!,!CRY!,!CRZ2! 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"

		start "" /B /High cmdgfx_gdi "fbox !BKG! 0 fa 0,0,200,100 & !CRSTR:~1,-1! & text 9 ? 0 !OP!(space)\-Bg\-!BKG!(ENTER) 1,78" f1:0,0,!W!,!H!kO

		set /A CRZ+=9,CRX+=0,CRY-=0,CRZ2-=4

		if exist EL.dat set /p KEY=<EL.dat 2>nul & del /Q EL.dat >nul 2>nul & if "!KEY!" == "" set KEY=0

		if !KEY! == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
		if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set /a BKG=0
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 100 set /A DIST+=100
		if !KEY! == 68 set /A DIST-=100
		if !KEY! == 27 set STOP=1
		
		set /a KEY=0
		set t1=!time: =0!
	)
)
if not defined STOP goto LOOP

del /Q %WNAME%
endlocal
cmdwiz setfont 6
mode 80,50 & cls
