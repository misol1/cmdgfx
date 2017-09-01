@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe m13uW13Ax | %0 %*
rem cmdgfx_input.exe kuW13Ax | %0 %*
set __=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a KEY=0

:REP
	set /p INPUT=
	rem echo %INPUT%

	set /a NEWMOUSE=0, NEWKEY=0
	
	if "%INPUT:~0,1%" == "M" for /f "tokens=4,6,8,10,12,14,16" %%A in ("%INPUT%") do ( set /a NEWMOUSE=1 & echo MOUSE %%A,%%B LB:%%C[%%E] RB:%%D[%%F] WH:%%G )
	
	if "%INPUT:~0,1%" == "K" for /f "tokens=4,6" %%A in ("%INPUT%") do ( echo KEY %%A %%B & set /a NEWKEY=1, KEY=%%B, KEYDOWN=%%A )
	
	if "%KEY%" == "27" if "%KEYDOWN%" == "1" goto OUT

	if "%INPUT:~0,1%" == "N" echo ...
	rem if "%INPUT:~0,1%" == "E" echo -

goto REP

:OUT
echo Q>inputflags.dat
rem taskkill /F /IM "cmdgfx_input.exe" >nul 2>nul
endlocal
