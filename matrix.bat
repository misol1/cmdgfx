@echo off
setlocal ENABLEDELAYEDEXPANSION
set W=120&set /a WW=!W!*2
cmdwiz setfont 2 & mode %W%,65 & cls
cmdwiz setbuffersize %WW% 160
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="
set CNT=0&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set HX!CNT!=%%a&set /a CNT+=1

set COL=0&set P0=0123456789a&set P1=0133456789b&set P2=0143456789c&set P3=0153456789d&set P4=0163456789e
cmdgfx "fbox a 0 00 0,0,%WW%,160"
set STREAM="??00=??00,??40=2?41,??41=a000,??80=2?81,??81=a000,??d0=2?d1,??d1=a?00,????=??++"

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (
	set OUT=""
	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel a 0 !C1!!C2! !X!,0&pixel a 0 !C1!!C3! !X!,1&pixel f 0 !C1!!C2! !X!,2&"
	for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel a 0 00 !X!,0&pixel a 0 00 !X!,1&"

	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% %W%+%W%,CH1=!RANDOM! %% 16,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel 2 0 !C1!!C2! !X!,80"
	for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% %W%+%W%"&set OUT="!OUT:~1,-1!pixel 2 0 00 !X!,80&"

	cmdgfx "!OUT:~1,-1! & block 0 %W%,0,%W%,75 %W%,2 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 %W%,81 -1 0 0 %STREAM:~1,-1% & block 0 %W%,80,%W%,75 0,0 & block 0 %W%,2,%W%,75 0,0 00" pk !P%%c!
	set KEY=!errorlevel!
	if !KEY! == 32 set /A COL+=1&if !COL! gtr 4 set COL=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
