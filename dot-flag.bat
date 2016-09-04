@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1
set W=160&set H=80
mode %W%,%H% & cls & cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
set CHAR=.
if not "%~1" == "" set CHAR=%~1

call sintable.bat
for /L %%a in (0,1,180) do set /A SV=720+%%a & set SIN!SV!=!SIN%%a!

set /A BKG=1, OW=16
set /A NOFPL=46, NOFPR=20

set /A ADDX=3, ADDY=3
set /A MULX=8, MULY=9
set /A DGRADD=180
set /A YBOUND=%MULY%*2
set /A XSTEP=1,YSTEP=2
set CNT=0

if not exist dots mkdir dots
cmdwiz setbuffersize %W% 120
for /L %%a in (0,%OW%,720) do set CX=0 & set CRSTR=""& set RV=%%a & for /L %%b in (1,1,%NOFPL%) do set /A COS=!RV!+%DGRADD%&for %%c in (!COS!) do for %%s in (!RV!) do set /a "XPOS=!CX!+!MULX!+(!SIN%%s!*%MULX%>>14),YPOS=%H%+!MULY!+(!SIN%%c!*%MULY%>>14),RV+=%OW%*%XSTEP%,CX+=!ADDX!" & set CRSTR="!CRSTR:~1,-1! & pixel f %BKG% %CHAR% !XPOS!,!YPOS!"&(if !RV! gtr 720 set /A RV-=720) & if %%b == %NOFPL% set /A PRC=%%a*100/720 & cmdgfx "fbox 7 0 20 0,%H%,%W%,%YBOUND% & !CRSTR:~1,-1! & text 9 0 0 Generating_flag_(!PRC!%%)... 70,35"&cmdwiz saveblock dots\!CNT! 0 %H% %W% %YBOUND%&set /A CNT+=1
cmdwiz setbuffersize %W% %H%

for /L %%a in (0,1,1000) do set SIN%%a=
set DI=0
set RENDERER=_gdi&set REND=0

set STOP=
:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,30) do if not defined STOP (

set /A X=5,Y=2,I=!DI!
set CRSTR=""
for /L %%a in (1,1,%NOFPR%) do set CRSTR="!CRSTR:~1,-1! & image dots\!I!.gxy 0 0 0 20 !X!,!Y!"&set /A I+=%YSTEP%,Y+=%ADDY%&if !I! geq %CNT% set /A I-=%CNT%
cmdgfx!RENDERER! "fbox !BKG! 0 db 0,0,200,200 & !CRSTR:~1,-1!" kf1
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
