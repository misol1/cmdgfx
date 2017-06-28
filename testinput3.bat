@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe M13nW15x | %0 %* | cmdgfx "" S
set __=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a KEY=0, OLD_M_X=-1, OLD_M_Y=-1

:REP
	set /p INPUT=
rem	echo %INPUT%

	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("%INPUT%") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, K_KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L )

	if not "%EV_BASE:~0,1%" == "N" if %M_EVENT%==1 (
		set /a COL=9
		if !M_LB!==1 set COL=f
		if !M_RB!==1 set /a COL=1
		if !OLD_M_X! == -1 echo "cmdgfx: pixel !COL! 0 db %M_X%,%M_Y%"
		if not !OLD_M_X! == -1 echo "cmdgfx: line !COL! 0 db %OLD_M_X%,%OLD_M_Y%,%M_X%,%M_Y%"
		set /a OLD_M_X=%M_X%, OLD_M_Y=%M_Y%
	)

	if "%K_KEY%" == "27" goto OUT
goto REP

:OUT
echo "cmdgfx: quit"
echo Q>inputflags.dat
endlocal
