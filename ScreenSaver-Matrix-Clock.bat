@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cls & cmdwiz setfont 6 & cls & cmdwiz showcursor 0

mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/7+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/12+1

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%m0OW16eSf5:0,0,310,165,155,55t6 000000,000080,004000
set __=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set /a WW=W*2, HHH=H*3
set /a HP=H+20, HP2=HP+1, HPP=HP+5, HPP2=HPP+1

set /a CNT=0 & for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /a HX!CNT!=%%a, CNT+=1

set STREAM="??00=??00,??40=2?41,??41=2000,??80=2?81,??81=2000,??d0=2?d1,??d1=2000,????=??++"

set /a RY=0, SPIN=1, ZOOM=0
set /a INDEX=0 & for %%a in (52 53 54 55 56 57 58 59 60 61 69) do set /a N!INDEX!=%%a, INDEX+=1
set CCHAR=07

set /a INI=0 & rem set INI to 1 to show image immediately (as before)
if !INI!==1 set INIT=fbox 2 0 00

call sindef.bat
set /a MUL=1000, SC=0

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
  set OUT="!INIT!&"
  set INIT=
  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,0&pixel f 0 !C1!!C3! !X!,1&pixel e 0 !C1!!C2! !X!,2&"
  for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,0&pixel 2 0 00 !X!,1&"

  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,!HPP!"
  for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,!HPP!&"

  set /a RY+=12
  set TIMED=!TIME! & set DIGI=""
  set /a "DIST=4000" & if !W! lss 275 set /a "DIST+=(275-W)*20"

  if !ZOOM! gtr 0 for %%a in (!SC!) do set /a A1=%%a & set /a "DIST+=(%SINE(x):x=!A1!*31416/180%*!MUL!>>!SHR!)+MUL/2, SC+=ZOOM"

  set /a "XD1=30-(DIST-4000)/200, XD2=23-(DIST-4000)/300"
  set /a "XP=W/2-(XD1*5+XD2*2)/2, YP=H/2+6-(DIST-4000)/2000, CNT=0, RY2=!RY!"
  for %%a in (0 1 3 4 6 7) do set CH=!TIMED:~%%a,1!& (if "!CH!"==" " set CH=0) & for %%b in (!CH!) do (if !SPIN!==0 set RY2=0) & set DIGI="!DIGI:~1,-1!  & 3d objects\letters\alph!N%%b!.obj 5,0 0,!RY2!,0 10,10,0 1,1,1,0,0,0 0,0,0,10 !XP!,!YP!,!DIST!,1.0 ? ? %CCHAR%"& set /a XP+=XD1, RY2+=180, CNT+=1 & if !CNT!==2 if %%a neq 7 set /a CNT=0 & set DIGI="!DIGI:~1,-1! & 3d objects\letters\alph!N10!.obj 5,0 0,0,0 10,10,0 1,1,1,0,0,0 0,0,0,10 !XP!,!YP!,!DIST!,1.0 ? ? %CCHAR%"& set /a XP+=XD2

  echo "cmdgfx: !OUT:~1,-1! & block 0 !W!,0,!W!,!HP! !W!,2 -1 0 0 %STREAM:~1,-1% & block 0 !W!,!HPP!,!W!,!HP! !W!,!HPP2! -1 0 0 %STREAM:~1,-1% & block 0 !W!,!HPP!,!W!,!HP! 0,0 -1 0 0 2???=a???& block 0 !W!,2,!W!,!HP! 0,0 00 & fbox ? ? 20 0,0,!W!,!H! & !DIGI:~1,-1! & block 0 !W!,!HPP!,!W!,!HP! 0,!HP2! -1 0 0 f???=2??? & block 0 !W!,2,!W!,!HP! 0,!HP2! 00 0 0 a???=2???,2???=2???,f???=2???,e???=a??? & block 0 0,0,!W!,!HP! 0,!HP2! 20 & block 0 0,!HP2!,!W!,!HP! 0,0 & skip text 9 0 a !W!_!DIST! 1,1" f5:0,0,!WW!,!HHH!,!W!,!H! !PAL%%c!
  
  if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

  if !KEY! == 112 set /a KEY=0 & cmdwiz getch
  if !KEY! neq 0 set STOP=1
  if !MOUSE_EVENT! neq 0 set STOP=1
	
  set /a KEY=0
)
if not defined STOP goto LOOP

cmdwiz delay 100
echo "cmdgfx: quit"
endlocal
