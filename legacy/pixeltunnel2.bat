@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1
set /a W=160, H=80
mode %W%,%H% & cls
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2
set /a DIST=2000, DRAWMODE=1
set /A CRX=0,CRY=0,CRZ=0
set ASPECT=0.75

call sindef.bat

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

set /A NOF=20, ZROT=0

set /A MUL=120
for /L %%a in (0,%OW%,360) do set /a SV=%%a, CV=%%a+90 & set /a "XPOS=(%SINE(x):x=!SV!*31416/180%*!MUL!>>%SHR%), YPOS=(%SINE(x):x=!CV!*31416/180%*!MUL!>>%SHR%)" & echo !XPOS! !YPOS! 0 >>%WNAME%
set /a CNT=0 & for /L %%a in (0,%OW%,360) do echo 1 !CNT! >>%WNAME%&set /a CNT+=1

set /A ADD1=5,ADD2=3
set BDIST=1200
set CDIST=-%BDIST%&for /L %%a in (1,1,%NOF%) do set PZ%%a=!CDIST!&set /A CDIST+=250&set /A PR%%a=%%a*%ADD1%&set /A PRC%%a=%%a*%ADD2%
set /A DISTMAX=%CDIST%
set /A DIVROTX=16, DIVROTY=16, SPEED=40
set /A COLDIV=(%DISTMAX%+%BDIST%)/10
::echo %COLDIV% & pause

set COLSET=0
call :SETCOLORS
set RENDERER=&set REND=1

set STOP=&set CONT=
:LOOP
for /L %%1 in (1,1,600) do if not defined STOP (
	set CRSTR=""
	for /L %%a in (1,1,%NOF%) do (for %%b in (!PR%%a!) do for %%c in (!PRC%%a!) do set /a INV=%%b,INV2=%%c & set /A "XP=(%SINE(x):x=!INV!*31416/180%*((PZ%%a+%BDIST%)/!DIVROTX!)>>%SHR%),YP=(%SINE(x):x=!INV2!*31416/180%*((PZ%%a+%BDIST%)/!DIVROTY!)>>%SHR%),PZ%%a-=!SPEED!,PR%%a+=%ADD1%,PRC%%a+=%ADD2%,C=(PZ%%a+%BDIST%)/%COLDIV%") & (for %%d in (!C!) do set CRSTR="!CRSTR:~1,-1! & 3d %WNAME% %DRAWMODE%,0 0,0,!CRZ! 0,0,0 1,1,1,!XP!,!YP!,!PZ%%a! 0,0,0,10 %XMID%,%YMID%,%DIST%,%ASPECT% !C%%d!")&(if !PZ%%a! leq -%BDIST% set PZ%%a=%DISTMAX%&set /A PR%%a+=%NOF%*%ADD1%,PRC%%a+=%NOF%*%ADD2%)
	start "" /B /High cmdgfx_gdi "fbox !BGC! 20 0,0,%W%,%H% & !CRSTR:~1,-1!" f1
	cmdgfx "" nkW12
	set KEY=!ERRORLEVEL!
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
	if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP
if defined CONT set CONT=&set STOP=&goto LOOP

del /Q %WNAME%
endlocal
cmdwiz setfont 6 & mode 80,50 & cls
goto :eof

:SETCOLORS
if %COLSET% gtr 3 set COLSET=0
if %COLSET%==0 set C0=f 0 04&set C1=f 0 04&set C2=f 0 .&set C3=f 0 .&set C4=7 0 .&set C5=7 0 .&set C6=8 0 .&set C7=8 0 .&set C8=8 0 .&set C9=8 0 .&set BGC=8 0
if %COLSET%==1 set C0=f 0 04&set C1=f 0 04&set C2=b 0 .&set C3=b 0 .&set C4=9 0 .&set C5=9 0 .&set C6=1 0 .&set C7=1 0 .&set C8=1 0 .&set C9=1 0 .&set BGC=1 0
if %COLSET%==2 set C0=f 0 db&set C1=f b b1&set C2=b 0 02&set C3=b 0 04&set C4=b 0 .&set C5=9 0 .&set C6=9 0 .&set C7=1 0 .&set C8=1 0 .&set C9=1 0 .&set BGC=9 0
::if %COLSET%==3 set C0=f 0 db&set C1=f d b1&set C2=d 0 02&set C3=d 0 04&set C4=d 0 .&set C5=5 0 .&set C6=5 0 .&set C7=5 0 .&set C8=5 0 .&set C9=5 0 fa&set BGC=5 0
if %COLSET%==3 set C0=f d b2&set C1=f d 02&set C2=d 0 04&set C3=d 0 07&set C4=d 0 .&set C5=5 0 .&set C6=5 0 .&set C7=5 0 .&set C8=5 0 .&set C9=5 0 fa&set BGC=5 0
