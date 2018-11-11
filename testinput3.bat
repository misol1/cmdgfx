@echo off
if defined __ goto :START
set __=.
cmdgfx_input.exe M13nW15xR | %0 %* | cmdgfx "" S
set __=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a KEY=0, OLD_M_X=-1, OLD_M_Y=-1, MODE=0
cmdwiz getconsoledim w & set /a W=!errorlevel! & cmdwiz getconsoledim h & set /a H=!errorlevel!

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /p INPUT=

	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L, RESIZED=%%M )

	if "!RESIZED!"=="1" cmdwiz getconsoledim w & set /a W=!errorlevel! & cmdwiz getconsoledim h & set /a H=!errorlevel!
	
	if !M_EVENT!==1 (
		set COL=9
		if !M_LB!==1 set COL=f
		if !M_RB!==1 set COL=1
		if !MODE!==1 echo "cmdgfx: fellipse !COL! 0 db !M_X!,!M_Y!,4,3" f:0,0,!W!,!H!
		if !MODE!==0 if !OLD_M_X! == -1 echo "cmdgfx: pixel !COL! 0 db !M_X!,!M_Y!" f:0,0,!W!,!H!
		if !MODE!==0 if not !OLD_M_X! == -1 echo "cmdgfx: line !COL! 0 db !OLD_M_X!,!OLD_M_Y!,!M_X!,!M_Y!" f:0,0,!W!,!H!
		set /a OLD_M_X=!M_X!, OLD_M_Y=!M_Y!
	)

	if "!KEY!" == "27" set STOP=1
	if "!KEY!" == "32" set /a MODE=1-MODE
	if "!KEY!" == "10" cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	set /a KEY=0
)
if not defined STOP goto LOOP

echo "cmdgfx: quit"
title input:Q
endlocal
