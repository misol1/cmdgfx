@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1
set W=160&set H=80
mode %W%,%H%
cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2&set /a YMID=%H%/2
set DIST=2000
set ASPECT=1.5
set DRAWMODE=0
set BITOP=3
set /A CRX=0,CRY=0,CRZ=0,CRZ2=0
set BKG=0

call sintable.bat
for /L %%a in (0,1,360) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

set OW=32
set /A CNT=720 / %OW%
set /A CNTV=%CNT%+1
set /A CNTF=1
set WNAME=circles.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
echo element vertex %CNTV% >>%WNAME%
echo element face %CNTF% >>%WNAME%
echo end_header>>%WNAME%

set /A MUL=150
for /L %%a in (0,%OW%,720) do set /A COS=%%a+180&for %%b in (!COS!) do set /a "XPOS=(!SIN%%a!*%MUL%>>14)" & set /A "YPOS=(!SIN%%b!*%MUL%>>14)" & echo !XPOS! !YPOS! 0 >>%WNAME%
echo 24  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 0 >>%WNAME%

for /L %%a in (0,1,1200) do set SIN%%a=

set /A COL1=1,   COL2=2,  COL3=4,  COL4=8,  COL5=12,  COL6=10
set /A PX1=129,  PX2=-40,  PX3=-150, PX4=150,  PX5=-120, PX6=0
set /A PY1=10,   PY2=-160, PY3=100,  PY4=-100, PY5=100,  PY6=0
set /A PZ1=-200, PZ2=-150, PZ3=600,  PZ4=-140, PZ5=300,  PZ6=0
set OP=XOR

:LOOP
set CRSTR=""
for /L %%a in (1,1,3) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,%BITOP% %CRX%,%CRY%,%CRZ% 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"
for /L %%a in (4,1,6) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,%BITOP% %CRX%,%CRY%,%CRZ2% 0,0,0 1,1,1,!PX%%a!,!PY%%a!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% 0 !COL%%a! 20"
cmdgfx "fbox %BKG% 0 fa 0,0,200,100 & %CRSTR:~1,-1% & text 9 ? 0 !OP!(space)\-Bg\-!BKG!(ENTER) 1,78" k
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
cmdwiz setfont 6
mode 80,50 & cls
