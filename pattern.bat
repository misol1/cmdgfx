@echo off
setlocal ENABLEDELAYEDEXPANSION
set COL=a
if not "%~1"=="" set COL=%~1
set /a PATTE=3
if not "%~2"=="" set /a PATTE=%~2
if not "%~2"=="" if "%~2"=="0" set PATTE=6
if %PATTE% lss 0 set /a PATTE=3
if %PATTE% gtr 6 set /a PATTE=3
if %PATTE%==1 set INP=b9,ba,bb,bc,c8,c9,ca,cb,cc,cd,ce
if %PATTE%==2 set INP=b0,b1,b2,db,dc,df
if %PATTE%==3 set INP=db,dc,df,fe
if %PATTE%==4 set INP=b3,b4,bf,c0,c1,c2,c3,c4,c5
if %PATTE%==5 set INP=10,11,1e,1f,fe
if %PATTE%==6 set INP=2f,5c
if not "%~2"=="" cmdwiz stringlen "%~2" & if !errorlevel! gtr 2 set /a PATTE=0
if %PATTE%==0 set INP=%~2
cmdwiz stringlen %INP%&set /A NOFC=!ERRORLEVEL!/3+1

cmdwiz getconsoledim w & set /a W=!errorlevel!
cmdwiz getconsoledim h & set /a H=!errorlevel!

set TRANSFORM=& for /l %%a in (1,1,%NOFC%) do set /a I=%%a-1, IP=I*3 & for %%b in (!IP!) do set TRANSFORM=!TRANSFORM!!I!0??=%COL%0!INP:~%%b,2!,
set TRANSFORM=!TRANSFORM!????=%COL%020

if not "%~3"=="" set /a NOFC+=%3

cmdgfx "block 0 0,0,%W%,%H% 0,0 -1 0 0 %TRANSFORM% random()*%NOFC%" K
endlocal
