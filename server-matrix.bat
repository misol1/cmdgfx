@echo off
bg font 5 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" ekOSf5:0,0,310,160,155,55W15
set __=
cls & bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=155
set /a WW=!W!*2
set /a WT=%W%-1 & mode !WT!,55

for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="
set /a CNT=0 & for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set /a HX!CNT!=%%a, CNT+=1
set IMG=img\myface.txt& if not "%~1" == "" set IMG=%1

echo "cmdgfx: fbox 2 0 00 0,0,%WW%,160"
set STREAM="??00=??00,??40=2?41,??41=2000,??80=2?81,??81=2000,??d0=2?d1,??d1=2000,????=??++"
del /Q EL.dat >nul 2>nul

set PAL0=-
set PAL1=000000,000000,022476,000000,000000,000000,000000,000000,000000,000000,0872ff
set PAL2=000000,000000,793400,000000,000000,000000,000000,000000,000000,000000,f89200
set /a PALC=0
set /a IMGI=0
set IMG0=img\spiral\_.txt
set IMG1=img\spiral.txt
set IMG2=img\myface.txt
set IMG3=img\-.txt
set /a XP=36,YP=4,IMGC=0

set /a SHOWHELP=1
set HELPMSG=text a 0 0 SPACE\-ENTER\-\g11\g10\g1e\g1f\-h 1,53
if !SHOWHELP!==1 set MSG=%HELPMSG%

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
  set OUT=""
  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,0&pixel f 0 !C1!!C3! !X!,1&pixel e 0 !C1!!C2! !X!,2&"
  for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,0&pixel 2 0 00 !X!,1&"

  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,80"
  for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,80&"

  for %%c in (!PALC!) do for %%i in (!IMGI!) do for %%n in (!IMGCD!) do set IMAGE=!IMG%%i! & set IMAGE=!IMAGE:_=%%n! & echo "cmdgfx: !OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 -1 0 0 2???=a???& block 0 %W%,2,%W%,75 0,0 00 & fbox ? ? 20 0,0,154,54 & image !IMAGE! ? ? 0 -1 !XP!,!YP! & block 0 %W%,80,%W%,75 0,76 -1 0 0 f???=2??? & block 0 %W%,2,%W%,75 0,76 00 0 0 a???=2???,2???=2???,f???=2???,e???=a??? & block 0 0,0,%W%,75 0,76 20 & block 0 0,76,%W%,75 0,0 & !MSG!" - !PAL%%c!
  
  if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

  if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set MSG=)&if !SHOWHELP!==1 set MSG=!HELPMSG!
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  if !KEY! == 331 set /a XP-=2
  if !KEY! == 333 set /a XP+=2
  if !KEY! == 328 set /a YP-=1
  if !KEY! == 336 set /a YP+=1
  if !KEY! == 13 set /a "IMGI=(!IMGI! + 1) %% 4" & (if !IMGI! == 2 set /a YP-=3) & (if !IMGI! == 3 set /a YP+=3)
  if !KEY! == 32 set /a PALC+=1 & if !PALC! gtr 2 set /a PALC=0
  set /a KEY=0
  set /a "IMGC=(!IMGC!+1) %% (10 * 5), IMGCD=IMGC/5"
)
if not defined STOP goto LOOP

echo "cmdgfx: quit"
cmdwiz delay 100
del /Q matrix-src-copy.bat>nul 2>nul
endlocal
