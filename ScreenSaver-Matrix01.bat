@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cls & cmdwiz setfont 7
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100
cmdwiz getconsoledim sw
set /a W=%errorlevel% + 1
cmdwiz getconsoledim sh
set /a H=%errorlevel% + 2

set __=.
call %0 %* | cmdgfx_gdi "" m0OW18%TOP%Sf7:0,0,%W%,%H%
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION

for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set /a W+=2, H+=2
set /a WW=W*2, HH=H*2, HP=H+1, HM=H-2
set CNT=0&for %%a in (0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f) do set HX!CNT!=%%a&set /a CNT+=1

echo "cmdgfx: fbox 0 0 0" f7:0,0,%W%,%H%
set STREAM="??00=??00,??40=2?41,??41=a000,??80=2?81,??81=a000,??c0=2?c1,??c1=a?00,????=??++"
set /a BC1=2 & set BC2=a
if "%2"=="2" set STREAM="??00=??00,??40=4?41,??41=c000,??80=4?81,??81=c000,??d0=4?d1,??d1=c?00,????=??++"&set BC1=4&set BC2=c

set STREAM2="??00=??00,"
for /L %%a in (0,1,192) do set /a "RAND=!RANDOM! %% 200"&set /a "CH1=!RAND! / 16,CH2=!RAND! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set STREAM2="!STREAM2:~1,-1!??!HX%%e!!HX%%f!=??31,"
set STREAM2="%STREAM2:~1,-1%????=??30"

set PAL0=-
set PAL1=000000,000000,022476,000000,000000,000000,000000,000000,000000,000000,0872ff
set PAL2=000000,000000,793400,000000,000000,000000,000000,000000,000000,000000,f89200
set /a PALC=0

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!PALC!) do (
	set OUT=""
	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 8,CH2=!RANDOM! %% 14 + 2"&set /a "CH3=!CH2!-1, CH4=!CH2!-2"&for %%e in (!CH1!) do for %%f in (!CH2!) do for %%g in (!CH3!) do for %%h in (!CH4!) do set C1=!HX%%e!&set C2=!HX%%f!&set C3=!HX%%g!&set C4=!HX%%h!&set OUT="!OUT:~1,-1!pixel %BC2% 0 !C1!!C2! !X!,0&pixel %BC2% 0 !C1!!C3! !X!,1&pixel f 0 !C1!!C2! !X!,2&"
	for /L %%a in (0,1,10) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel %BC2% 0 00 !X!,0&pixel %BC2% 0 00 !X!,1&"

	for /L %%a in (0,1,1) do set /a "X=!RANDOM! %% !W!+!W!,CH1=!RANDOM! %% 12,CH2=!RANDOM! %% 16"&for %%e in (!CH1!) do for %%f in (!CH2!) do set C1=!HX%%e!&set C2=!HX%%f!&set OUT="!OUT:~1,-1!pixel %BC1% 0 !C1!!C2! !X!,!H!"
	for /L %%a in (0,1,6) do set /a "X=!RANDOM! %% !W!+!W!"&set OUT="!OUT:~1,-1!pixel %BC1% 0 00 !X!,!H!&"
	
	echo "cmdgfx: !OUT:~1,-1! & block 0 !W!,0,!W!,!HM! !W!,2 -1 0 0 %STREAM:~1,-1% & block 0 !W!,!H!,!W!,!HM! !W!,!HP! -1 0 0 %STREAM:~1,-1% & block 0 !W!,!H!,!W!,!HM! 0,0 -1 0 0 %STREAM2:~1,-1%& block 0 !W!,2,!W!,!HM! 0,0 00 0 0 %STREAM2:~1,-1%" FW18f7:0,0,!WW!,!HH!,!W!,!H! !PAL%%c!
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
