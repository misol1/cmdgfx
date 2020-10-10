@echo off

if "%~1"=="_GETANSWER" call :POPUPANSWER %2 %3 %4 & goto :eof

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
call %0 %* | cmdgfx_gdi "fbox 0 0 db" %TOP%m0OW0Sfa:0,0,%W%,%H%nt8Q7000
set __=
set W=&set H=&set density=
cmdwiz fullscreen 0 & cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set EXTRA=&for /L %%a in (1,1,200) do set EXTRA=!EXTRA!xtra
call :MAKERULES stay
call :MAKERULES born

set zoomFont=abcdef
set /a XTXT=2, YTXT=4, HLP=1, FPS=0, CRXTR=0, WVAL=0, slowDeath=0, liveCol=1, updateRate=0, rateCnt=0, XSC=0, YSC=0, zoom=0, WSC=W,HSC=H
set font=!zoomFont:~%zoom%,1!
set TS=&if !HLP!==0 set TS=skip
set FS=&if !FPS!==0 set FS=skip
set LKEY=""& set SCHR="()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|}~"
set KEY=

set /a stayOld=0, bornOld=0
set /a opType=0, initPrep=1, c0pos=0
set OPOUT=""

:: misol map generator (mandala creator : TAB key) 
set /a stay=120,born=68,density=31
::lines+green blob emitters (try FS tab)
set /a stay=87,born=46,density=100,liveCol=7,slowDeath=0


:BEGIN
if !initPrep! == 1 (
	if !opType! == 0 call :PREP 1
	if !opType! == 1 call :PREP
	if !opType! == 2 call :PREP 2
	if !opType! == 3 call :PREP 0 2
)

if not "!PAL!"=="" set COL0=%PAL:~0,7%& echo "cmdgfx: " - !PAL!

for /l %%a in () do (

	set /a rateCnt+=1
	if !rateCnt! geq !updateRate! (
		set XTRP=""
		if !CRXTR! == 1 for /l %%b in (1,1,10) do set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!" & set XTRP="!XTRP:~1,-1! & pixel 1 0 db !XP!,!YP!"

		set /a iflc=-1, ifi=-1
		if not "!inFileLineCount!" == "" set /a iflc=inFileLineCount-1, ifi=inFileIndex
		echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - DLL:eextern:randMoore:!stay!,!born!,!slowDeath!,!liveCol! & !XTRP:~1,-1! & !TS! text b 0 0 !stay!__!born!__!density!__(!slowDeath!_!liveCol!)___(!ifi!/!iflc!) !XTXT!,!YTXT! 5 & !FS! text b 0 0 [FRAMECOUNT] 2,28 5 & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%" f!font!:0,0,%W%,%H%,!WSC!,!HSC!,!XSC!,!YSC!
		set /a rateCnt=0
	) else (
		echo "cmdgfx: skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%" f!font!:0,0,%W%,%H%,!WSC!,!HSC!,!XSC!,!YSC!
	)
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

	if !KEY! neq 0 (
		if !KEY! leq 126 if !KEY! geq 40 set /A MKEY=!KEY!-40+1 & for %%M in (!MKEY!) do set LKEY="!SCHR:~%%M,1!"
	
		if !KEY! == 13 set /a stayOld=stay, bornOld=born & call :MAKERULES stay & call :MAKERULES born & call :PREP 1
		if !LKEY! == "<" set /a stay=stayOld, born=bornOld & call :PREP 1
		if !KEY! == 32 call :PREP 1
		if !KEY! == 9 call :PREP
		if !LKEY! == "." call :PREP 0 2
		if !LKEY! == "," call :PREP 2
		if !LKEY! == "f" set /a FPS=1-FPS & set FS=&if !FPS!==0 set FS=skip
		
		if !KEY! geq 48 if !KEY! leq 57 set /a "density=(KEY-47)*10" & call :PREP 1
		if !KEY! == 333 set /a "density+=1" & call :PREP 1
		if !KEY! == 331 set /a "density-=1" & call :PREP 1

		if !KEY! == 328 call :GETPATTERNFROMFILE -1
		if !KEY! == 336 call :GETPATTERNFROMFILE 1
		if !LKEY! == "g" if not "!inFileLineCount!" == "" call :GETPATTERNINDEX & call :GETPATTERNFROMFILE 0

		if !LKEY! == "a" set /a "stay-=1" & (if !stay! lss 0 set /a stay=255) & call :PREP 1
		if !LKEY! == "A" set /a "stay+=1" & (if !stay! gtr 255 set /a stay=0) & call :PREP 1
		if !LKEY! == "b" set /a "born-=1" & (if !born! lss 0 set /a born=255) & call :PREP 1
		if !LKEY! == "B" set /a "born+=1" & (if !born! gtr 255 set /a born=0) & call :PREP 1

		if !LKEY! == "Z" call :ADJUSTZOOM 1
		if !LKEY! == "z" call :ADJUSTZOOM -1
		if !LKEY! == "X" if !zoom! gtr 0 set /a "XSC+=10, XMAX=W-WSC" & if !XSC! geq !XMAX! set /a XSC=XMAX-1
		if !LKEY! == "x" if !zoom! gtr 0 set /a "XSC-=10" & if !XSC! lss 0 set /a XSC=0
		if !LKEY! == "Y" if !zoom! gtr 0 set /a "YSC+=10, YMAX=H-HSC" & if !YSC! geq !YMAX! set /a YSC=YMAX-1
		if !LKEY! == "y" if !zoom! gtr 0 set /a "YSC-=10" & if !YSC! lss 0 set /a YSC=0

		if !LKEY! == "c" call :RAND_PALETTE
		if !LKEY! == "C" if not "!PAL!"=="" (if !c0pos!==0 set PAL=000000,!PAL:~7!) & (if !c0pos!==1 set PAL=ffffff,!PAL:~7!) & (if !c0pos!==2 set PAL=!COL0!!PAL:~7!) & echo "cmdgfx: " - !PAL! & set /a c0pos+=1 & if !c0pos! gtr 2 set /a c0pos=0
		if !LKEY! == "d" set PAL=& echo "cmdgfx: " - -
		if !LKEY! == "P" echo !PAL! >> data\randMoorePalette.txt
		if !LKEY! == "s" call :SAVE_CURRENT
		if !LKEY! == "S" call :SAVE_CURRENT 1

		if !LKEY! == "h" set /a HLP=1-HLP & set TS=&if !HLP!==0 set TS=skip
		if !LKEY! == "r" set /a CRXTR=1-CRXTR
		if !LKEY! == "w" set /a WVAL=10, updateRate+=1 & echo "cmdgfx: " W!WVAL!
		if !LKEY! == "W" set /a updateRate=0, WVAL=0 & echo "cmdgfx: " W!WVAL!

		if !LKEY! == "l" set /a "liveCol-=1" & if !liveCol! lss 1 set /a liveCol=1
		if !LKEY! == "L" set /a "liveCol+=1" & if !liveCol! gtr 15 set /a liveCol=15

		if !LKEY! == "m" set /a "slowDeath=1-slowDeath"
		
		if !LKEY! == "p" cmdwiz getch
		
		if !KEY! == 27 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	)
	set /a KEY=0
	set LKEY=""
)

:PREP
set OPOUT=""
if "%1"=="1" set /a opType=0 & echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)*!liveCol!" & goto :eof
echo "cmdgfx: fbox 0 0 db" nW0
if "%1"=="2" set /a opType=2 & set /a SIZ=20 + !random! %% 80, WH=w/2-SIZ/2,HH=h/2-SIZ/2 & echo "cmdgfx: block 0 !WH!,!HH!,!SIZ!,!SIZ! !WH!,!HH! -1 0 0 - min(random()*100/(101-%density%),1)*!liveCol!" & goto :eof
if "%1"=="" ( 
	set /a opType=1
	for /l %%a in (1,1,65) do (
		set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!, XS=!RANDOM! %% 100 + 5, YS=!RANDOM! %% 100 + 5, OP=!RANDOM! %% 4, XP2=XP+XS, YP2=YP+YS"
		if !OP!==0 echo "cmdgfx: fellipse !liveCol! 0 db !XP!,!YP!,!XS!,!YS!" n
		if !OP!==1 echo "cmdgfx: fbox !liveCol! 0 db !XP!,!YP!,!XS!,!YS!" n
		if !OP!==2 echo "cmdgfx: line !liveCol! 0 db !XP!,!YP!,!XP2!,!YP!" n
		if !OP!==3 echo "cmdgfx: line !liveCol! 0 db !XP!,!YP!,!XP!,!YP2!" n
	)
) else (
	set /a opType=3
	for /l %%a in (1,1,1) do (
		set /a "XP=!W!/2, YP=!H!/2, XS=!RANDOM! %% 500 + 400, YS=!RANDOM! %% 200 + 300, OP=!RANDOM! %% 4"
		if !OP!==0 echo "cmdgfx: fellipse !liveCol! 0 db !XP!,!YP!,!YS!,!YS!" n & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fellipse !liveCol! 0 db !XP!,!YP!,!YS!,!YS!\" n"
		if !OP!==1 echo "cmdgfx: fbox !liveCol! 0 db !XP!,!YP!,!YS!,!YS!" nV & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fbox !liveCol! 0 db !XP!,!YP!,!YS!,!YS!\" nV"
		if !OP!==2 echo "cmdgfx: fellipse !liveCol! 0 db !XP!,!YP!,!XS!,!YS!" n & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fellipse !liveCol! 0 db !XP!,!YP!,!XS!,!YS!\" n"
		if !OP!==3 echo "cmdgfx: fbox !liveCol! 0 db !XP!,!YP!,!XS!,!YS!" nV & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fbox !liveCol! 0 db !XP!,!YP!,!XS!,!YS!\" nV"
	)
)	
set /a XP=0, YP=H2
echo "cmdgfx: " W!WVAL!
goto :eof

:MAKERULES
set /a VD=0
set /a "BITC=!RANDOM! %% 3 + 2"
for /l %%a in (1,1,8) do (
	set /a "BITT=!RANDOM! %% !BITC!"
	if !BITT! gtr 0 set /a BIT=0
	if !BITT! equ 0 set /a BIT=1
	set /a "VD=(VD << 1) | BIT"
)
set %1=!VD!
set /a c0pos=0
goto :eof

:RAND_PALETTE
set PAL=
set /a BLCH=0
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
set COL0=%PAL:~0,7%
set /a c0pos=0
goto :eof

:SAVE_CURRENT
set /a savePal=0
if "%~1" == "1" if not "!PAL!"=="" set /a savePal=1
set WVS=& if !WVAL! neq 0 set WVS=,WVAL=!WVAL!,updateRate=!updateRate!
if !savePal! == 0 cmdwiz print "::set /a stay=!stay!,born=!born!,density=!density!,liveCol=!liveCol!,slowDeath=!slowDeath!,opType=!opType!%WVS% !OPOUT:~1,-1!\n" >> data\randMooreSet.txt
if !savePal! == 1 cmdwiz print "::set /a stay=!stay!,born=!born!,density=!density!,liveCol=!liveCol!,slowDeath=!slowDeath!,opType=!opType!%WVS% !OPOUT:~1,-1!& set PAL=!PAL!\n" >> data\randMooreSet.txt
set WVS=
goto :eof

:GETPATTERNFROMFILE
set inFile=data\randMoore-data.txt
if not "%inFileIndex%" == "" set /a inFileIndex += %1
if "%inFileIndex%" == "" (
	set /a inFileIndex=0
	set /a inFileLineCount=0
	for /f "tokens=*" %%a in ('type "%inFile%"') do set /a inFileLineCount+=1
)
if %inFileIndex% geq !inFileLineCount! set /a inFileIndex=0
if %inFileIndex% lss 0 set /a inFileIndex=!inFileLineCount!-1
set /a cnt=0, initPrep=1, WVAL=0, updateRate=0, opType=0, slowDeath=0, liveCol=1, XTXT=2, YTXT=4
set PAL=
for /f "tokens=*" %%a in ('type "%inFile%"') do (if !cnt! == !inFileIndex! set pattern="%%a")& set /a cnt+=1
echo "cmdgfx: fbox 0 0 db" - - -
%pattern:~1,-1%
if not "!PAL!"=="" set COL0=%PAL:~0,7%& echo "cmdgfx: " - !PAL!

set /a WVAL=0, updateRate=0 & echo "cmdgfx: " W!WVAL!

if !initPrep! == 1 (
	if !opType! == 0 call :PREP 1
	if !opType! == 1 call :PREP
	if !opType! == 2 call :PREP 2
	if !opType! == 3 call :PREP 0 2
)
set pattern=
set /a c0pos=0
goto :eof

:GETPATTERNINDEX
set /a KEY=0,VAL=0
:KEYLOOP
echo "cmdgfx: skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%"
if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22"
if !KEY! geq 48 if !KEY! leq 57 set /a "VAL=VAL*10+(KEY-48), KEY=0"
if not !KEY! == 13 goto :KEYLOOP
set /a inFileIndex = VAL, KEY=0
if %inFileIndex% geq !inFileLineCount! set /a inFileIndex=0
if %inFileIndex% lss 0 set /a inFileIndex=!inFileLineCount!-1
goto :eof

:ADJUSTZOOM
set /a "zoom+=%1"
if !zoom! gtr 5 set /a zoom=5
if !zoom! lss 0 set /a zoom=0
set /a "WSC=W/(zoom+1),HSC=H/(zoom+1)"
set font=!zoomFont:~%zoom%,1!
set /a "XMAX=W-WSC" & if !XSC! geq !XMAX! set /a XSC=XMAX-1
set /a "YMAX=H-HSC" & if !YSC! geq !YMAX! set /a YSC=YMAX-1
goto :eof
