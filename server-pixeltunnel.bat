@echo off
bg font 1 & mode 160,80 & cls
cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf1:0,0,160,80W12
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=2000, DRAWMODE=1
set /A CRX=0,CRY=0,CRZ=0
set ASPECT=0.75

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /a SHR=13

:: try higher values for OW, like 16, 32, 60 !
set OW=8
set /A CNT=360/%OW%
set /A CNTV=%CNT%+1
set WNAME=tunnel.ply
echo ply>%WNAME%
echo format ascii 1.0 >>%WNAME%
echo element vertex %CNTV% >>%WNAME%
echo element face %CNTV% >>%WNAME%
echo end_header>>%WNAME%

set /A NOF=25, ZROT=0, SHR=13

set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a SV=%%a, CV=%%a+90 & set /a "XPOS=(%SINE(x):x=!SV!*31416/180%*!MUL!>>%SHR%), YPOS=(%SINE(x):x=!CV!*31416/180%*!MUL!>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
set /a CNT=0 & for /L %%a in (0,%OW%,360) do echo 1 !CNT! >>%WNAME%&set /a CNT+=1

set /A ADD1=4,ADD2=2
set BDIST=1200
set CDIST=-%BDIST%&for /L %%a in (1,1,%NOF%) do set PZ%%a=!CDIST!&set /A CDIST+=250&set /A PR%%a=%%a*%ADD1%&set /A PRC%%a=%%a*%ADD2%
set /A DISTMAX=%CDIST%
set /A DIVROTX=16, DIVROTY=16, SPEED=30
set /A COLDIV=(%DISTMAX%+%BDIST%)/10

set COLSET=0
call :SETCOLORS
del /Q EL.dat >nul 2>nul

set STOP=&set CONT=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set CRSTR=""
	for /L %%a in (1,1,%NOF%) do (for %%b in (!PR%%a!) do for %%c in (!PRC%%a!) do set /a INV=%%b,INV2=%%c & set /A "XP=(%SINE(x):x=!INV!*31416/180%*((PZ%%a+%BDIST%)/!DIVROTX!)>>%SHR%),YP=(%SINE(x):x=!INV2!*31416/180%*((PZ%%a+%BDIST%)/!DIVROTY!)>>%SHR%),PZ%%a-=!SPEED!,PR%%a+=%ADD1%,PRC%%a+=%ADD2%,C=(PZ%%a+%BDIST%)/%COLDIV%") & (for %%d in (!C!) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,0 0,0,!CRZ! 0,0,0 1,1,1,!XP!,!YP!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !C%%d!")&(if !PZ%%a! leq -%BDIST% set PZ%%a=%DISTMAX%&set /A PR%%a+=%NOF%*%ADD1%,PRC%%a+=%NOF%*%ADD2%)

	echo "cmdgfx: fbox !BGC! 20 0,0,%W%,%H% & !CRSTR:~1,-1!"

	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	set CRSTR=

	set /A CRZ+=!ZROT!

	if !KEY! == 328 set /A SPEED+=1&if !SPEED! gtr 100 set SPEED=100
	if !KEY! == 336 set /A SPEED-=1&if !SPEED! lss 15 set SPEED=15
	if !KEY! == 120 set /A DIVROTX+=1&if !DIVROTX! gtr 200 set DIVROTX=200
	if !KEY! == 88 set /A DIVROTX-=1&if !DIVROTX! lss 8 set DIVROTX=8
	if !KEY! == 121 set /A DIVROTY+=1&if !DIVROTY! gtr 150 set DIVROTY=150
	if !KEY! == 89 set /A DIVROTY-=1&if !DIVROTY! lss 8 set DIVROTY=8
	if !KEY! == 32 set /A COLSET+=1,STOP=1,CONT=1&call :SETCOLORS
	if !KEY! == 122 set /A ZROT=1-!ZROT!&set CRZ=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
if defined CONT set CONT=&set STOP=&goto LOOP

del /Q %WNAME%
endlocal
echo "cmdgfx: quit"
goto :eof

:SETCOLORS
if %COLSET% gtr 3 set COLSET=0
if %COLSET%==0 set C0=f 0 04&set C1=f 0 04&set C2=f 0 .&set C3=f 0 .&set C4=7 0 .&set C5=7 0 .&set C6=8 0 .&set C7=8 0 .&set C8=8 0 .&set C9=8 0 .&set BGC=8 0
if %COLSET%==1 set C0=f 0 04&set C1=f 0 04&set C2=b 0 .&set C3=b 0 .&set C4=9 0 .&set C5=9 0 .&set C6=1 0 .&set C7=1 0 .&set C8=1 0 .&set C9=1 0 .&set BGC=1 0
if %COLSET%==2 set C0=f 0 db&set C1=f b b1&set C2=b 0 02&set C3=b 0 04&set C4=b 0 .&set C5=9 0 .&set C6=9 0 .&set C7=1 0 .&set C8=1 0 .&set C9=1 0 .&set BGC=9 0
::if %COLSET%==3 set C0=f 0 db&set C1=f d b1&set C2=d 0 02&set C3=d 0 04&set C4=d 0 .&set C5=5 0 .&set C6=5 0 .&set C7=5 0 .&set C8=5 0 .&set C9=5 0 fa&set BGC=5 0
if %COLSET%==3 set C0=f d b2&set C1=f d 02&set C2=d 0 04&set C3=d 0 07&set C4=d 0 .&set C5=5 0 .&set C6=5 0 .&set C7=5 0 .&set C8=5 0 .&set C9=5 0 fa&set BGC=5 0
