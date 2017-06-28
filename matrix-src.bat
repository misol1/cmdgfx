@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=155
set /a WW=!W!*2
bg font 5
set /a WT=%W%-1 & mode !WT!,55
cmdwiz setbuffersize %WW% 160
cmdwiz showcursor 0 & cls

for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="
set CNT=0&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set HX!CNT!=%%a&set /a CNT+=1
set IMG=matrix-src.bat&if not "%~1" == "" set IMG=%1

< %IMG% (
  for /l %%i in (1,1,60) do set /p line%%i=
)
for /l %%i in (1,1,60) do set linetemp="!line%%i!"&set linetemp=!linetemp:^"='!&set "line%%i=!linetemp:~1,-1!"

set SPACES=                                                                                                                                                                              
for /L %%a in (1,1,60) do (
  cmdwiz stringlen "!line%%a!" & set /a FILL = %W% - !errorlevel!
  if !FILL! gtr 0 for %%b in (!FILL!) do cmdwiz print "!N!!L!!line%%a!!SPACES:~0,%%b!">>matrix-src-copy.bat
  if !FILL! leq 0 cmdwiz print "!N!!L!!line%%a:~0,%W%!">>matrix-src-copy.bat
  set line%%a=
  set N=\&set L=n
)
set SPACES=

cmdgfx "fbox 2 0 00 0,0,%WW%,160"
set STREAM="??00=??00,??40=2?41,??41=2000,??80=2?81,??81=2000,??d0=2?d1,??d1=2000,????=??++"

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
  set OUT=""
  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,0&pixel f 0 !C1!!C3! !X!,1&pixel e 0 !C1!!C2! !X!,2&"
  for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,0&pixel 2 0 00 !X!,1&"

  for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel f 0 !C1!!C2! !X!,80"
  for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,80&"

  cmdgfx "!OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 -1 0 0 2???=a???& block 0 %W%,2,%W%,75 0,0 00 & image matrix-src-copy.bat ? ? 0 -1 0,0 & block 0 %W%,80,%W%,75 0,76 -1 0 0 f???=2??? & block 0 %W%,2,%W%,75 0,76 00 0 0 a???=2???,2???=2???,f???=2???,e???=a??? & block 0 0,0,%W%,75 0,76 20 & block 0 0,76,%W%,75 0,0" pk
  
  set KEY=!errorlevel!
	
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

del /Q matrix-src-copy.bat>nul 2>nul
endlocal
bg font 6 & mode 80,50
cmdwiz showcursor 1
cls
