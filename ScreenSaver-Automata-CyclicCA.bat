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
call %0 %* | cmdgfx_gdi "" %TOP%m0OW0Sfa:0,0,%W%,%H%nt8
set __=
set W=&set H=&set density=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
set /a MODE=0, pdiv=150, WVAL=0
call :PREP
set KEY=

for /l %%a in () do (

	set XTRP=""& for /l %%b in (1,1,!inject!) do set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!, COL=!RANDOM! %% (!stateNof! + !plusV!)" & set XTRP="!XTRP:~1,-1! & pixel !COL! 0 db !XP!,!YP!"

	echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - DLL:eextern:cyclicCA:!stateNof! & !XTRP:~1,-1! & rem fbox 0 0 0 1,1,70,11 & text f 0 0 [FRAMECOUNT] 2,2 5 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%"
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	if !KEY! == 13 set /a KEY=0 & call :PREP 0
	if !KEY! == 99 set /a KEY=0 & call :PREP & call :RAND_PALETTE
	if !KEY! == 67 set /a KEY=0 & call :PREP
	if !KEY! == 115 set /a KEY=0 & echo !PAL! >> data\cyclicCAPalette.txt
	if !KEY! == 333 set /a KEY=32
	if !KEY! == 32 set /a KEY=0 & set /a MODE+=1 & (if !MODE! gtr 6 set /a MODE=0) & call :PREP
	if !KEY! == 331 set /a KEY=0 & set /a MODE-=1 & (if !MODE! lss 0 set /a MODE=6) & call :PREP
	if !KEY! == 110 set /a KEY=0 & set /a PDIV+=5 & call :PREP
	if !KEY! == 111 set /a KEY=0 & set /a PDIV-=5 & (if !PDIV! lss 5 set /a PDIV=8) & call :PREP
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! == 119 set /a KEY=0, WVAL+=20 & (if !WVAL! gtr 80 set /a WVAL=0 ) & echo "cmdgfx: " W!WVAL!
	if !KEY! == 298 set /a KEY=0
	if !KEY! gtr 0 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	if !MOUSE_EVENT! == 1 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
)

:PREP
set PAL=000000,000080,008000,008080,800000,800080,ffff00,c0c0c0,808080,0000ff,00ff00,00ffff,000000,ff00ff
if "%~1" == "0" set PAL=
set /a stateNof=13, plusV=1, inject=10
if !MODE!==4 set /a plusV=140,inject=60,pdiv=22
if !MODE!==5 set /a plusV=140,inject=30,pdiv=150
if !MODE!==0 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - random()*(!stateNof!+!plusV!)" - !PAL!
if !MODE!==1 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - min(random()*(!stateNof!)+sin(x/100)*cos(y/150)+1.4,!stateNof!)" - !PAL!
if !MODE!==2 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - min(random()*(!stateNof!)+1.5,!stateNof!)" - !PAL!
if !MODE!==3 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - min(random()*(!stateNof!)+5.5,!stateNof!)" - !PAL!
if !MODE! gtr 3 if !MODE! lss 6 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - (perlin(x/!PDIV!,y/!PDIV!))*(!stateNof!+!plusV!)" - !PAL!
if !MODE!==6 echo "cmdgfx: fbox 0 0 db & block 0 0,0,%W%,%H% 0,0 -1 0 0 - random()*(!stateNof!+1)*lss(length(x-%W%/2,y-%H%/2),%H%/2)" - !PAL!
goto :eof

:RAND_PALETTE
set PAL=
set /a BLCH=45 & if !MODE! geq 4 if !MODE! leq 5 set /a BLCH=30
for /l %%d in (1,1,16) do (
	set /a "BL=!RANDOM! %% 100"
	for /l %%e in (1,1,3) do (
		set /a "C=!RANDOM! %% 256"
		if !BL! lss !BLCH! set /a C=0
		set /a "CNT=-1, C1=C/16, C2=C %% 16"
		for %%f in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set /a CNT+=1 & if !CNT!==!C1! set PAL=!PAL!%%f
		set /a CNT=-1 & for %%f in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set /a CNT+=1 & if !CNT!==!C2! set PAL=!PAL!%%f
	)
	set PAL=!PAL!,
)
echo "cmdgfx: " - !PAL!
