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
call %0 %* | cmdgfx_gdi "" %TOP%m0OW0Sfa:0,0,%W%,%H%r2nt8 000000,0000ff,ffffff
set __=
set W=&set H=&set density=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
set KEY=
call :PREP

for /l %%a in () do (
	echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - DLL:eextern:briansBrain & skip text 9 0 0 [FRAMECOUNT] 2,2 5 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%"
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	if !KEY! == 32 set /a KEY=0 & call :PREP
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! gtr 0 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	if !MOUSE_EVENT! == 1 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
)

:PREP
set /a density=30
set /a "HW=W/2, HH=H/2, SIZE=50, XP=HW-SIZE/2, YP=HH-SIZE/2"
echo "cmdgfx: fbox 0 0 db & block 0 %XP%,%YP%,%SIZE%,%SIZE% %XP%,%YP% -1 0 0 - floor(min(random()*100/(101-%density%),1))*2"
