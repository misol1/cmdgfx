@echo off
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 1
set W=160&set H=83
if "%~1" == "2" set W=158&set H=76
mode %W%,%H% & cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

call sintable.bat
for /L %%a in (0,1,180) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

set /A BKG=1, OW=22
set /A NOFPL=12, NOFPR=7
set /A ADDX=11, ADDY=8
set /A MULX=9, MULY=12
set /A DGRADD=180
set /A YBOUND=%MULY%*2+10
set /A XSTEP=2,YSTEP=3
set /A XS=4, YS=1
set IMG=ball4.gxy

if "%~1" == "2" set /A BKG=1, OW=22, NOFPL=20, NOFPR=10, ADDX=7, ADDY=5, MULX=6, MULY=9, DGRADD=180, XSTEP=2,YSTEP=3, XS=2,YS=4 & set /A YBOUND=%MULY%*2+6 & set IMG=ball_s.gxy

set CNT=0

if not exist dots mkdir dots
cmdwiz setbuffersize %W% 120
for /L %%a in (0,%OW%,720) do set CX=0 & set CRSTR=""& set RV=%%a & for /L %%b in (1,1,%NOFPL%) do set /A COS=!RV!+%DGRADD%&for %%c in (!COS!) do for %%s in (!RV!) do set /a "XPOS=!CX!+!MULX!+(!SIN%%s!*%MULX%>>14),YPOS=%H%+!MULY!+(!SIN%%c!*%MULY%>>14),RV+=%OW%*%XSTEP%,CX+=!ADDX!" & set CRSTR="!CRSTR:~1,-1! & image img\%IMG% 0 0 0 x !XPOS!,!YPOS!"&(if !RV! gtr 720 set /A RV-=720) & if %%b == %NOFPL% set /A PRC=%%a*100/720 & cmdgfx "fbox 7 0 x 0,%H%,%W%,%YBOUND% & !CRSTR:~1,-1! & text 9 0 0 Generating_flag_(!PRC!%%)... 70,35"&cmdwiz saveblock dots\!CNT! 0 %H% %W% %YBOUND%&set /A CNT+=1
cmdwiz setbuffersize %W% %H%

for /L %%a in (0,1,1000) do set SIN%%a=
set DI=0
set /A SHADEY=%H%-2
set RENDERER=_gdi&set REND=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (

set /A X=%XS%,Y=%YS%,I=!DI!
set CRSTR=""
for /L %%a in (1,1,%NOFPR%) do set CRSTR="!CRSTR:~1,-1! & image dots\!I!.gxy 0 0 0 x !X!,!Y!"&set /A I+=%YSTEP%,Y+=%ADDY%&if !I! geq %CNT% set /A I-=%CNT%
cmdgfx!RENDERER! "fbox !BKG! 0 db 0,0,200,200 & fbox !BKG! 0 b2 0,0,200,1 & fbox !BKG! 0 b2 0,%SHADEY%,200,1 & !CRSTR:~1,-1!" kf1
set KEY=!ERRORLEVEL!

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
