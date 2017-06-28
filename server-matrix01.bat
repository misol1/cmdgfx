@echo off
bg font 7 & cls & cmdwiz showcursor 0
if defined __ goto :START
set __=.
call %0 %* | cmdgfx_gdi "" kOSf7:0,0,164,140,82,54W18
set __=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=82, WW=W*2
mode %W%,54
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="
set CNT=0&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set HX!CNT!=%%a&set /a CNT+=1

echo "cmdgfx: fbox a 0 00 0,0,%WW%,160"
set STREAM="??00=??00,??40=2?41,??41=a000,??80=2?81,??81=a000,??c0=2?c1,??c1=a?00,????=??++"
set STREAM2="??00=??00,"
for /L %%a in (0,1,192) do set /a "RAND=!RANDOM! %% 200"&set /a "CH1=!RAND! / 16,CH2=!RAND! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set STREAM2="!STREAM2:~1,-1!??!HX%%e!!HX%%f!=??31,"
set STREAM2="%STREAM2:~1,-1%????=??30"
if not "%~1" == "" set STREAM2="-"

set PAL0=-
set PAL1=000000,000000,022476,000000,000000,000000,000000,000000,000000,000000,0872ff
set PAL2=000000,000000,793400,000000,000000,000000,000000,000000,000000,000000,f89200
set /a PALC=0
del /Q EL.dat >nul 2>nul

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set OUT=""
	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 8,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel a 0 !C1!!C2! !X!,0&pixel a 0 !C1!!C3! !X!,1&pixel f 0 !C1!!C2! !X!,2&"
	for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel a 0 00 !X!,0&pixel a 0 00 !X!,1&"

	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 8,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel 2 0 !C1!!C2! !X!,80"
	for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,80&"

	for %%c in (!PALC!) do echo "cmdgfx: !OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 -1 0 0 %STREAM2:~1,-1%& block 0 %W%,2,%W%,75 0,0 00 0 0 %STREAM2:~1,-1%" - !PAL%%c!
	
	if exist EL.dat set /p KEY=<EL.dat & del /Q EL.dat >nul 2>nul

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	if !KEY! == 32 set /a PALC+=1 & if !PALC! gtr 2 set /a PALC=0
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
bg font 6 & mode 80,50 & cls
cmdwiz showcursor 1
echo "cmdgfx: quit"
