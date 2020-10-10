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
set /a W2=W/5, H2=H/5
set /a H+=H2

set __=.
set /a density=10
call %0 %* | cmdgfx_gdi "fbox 0 0 db & skip block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)" %TOP%m0OW0Sfe:0,0,%W%,%H%,%W2%,%H2%r2nt8 000000,ffffff,0088ff,0000bb
set __=
set W=&set H=&set density=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
call :PREP
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
set /a CNT=0, WH=W2/2, HH=H2/2, WEDGE=W2-9, HEDGE=H2-9
set KEY=

for /l %%a in () do (
	set /a "CNT+=1, CHG=CNT %% 6"
	set BS=& if !CHG! gtr 0 set BS=skip

	set /a XMAX=!W!-!W2!, YMAX=!H!-!H2!
	set LAS=skip& if !XP! gtr 0 set LAS=
	set RAS=skip& if !XP! lss !XMAX! set RAS=
	set UAS=skip& if !YP! gtr !H2! set UAS=
	set BAS=skip& if !YP! lss !YMAX! set BAS=
	set ARROWS="!LAS! text c 0 0 \g11 4,!HH! 0 & !RAS! text c 0 0 \g10 !WEDGE!,!HH! 0 & !UAS! text c 0 0 \g1e !WH!,4 0 & !BAS! text c 0 0 \g1f !WH!,!HEDGE! 0"

	echo "cmdgfx: !BS! block 0 0,%h2%,%w%,%h% 0,%h2% -1 0 0 - DLL:eextern:gameOfLife3col & block 0 !XP!,!YP!,%W2%,%H2% 0,0 & skip text 9 0 0 [FRAMECOUNT] 2,2 5 & !ARROWS:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%"
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

	if !KEY! == 333 set /a XP+=20, XMAX=!W!-!W2!, KEY=0 & if !XP! gtr !XMAX! set /a XP=!XMAX!
	if !KEY! == 331 set /a XP-=20, KEY=0 & if !XP! lss 0 set /a XP=0
	if !KEY! == 336 set /a YP+=20, YMAX=!H!-!H2!, KEY=0 & if !YP! gtr !YMAX! set /a YP=!YMAX!
	if !KEY! == 328 set /a YP-=20, KEY=0 & if !YP! lss !H2! set /a YP=!H2!
	if !KEY! == 32 set /a KEY=0 & call :PREP
	if !KEY! == 13 set /a KEY=0 & call :PREP 1
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! gtr 0 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	if !MOUSE_EVENT! == 1 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
)

:PREP
if "%1"=="1" echo "cmdgfx: fbox 0 0 db & block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)" & goto :eof
echo "cmdgfx: fbox 0 0 db" nW0
for /l %%a in (1,1,30) do (
	set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!, XS=!RANDOM! %% 600 + 5, YS=!RANDOM! %% 600 + 5, OP=!RANDOM! %% 4, XP2=XP+XS, YP2=YP+YS"
	if !OP!==0 echo "cmdgfx: ellipse 1 0 db !XP!,!YP!,!XS!,!YS!" n
	if !OP!==1 echo "cmdgfx: box 1 0 db !XP!,!YP!,!XS!,!YS!" n
	if !OP!==2 echo "cmdgfx: line 1 0 db !XP!,!YP!,!XP2!,!YP!" n
	if !OP!==3 echo "cmdgfx: line 1 0 db !XP!,!YP!,!XP!,!YP2!" n
)
set /a XP=0, YP=H2
echo "cmdgfx: " W20
