:: Hills parallax scroller : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION
cls & bg font 0
set /a W=240, H=110
mode %W%,%H%

set MIN_ADV_L1=60
set /A HILLS_L1=%W%/%MIN_ADV_L1% + 2
set /A WX=0
for /L %%b in (1,1,%HILLS_L1%) do set WL1_%%b=!WX!&set /A WLW1_%%b=!RANDOM!%%40+30&set /A WLH1_%%b=!WLW1_%%b!+!RANDOM!%%37&set /A WX+=!RANDOM! %% 60 + %MIN_ADV_L1%&set /A WLW1b_%%b=!WLW1_%%b!+5

set MIN_ADV_L2=60
set /A HILLS_L2=%W%/%MIN_ADV_L2% + 2
set /A WX=0
for /L %%b in (1,1,%HILLS_L2%) do set WL2_%%b=!WX!&set /A WLW2_%%b=!RANDOM!%%30+20&set /A WLH2_%%b=!WLW2_%%b!+!RANDOM!%%19+50&set /A WX+=!RANDOM! %% 60 + %MIN_ADV_L2%&set /A WLW2b_%%b=!WLW2_%%b!+2

set SHOW_PLY=1
set /A WMAX=%W%+100
set DIR=1
set PLXPOS=15
set PLYPOS=85
set JMP=0&set JMPV=0

set CNT=0
:SHOWLOOP
set L1=""
set /A ADD=%DIR%*(1+%CNT% %% 2)
for /L %%a in (1,1,%HILLS_L1%) do set /A WL1_%%a-=%ADD% & set CX=!WL1_%%a!& set L1="!L1:~1,-1! & fellipse 2 0 20 !CX!,98,!WLW1b_%%a!,!WLH1_%%a! & fellipse a 0 b1 !CX!,100,!WLW1_%%a!,!WLH1_%%a! & fellipse a 0 db !CX!,120,!WLW1_%%a!,!WLH1_%%a!"& set /A CX+=!WLW1_%%a!*%DIR% & set OUT=0&(if %DIR%==1 if !CX! lss -100 set OUT=1&set /A INDEX=%%a-1&if !INDEX! lss 1 set INDEX=%HILLS_L1%)&(if %DIR%==-1 if !CX! gtr %WMAX% set OUT=1&set /A INDEX=%%a+1&if !INDEX! gtr %HILLS_L1% set INDEX=1)&if !OUT!==1 for %%b in (!INDEX!) do set /A WL1_%%a=!WL1_%%b! + !RANDOM!*%DIR% %% 60 + %MIN_ADV_L1%*%DIR%&set /A WLW1_%%a=!RANDOM!%%40+30&set /A WLW1b_%%a=!WLW1_%%a!+5&set /A WLH1_%%a=!WLW1_%%a!+!RANDOM!%%37
set L2=""
set /A ADD=%DIR%*(1+%CNT% %% 1)
for /L %%a in (1,1,%HILLS_L2%) do set /A WL2_%%a-=%ADD% & set CX=!WL2_%%a!& set L2="!L2:~1,-1! & fellipse 2 0 20 !CX!,99,!WLW2b_%%a!,!WLH2_%%a! & fellipse 2 0 b0 !CX!,100,!WLW2_%%a!,!WLH2_%%a! & fellipse 2 0 db !CX!,110,!WLW2_%%a!,!WLH2_%%a!"& set /A CX+=!WLW2_%%a!*%DIR%& set OUT=0&(if %DIR%==1 if !CX! lss -100 set OUT=1&set /A INDEX=%%a-1&if !INDEX! lss 1 set INDEX=%HILLS_L2%)&(if %DIR%==-1 if !CX! gtr %WMAX% set OUT=1&set /A INDEX=%%a+1&if !INDEX! gtr %HILLS_L2% set INDEX=1)&if !OUT!==1 for %%b in (!INDEX!) do set /A WL2_%%a=!WL2_%%b! + !RANDOM!*%DIR% %% 60 + %MIN_ADV_L2%*%DIR%&set /A WLW2_%%a=!RANDOM!%%30+20&set /A WLW2b_%%a=!WLW2_%%a!+2&set /A WLH2_%%a=!WLW2_%%a!+!RANDOM!%%19+50

set PLY="" & set XFLIP=0&(if %DIR%==-1 set XFLIP=1)&if %SHOW_PLY% == 1 set /A IMG=%CNT% %% 8/4+1&set PLY="image img\mario!IMG!.gxy 0 0 0 0 %PLXPOS%,%PLYPOS% %XFLIP%"
cmdgfx "fbox 1 9 b2 0,0,%W%,10 & fbox 1 9 b1 0,3,%W%,10 & fbox 1 9 b0 0,9,%W%,%H% & %L2:~1,-1% & %L1:~1,-1% & fbox a 0 20 0,95,%W%,50 & fbox a e b2 0,96,%W%,50 & fbox a e b1 0,102,%W%,50 & %PLY:~1,-1%" k
if !ERRORLEVEL!==27 goto ESCAPE
if !ERRORLEVEL!==331 set DIR=-1
if !ERRORLEVEL!==333 set DIR=1
if !ERRORLEVEL!==328 if %JMP%== 0 set JMPV=64&set JMP=1
if %JMP% == 1 set /A PLYPOS-=%JMPV%/32*4&set /A JMPV-=5&if !JMPV! lss -64 set PLYPOS=85&set JMP=0
if !ERRORLEVEL!==32 set /A SHOW_PLY=1-%SHOW_PLY%
set /A CNT+=1
goto SHOWLOOP

:ESCAPE
endlocal
mode 80,50
cls & bg font 6
