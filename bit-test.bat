@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1
set /a W=160, H=80
mode %W%,%H%
cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2,YMID=%H%/2
set /a DIST=2000, DRAWMODE=0, BKG=0, NOF=6
set /A CRX=0,CRY=0,CRZ=0
set ASPECT=0.75
set BITOP=3

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /a SHR=13

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

:LOOP
	set CRSTR=""
	for /L %%a in (1,1,3) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,%BITOP% %CRX%,%CRY%,%CRZ% 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"
	for /L %%a in (4,1,6) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,%BITOP% %CRX%,%CRY%,%CRZ2% 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"

	start "" /B /High cmdgfx_gdi "fbox %BKG% 0 fa 0,0,200,100 & %CRSTR:~1,-1% & text 9 ? 0 !OP!(space)\-Bg\-!BKG!(ENTER) 1,78" f1
	cmdgfx "" nkW12
	set KEY=%ERRORLEVEL%

	set /A CRZ+=9,CRX+=0	,CRY-=0,CRZ2-=4

	if %KEY% == 32 set /A BITOP+=1&(if !BITOP! gtr 6 set BITOP=0)&set CNT=0&for %%a in (NORMAL OR AND XOR ADD SUB SUB-n) do (if !CNT!==!BITOP! set OP=%%a)&set /A CNT+=1
	if %KEY% == 13 set /A BKG+=1&if !BKG! gtr 15 set BKG=0
	if %KEY% == 112 cmdwiz getch
	if %KEY% == 100 set /A DIST+=100
	if %KEY% == 68 set /A DIST-=100
if not %KEY% == 27 goto LOOP

del /Q %WNAME%
endlocal
bg font 6
mode 80,50 & cls
