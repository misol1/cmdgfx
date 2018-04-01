@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 1
set /a W=160, H=82
if "%~1" == "2" set /a W=158, H=76
mode %W%,%H% & cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call sindef.bat

set /a BKG=1, OW=11
set /a NOFPL=12, NOFPR=7
set /a ADDX=11, ADDY=8, MULX=7, MULY=9, DGRADD=90
set /a YBOUND=%MULY%*2+12
set /a XSTEP=2,YSTEP=3, XS=4, YS=2
set IMG=ball4.gxy

if "%~1" == "2" set /a BKG=1, OW=11, NOFPL=20, NOFPR=10, ADDX=7, ADDY=5, MULX=6, MULY=8, DGRADD=90, XSTEP=2,YSTEP=3, XS=1,YS=3 & set /A YBOUND=%MULY%*2+8 & set IMG=ball_s.gxy

set /a CNT=0

if not exist dots mkdir dots
cmdwiz setbuffersize %W% 120
for /L %%a in (0,%OW%,360) do set CRSTR=""& set /a CX=0, RV=%%a & for /L %%b in (1,1,%NOFPL%) do set /A COS=!RV!+%DGRADD% & set /a "XPOS=2+!CX!+!MULX!+(%SINE(x):x=!RV!*31416/180%*!MULX!>>%SHR%),YPOS=%H%+2+!MULY!+(%SINE(x):x=!COS!*31416/180%*!MULY!>>%SHR%),RV+=%OW%*%XSTEP%,CX+=!ADDX!" & set CRSTR="!CRSTR:~1,-1! & image img\%IMG% 0 0 0 x !XPOS!,!YPOS!"& if %%b == %NOFPL% set /A PRC=%%a*100/360 & cmdgfx "fbox 7 0 x 0,%H%,%W%,%YBOUND% & !CRSTR:~1,-1! & text 9 0 0 Generating_flag_(!PRC!%%)... 70,35"&cmdwiz saveblock dots\!CNT! 0 %H% %W% %YBOUND%&set /A CNT+=1
cmdwiz setbuffersize %W% %H%

set /a DI=0, SHADEY=%H%-2
set RENDERER=_gdi& set /a REND=0

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /A X=%XS%,Y=%YS%,I=!DI!
	set CRSTR=""
	for /L %%a in (1,1,%NOFPR%) do set CRSTR="!CRSTR:~1,-1! & image dots\!I!.gxy 0 0 0 x !X!,!Y!"&set /A I+=%YSTEP%,Y+=%ADDY%&if !I! geq %CNT% set /A I-=%CNT%
	cmdgfx!RENDERER! "fbox !BKG! 0 db 0,0,200,200 & fbox !BKG! 0 b2 0,0,200,1 & fbox !BKG! 0 b2 0,%SHADEY%,200,1 & !CRSTR:~1,-1!" kf1
	set /a KEY=!ERRORLEVEL!

	set /A DI+=1&if !DI! geq %CNT% set DI=0

	if !KEY! == 13 set /A BKG+=1&if !BKG! gtr 15 set BKG=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
rd /Q /S dots
cmdwiz setfont 6
mode 80,50 & cls & cmdwiz showcursor 1
