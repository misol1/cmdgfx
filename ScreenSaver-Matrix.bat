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
::set /a W=(W*114)/100+2

set __=.
call %0 %* | cmdgfx_gdi "" %TOP%m0OW16eSf5:0,0,310,165,155,55t6
set __=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set /a WW=W*2, HHH=H*3
set /a HP=H+20, HP2=HP+1, HPP=HP+5, HPP2=HPP+1

set /a CNT=0 & for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /a HX!CNT!=%%a, CNT+=1
set IMG=img\myface.txt& if not "%~1" == "" set IMG=%1

set STREAM="??00=??00,??40=2?41,??41=2000,??80=2?81,??81=2000,??d0=2?d1,??d1=2000,????=??++"

set PAL0=-
set PAL1=000000,000000,022476,000000,000000,000000,000000,000000,000000,000000,0872ff
set PAL2=000000,000000,793400,000000,000000,000000,000000,000000,000000,000000,f89200
set /a PALC=0
set /a IMGI=0
set IMG0=img\spiral\_.txt
set IMG1=img\myface.txt
set IMG2=img\-.txt

set /a "XP=W/2-80/2-1,YP=H/2-48/2"
set /a IMGC=0

::set INI to 1 to show image immediately (as before)
set /a INI=0
if !INI!==1 set INIT=fbox 2 0 00

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
  set OUT="!INIT!&"
  set INIT=
  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,0&pixel f 0 !C1!!C3! !X!,1&pixel e 0 !C1!!C2! !X!,2&"
  for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,0&pixel 2 0 00 !X!,1&"

  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,!HPP!"
  for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,!HPP!&"

  for %%c in (!PALC!) do for %%i in (!IMGI!) do for %%n in (!IMGCD!) do set IMAGE=!IMG%%i! & set IMAGE=!IMAGE:_=%%n! & echo "cmdgfx: !OUT:~1,-1! & block 0 !W!,0,!W!,!HP! !W!,2 -1 0 0 %STREAM:~1,-1% & block 0 !W!,!HPP!,!W!,!HP! !W!,!HPP2! -1 0 0 %STREAM:~1,-1% & block 0 !W!,!HPP!,!W!,!HP! 0,0 -1 0 0 2???=a???& block 0 !W!,2,!W!,!HP! 0,0 00 & fbox ? ? 20 0,0,!W!,!H! & image !IMAGE! ? ? 0 -1 !XP!,!YP! & block 0 !W!,!HPP!,!W!,!HP! 0,!HP2! -1 0 0 f???=2??? & block 0 !W!,2,!W!,!HP! 0,!HP2! 00 0 0 a???=2???,2???=2???,f???=2???,e???=a??? & block 0 0,0,!W!,!HP! 0,!HP2! 20 & block 0 0,!HP2!,!W!,!HP! 0,0" f5:0,0,!WW!,!HHH!,!W!,!H! !PAL%%c!
  
  if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

  if !KEY! == 112 set /a KEY=0 & cmdwiz getch
  if !KEY! neq 0 set STOP=1
  if !MOUSE_EVENT! neq 0 set STOP=1
	
  set /a KEY=0
  set /a "IMGC=(!IMGC!+1) %% (10 * 5), IMGCD=IMGC/5"
)
if not defined STOP goto LOOP

cmdwiz delay 100
echo "cmdgfx: quit"
endlocal
