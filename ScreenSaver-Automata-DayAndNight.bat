@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cmdwiz setfont 6
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cls & cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%
cmdwiz getdisplaydim h
set /a H=%errorlevel%

set __=.
set /a density=50
call %0 %* | cmdgfx_gdi "fbox 0 0 db & block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)*0" %TOP%m0OW0Sfa:0,0,%W%,%H%r2nt8
set __=
set W=&set H=&set density=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
call :PREP 1
set KEY=

for /l %%a in () do (

	echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - DLL:eextern:dayNight & skip text 9 0 0 [FRAMECOUNT] 2,2 5 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%"
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	if !KEY! == 32 set /a KEY=0 & call :PREP
	if !KEY! == 13 set /a KEY=0 & call :PREP 1
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! gtr 0 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	if !MOUSE_EVENT! == 1 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
)

:PREP
if "%1"=="1" echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)" & goto :eof
echo "cmdgfx: fbox 0 0 db" n
for /l %%a in (1,1,165) do (
	set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!, XS=!RANDOM! %% 600 + 5, YS=!RANDOM! %% 600 + 5, OP=!RANDOM! %% 2 + 2, XP2=XP+XS, YP2=YP+YS"
	if !OP!==0 echo "cmdgfx: fellipse 1 0 db !XP!,!YP!,!XS!,!YS!" n
	if !OP!==1 echo "cmdgfx: fbox 1 0 db !XP!,!YP!,!XS!,!YS!" n
	if !OP!==2 echo "cmdgfx: line 1 0 db !XP!,!YP!,!XP2!,!YP!" n
	if !OP!==3 echo "cmdgfx: line 1 0 db !XP!,!YP!,!XP!,!YP2!" n
)
set /a XP=0, YP=H2
echo "cmdgfx: "
