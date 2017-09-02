@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe M5nuW15x | %0 %*
rem cmdgfx_input.exe kW15x | %0 %*
set __=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a KEY=0

:REP
	set /p INPUT=
rem	echo %INPUT%

	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("%INPUT%") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, K_KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L )

	if not "%EV_BASE:~0,1%" == "N" (
		if %K_EVENT%==1 echo KEY %K_DOWN% %K_KEY% 
		if %M_EVENT%==1 echo MOUSE %M_X%,%M_Y% LB:%M_LB%[%M_DBL_LB%] RB:%M_RB%[%M_DBL_RB%] WH:%M_WHEEL%
	) else (
		echo ...
	)

	if "%K_KEY%" == "27" if "%K_DOWN%" == "1" goto OUT
goto REP

:OUT
title input:Q
endlocal
