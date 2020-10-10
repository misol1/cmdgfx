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
set /a WW=W*2

set __=.
set /a density=50
call %0 %* | cmdgfx_RGB_32 "fbox 0 0 db" %TOP%m0OW0Sfa:0,0,%WW%,%H%nt8
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
set /a XTXT=2, YTXT=4, HLP=1, FPS=0, CRXTR=0, WVAL=0, slowDeath=0, liveCol=1, updateRate=0, rateCnt=0, XSC=0, YSC=0, zoom=0, WSC=W,HSC=H,WW=W*2
set font=!zoomFont:~%zoom%,1!
set TS=&if !HLP!==0 set TS=skip
set FS=&if !FPS!==0 set FS=skip
set LKEY=""& set SCHR="()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|}~"
set KEY=

set /a stayOld=0, bornOld=0, NH=3, initPrep=1, c0pos=0, opType=0, stateMethod=1, keyMode=0, wrap=1, WMM=W-1, HMM=H-1
set edgeS=skip&if !wrap!==0 set edgeS=
set OPOUT=""


::Disintegrate/explode
set /a stay=33145,born=8244,density=60,liveCol=5,slowDeath=1,NH=3


:BEGIN

set /a CNT=-1, MAXBITS=8 & for %%a in (8 12 12 16 20 24 16 12 10 10 12 10 10 16) do set /a CNT+=1 & if !CNT!==!NH! set /a MAXBITS=%%a
set /a MAXVAL="(1 << (!MAXBITS!))-1"

call :EXECUTEPREP

call sindef.bat
set /a XMUL=400,YMUL=250,XMUL2=50,YMUL2=60,SCNT=0, BOB=0, bobType=0

::Color output settings.  To use negative P and Neg values, add 128 to value, like: redP=(4+128) to mean -4
set /a "redP=(6), greenP=(6), blueP=(6), colChange=2" & rem colChange=0 =add neighbours*redP to r, 1=add state*redP, 2=add 1*redP,  3=add (neighbours^state)*redP,  4-7 undefined/like 0
set /a "redNeg=(2), greenNeg=(2), blueNeg=(2)"
set /a "redAnd=1, greenAnd=2, blueAnd=4"
set /a "stayPatt=0, stayVal=1" & rem 0=decrease all colors, 1=decrease colors if b>=stayVal, 2 if r>=stayVal, 3 if g>=stayVal, 4 if b>=val for red/green, r>=val for blue, 5=0 but grayscale, 6=5 but not gray neg,  7 undefined
set /a "topClamp=1, bottomClamp=1"


for /l %%a in () do (

	set bobS=""
	if !BOB! == 1 (
		set /a SCNT-=1
		if !SCNT! leq 0 (
			set /a "SC+=1, CC+=2, SC2+=2, CC2+=1, RAND=!RANDOM! %% 1000"
			if !RAND! lss 100 set /a SC2+=1
			if !RAND! gtr 900 set /a CC-=1
			if !RAND! gtr 500 if !RAND! lss 600 set /a SC+=1
				
			for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS=W/2+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A4!*31416/180%*!XMUL2!>>!SHR!), YPOS=H/2+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A3!*31416/180%*!YMUL2!>>!SHR!)"
			set /a SCNT=0
		)
		set /a rad=10, diam=rad*2

		if !bobType!==0 set /a XPOS-=rad,YPOS-=rad & set bobS="block 0 !XPOS!,!YPOS!,!diam!,!diam! !XPOS!,!YPOS! -1 0 0 - or(col(x,y),shl(!liveCol!*lss(length(x-!rad!,y-!rad!),!rad!),24))"& rem slower but easier
		if !bobType!==1 set /a XPOS-=rad,YPOS-=rad & set bobS="block 0 !XPOS!,!YPOS!,!diam!,!diam! !XPOS!,!YPOS! -1 0 0 - or(fgcol(x,y),!liveCol!*lss(length(x-!rad!,y-!rad!),!rad!))"& rem NICE! with the blue sponge
		if !bobType!==2 set bobS="fellipse !liveColCh!000000 0 db !XPOS!,!YPOS!,!rad!,!rad!"
		if !bobType!==3 set bobS="ipoly !liveColCh!000000 0 db 1 !XPOS!,!YPOS!,-5,-5,5,-5,5,5,-5,5"& rem Cube. Make an ipoly of a circle for faster version of bobType 0
	)

	set /a rateCnt+=1
	if !rateCnt! geq !updateRate! (
		set XTRP=""
		if !CRXTR! == 1 for /l %%b in (1,1,10) do set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!" & set XTRP="!XTRP:~1,-1! & pixel !liveColCh!000000 0 db !XP!,!YP!"

		set /a iflc=-1, ifi=-1
		if not "!inFileLineCount!" == "" set /a iflc=inFileLineCount-1, ifi=inFileIndex

		set /a "colMuls=redP | (greenP<<8) | (blueP<<16) | (slowDeath<<24) | (NH<<25), colNegs=redNeg | (greenNeg<<8) | (blueNeg<<16) | (liveCol<<24)"
		set /a "options=colChange | (redAnd<<3) | (greenAnd<<6) | (blueAnd<<9)"
		set /a "options=options | (topClamp<<12) | (bottomClamp<<13) | (stayPatt<<14) | (stayVal<<17)"
		if !keyMode! == 0 set stateText="!stay!__!born!__!density!__(!slowDeath!_!liveCol!)___(!ifi!/!iflc!)"
		if !keyMode! == 1 set stateText="COL:_!colChange!__!redP!_!greenP!_!blueP!__!redNeg!_!greenNeg!_!blueNeg!__!redAnd!_!greenAnd!_!blueAnd!__!stayPatt!_!stayVal!"

		echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - DLL:eextern:randMooreExtended32compact:!stay!,!born!,!colMuls!,!colNegs!,!options! & !XTRP:~1,-1! & !TS! text b 0 0 !stateText:~1,-1! !XTXT!,!YTXT! 5 & !FS! text b 0 0 [FRAMECOUNT] 2,28 5 & !edgeS! box 000000 0 db 0,0,!wmm!,!hmm! & !bobS:~1,-1! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%" v-Vf!font!:0,0,%WW%,%H%,!WSC!,!HSC!,!XSC!,!YSC!
		
		set /a rateCnt=0
	) else (
		echo "cmdgfx: skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%" f!font!:0,0,%WW%,%H%,!WSC!,!HSC!,!XSC!,!YSC!
	)
	
	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"

	if !KEY! neq 0 (
		if !KEY! leq 126 if !KEY! geq 40 set /A MKEY=!KEY!-40+1 & for %%M in (!MKEY!) do set LKEY="!SCHR:~%%M,1!"
	
		if !keyMode! == 1 (
			if !LKEY! == "b" set /a "blueP-=1, KEY=0"&set LKEY=""
			if !LKEY! == "B" set /a "blueP+=1, KEY=0"&set LKEY=""
			if !LKEY! == "r" set /a "redP-=1, KEY=0"&set LKEY=""
			if !LKEY! == "R" set /a "redP+=1, KEY=0"&set LKEY=""
			if !LKEY! == "g" set /a "greenP-=1, KEY=0"&set LKEY=""
			if !LKEY! == "G" set /a "greenP+=1, KEY=0"&set LKEY=""
			if !LKEY! == "a" set /a "stayPatt-=1, KEY=0"&set LKEY=""&if !stayPatt! lss 0 set /a stayPatt=6
			if !LKEY! == "A" set /a "stayPatt+=1, KEY=0"&set LKEY=""&if !stayPatt! gtr 6 set /a stayPatt=0
			if !LKEY! == "v" set /a "stayVal-=1, KEY=0"&set LKEY=""&if !stayVal! lss 0 set /a stayVal=255
			if !LKEY! == "V" set /a "stayVal+=1, KEY=0"&set LKEY=""&if !stayVal! gtr 255 set /a stayVal=0
			if !LKEY! == "c" set /a "colChange-=1, KEY=0"&set LKEY=""&if !colChange! lss 0 set /a colChange=3
			if !LKEY! == "C" set /a "colChange+=1, KEY=0"&set LKEY=""&if !colChange! gtr 3 set /a colChange=0
			if !LKEY! == "t" set /a "topClamp=1-topClamp, KEY=0"&set LKEY=""
			if !LKEY! == "T" set /a "bottomClamp=1-bottomClamp, KEY=0"&set LKEY=""

			if !LKEY! == "q" set /a "redAnd-=1, KEY=0"&set LKEY=""&if !redAnd! lss 0 set /a redAnd=7
			if !LKEY! == "Q" set /a "redAnd+=1, KEY=0"&set LKEY=""&if !redAnd! gtr 7 set /a redAnd=0
			if !LKEY! == "w" set /a "greenAnd-=1, KEY=0"&set LKEY=""&if !greenAnd! lss 0 set /a greenAnd=7
			if !LKEY! == "W" set /a "greenAnd+=1, KEY=0"&set LKEY=""&if !greenAnd! gtr 7 set /a greenAnd=0
			if !LKEY! == "e" set /a "blueAnd-=1, KEY=0"&set LKEY=""&if !blueAnd! lss 0 set /a blueAnd=7
			if !LKEY! == "E" set /a "blueAnd+=1, KEY=0"&set LKEY=""&if !blueAnd! gtr 7 set /a blueAnd=0
		
			if !LKEY! == "u" set /a "redNeg-=1, KEY=0"&set LKEY=""
			if !LKEY! == "U" set /a "redNeg+=1, KEY=0"&set LKEY=""
			if !LKEY! == "i" set /a "greenNeg-=1, KEY=0"&set LKEY=""
			if !LKEY! == "I" set /a "greenNeg+=1, KEY=0"&set LKEY=""
			if !LKEY! == "o" set /a "blueNeg-=1, KEY=0"&set LKEY=""
			if !LKEY! == "O" set /a "blueNeg+=1, KEY=0"&set LKEY=""
		)
		if !LKEY! == "k" set /a keyMode=1-keyMode

		if !KEY! == 13 set /a stayOld=stay, bornOld=born & call :MAKERULES stay & call :MAKERULES born & call :PREP 1
		if !LKEY! == "<" set /a stay=stayOld, born=bornOld & call :PREP 1
		if !KEY! == 32 call :PREP 1
		if !KEY! == 9 call :PREP
		if !LKEY! == "." call :PREP 0 2
		if !LKEY! == "," call :PREP 2
		if !LKEY! == ":" call :PREP 4
		if !LKEY! == "f" set /a FPS=1-FPS & set FS=&if !FPS!==0 set FS=skip
		
		if !KEY! geq 48 if !KEY! leq 57 set /a "density=(KEY-47)*10" & call :PREP 1
		if !KEY! == 333 set /a "density+=1" & call :PREP 1
		if !KEY! == 331 set /a "density-=1" & call :PREP 1

		if !KEY! == 328 call :GETPATTERNFROMFILE -1
		if !KEY! == 336 call :GETPATTERNFROMFILE 1
		if !KEY! == 408 call :GETPATTERNFROMFILE -1 colSkip
		if !KEY! == 416 call :GETPATTERNFROMFILE 1 colSkip
		if !LKEY! == "g" if not "!inFileLineCount!" == "" call :GETPATTERNINDEX & call :GETPATTERNFROMFILE 0
		
		if !LKEY! == "n" call :GETCOLPATTERNFROMFILE -1
		if !LKEY! == "N" call :GETCOLPATTERNFROMFILE 1

		if !LKEY! == "d" call :SETORGPAL
		if !LKEY! == "D" if not "!inFileLineCount!" == "" call :GETPATTERNFROMFILE 0 skip

		if !LKEY! == "a" set /a "stay-=1" & (if !stay! lss 0 set /a stay=!MAXVAL!) & call :PREP 1
		if !LKEY! == "A" set /a "stay+=1" & (if !stay! gtr !MAXVAL! set /a stay=0) & call :PREP 1
		if !LKEY! == "b" set /a "born-=1" & (if !born! lss 0 set /a born=!MAXVAL!) & call :PREP 1
		if !LKEY! == "B" set /a "born+=1" & (if !born! gtr !MAXVAL! set /a born=0) & call :PREP 1

		if !LKEY! == "s" call :SAVE_CURRENT
		if !LKEY! == "S" call :SAVE_COLPATT & call :SAVE_CURRENT "!colPatt!"
		if !LKEY! == "P" call :SAVE_COLPATT 1
	
		if !LKEY! == "Z" call :ADJUSTZOOM 1
		if !LKEY! == "z" call :ADJUSTZOOM -1
		if !LKEY! == "X" if !zoom! gtr 0 set /a "XSC+=15, XMAX=W-WSC" & if !XSC! geq !XMAX! set /a XSC=XMAX-1
		if !LKEY! == "x" if !zoom! gtr 0 set /a "XSC-=15" & if !XSC! lss 0 set /a XSC=0
		if !LKEY! == "Y" if !zoom! gtr 0 set /a "YSC+=15, YMAX=H-HSC" & if !YSC! geq !YMAX! set /a YSC=YMAX-1
		if !LKEY! == "y" if !zoom! gtr 0 set /a "YSC-=15" & if !YSC! lss 0 set /a YSC=0

		if !LKEY! == "h" set /a HLP=1-HLP & set TS=&if !HLP!==0 set TS=skip
		if !LKEY! == "r" set /a CRXTR=1-CRXTR
		if !LKEY! == "w" set /a WVAL=10, updateRate+=1 & echo "cmdgfx: " W!WVAL!
		if !LKEY! == "W" set /a updateRate=0, WVAL=0 & echo "cmdgfx: " W!WVAL!
		if !KEY! == 23 set /a wrap=1-wrap & set edgeS=skip&if !wrap!==0 set edgeS=& rem ^W

		if !LKEY! == "l" set /a "liveCol-=1" & if !liveCol! lss 1 set /a liveCol=1
		if !LKEY! == "L" set /a "liveCol+=1" & rem if !liveCol! gtr 15 set /a liveCol=15

		if !LKEY! == "m" set /a "slowDeath=1-slowDeath"

		if !LKEY! == "n" set /a NH-=1 & if !NH! lss 0 set /a NH=3
		if !LKEY! == "N" set /a NH+=1 & if !NH! gtr 3 set /a NH=0
		
		if !KEY! == 2 set /a BOB=1-BOB & rem ^B
		if !KEY! == 4 set /a bobType+=1 & if !bobType! gtr 3 set /a bobType=0 & rem ^D

		if !LKEY! == "p" cmdwiz getch
		
		if !KEY! == 27 cmdwiz delay 100 & echo "cmdgfx: quit" & exit
	)
	set /a KEY=0
	set LKEY=""
)

:PREP
set OPOUT=""
set /a HIB=liveCol/16,cnt=-1 & for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set /a cnt+=1 & if !cnt! == !HIB! set liveColCh=%%a
set /a LOB=liveCol-HIB*16,cnt=-1 & for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set /a cnt+=1 & if !cnt! == !LOB! set liveColCh=!liveColCh!%%a
if "%1"=="1" set /a opType=0 & echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - min(random()*100/(101-%density%),1)*!liveCol!" & goto :PREPSTEP2
echo "cmdgfx: fbox 0 0 db" nW0
if "%1"=="2" set /a opType=2 & set /a SIZ=20 + !random! %% 80, WH=w/2-SIZ/2,HH=h/2-SIZ/2 & echo "cmdgfx: block 0 !WH!,!HH!,!SIZ!,!SIZ! !WH!,!HH! -1 0 0 - min(random()*100/(101-%density%),1)*!liveCol!" & goto :PREPSTEP2
if "%1"=="" ( 
	set /a opType=1
	for /l %%a in (1,1,65) do (
		set /a "XP=!RANDOM! %% !W!, YP=!RANDOM! %% !H!, XS=!RANDOM! %% 100 + 5, YS=!RANDOM! %% 100 + 5, OP=!RANDOM! %% 4, XP2=XP+XS, YP2=YP+YS"
		if !OP!==0 echo "cmdgfx: fellipse 0000!liveColCh! 0 db !XP!,!YP!,!XS!,!YS!" n
		if !OP!==1 echo "cmdgfx: fbox 0000!liveColCh! 0 db !XP!,!YP!,!XS!,!YS!" n
		if !OP!==2 echo "cmdgfx: line 0000!liveColCh! 0 db !XP!,!YP!,!XP2!,!YP!" n
		if !OP!==3 echo "cmdgfx: line 0000!liveColCh! 0 db !XP!,!YP!,!XP!,!YP2!" n
	)
) else if "%1"=="4" (
	set /a opType=4
	for /l %%a in (1,1,1) do (
		set /a "XP=!W!/2, YP=!H!/2, XS=!RANDOM! %% 300 + 100, YS=!RANDOM! %% 200 + 200, NOFP=!RANDOM! %% 8 + 3, PMUL=!RANDOM! %% 3 + 1"
		set OP=ipoly 0000!liveColCh! 0 db 0 
		set /a "SC=0,CC=0,SCP=360/NOFP*PMUL,SCS=!RANDOM! %% 360,SCSC=!RANDOM! %% 3"
		if !SCSC! == 0 set /a SC=!SCS!
		for /l %%b in (1,1,!NOFP!) do (
			set /a "SC+=SCP*0, CC=SC+90"
			for %%d in (!SC!) do for %%e in (!CC!) do set /a A1=%%d,A2=%%e & set /a "XPOS=XP+(%SINE(x):x=!A1!*31416/180%*!XS!>>!SHR!), YPOS=YP+(%SINE(x):x=!A2!*31416/180%*!XS!>>!SHR!)"
			set OP=!OP!!XPOS!,!YPOS!,
			set /a "SC+=SCP"
		)
		echo "cmdgfx: !OP!" n-v
		rem echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - eq(col(x,y-1)*col(x,y+1)*col(x-1,y)*col(x+1,y),0)*col(x,y)" n & rem Turn poly into polyline. A bit faster
		set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: !OP!\" n-v"
		set OP=
	)
) else (
	set /a opType=3
	for /l %%a in (1,1,1) do (
		set /a "XP=!W!/2, YP=!H!/2, XS=!RANDOM! %% 500 + 400, YS=!RANDOM! %% 200 + 300, OP=!RANDOM! %% 4"
		if !OP!==0 echo "cmdgfx: fellipse 0000!liveColCh! 0 db !XP!,!YP!,!YS!,!YS!" n & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fellipse 00000!liveCol! 0 db !XP!,!YP!,!YS!,!YS!\" n"
		if !OP!==1 echo "cmdgfx: fbox 0000!liveColCh! 0 db !XP!,!YP!,!YS!,!YS!" nV & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fbox 00000!liveCol! 0 db !XP!,!YP!,!YS!,!YS!\" nV"
		if !OP!==2 echo "cmdgfx: fellipse 0000!liveColCh! 0 db !XP!,!YP!,!XS!,!YS!" n & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fellipse 00000!liveCol! 0 db !XP!,!YP!,!XS!,!YS!\" n"
		if !OP!==3 echo "cmdgfx: fbox 0000!liveColCh! 0 db !XP!,!YP!,!XS!,!YS!" nV & set OPOUT="& set /a initPrep=0 & echo \"cmdgfx: fbox 00000!liveCol! 0 db !XP!,!YP!,!XS!,!YS!\" nV"
	)
)	
set /a XP=0, YP=H2
:PREPSTEP2
if !stateMethod!==0 echo "cmdgfx: " W!WVAL!
if !stateMethod!==1 echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - shl(col(x,y),24)" W!WVAL!
goto :eof

:MAKERULES
set /a VD=0
set /a "BITC=!RANDOM! %% 3 + 2"
for /l %%a in (1,1,!MAXBITS!) do (
	set /a "BITT=!RANDOM! %% !BITC!"
	if !BITT! gtr 0 set /a BIT=0
	if !BITT! equ 0 set /a BIT=1
	set /a "VD=(VD << 1) | BIT"
)
set %1=!VD!
set /a c0pos=0
goto :eof


:SAVE_CURRENT
set WVS=& if !WVAL! neq 0 set WVS=,WVAL=!WVAL!,updateRate=!updateRate!
set CPATT=""
if not "%~1" == "" set CPATT=",  %~1"
cmdwiz print "::set /a stay=!stay!,born=!born!,density=!density!,liveCol=!liveCol!,slowDeath=!slowDeath!,NH=!NH!,wrap=!wrap!,opType=!opType!%CPATT:~1,-1%%WVS% !OPOUT:~1,-1!\n" >> data\randMoore-RGB-Extended-Set.txt
set WVS=&set CPATT=
goto :eof



:GETPATTERNFROMFILE
set inFile=data\randMooreRGB-Extended-data.txt
if not "%inFileIndex%" == "" set /a inFileIndex += %1
if "%inFileIndex%" == "" (
	set /a inFileIndex=0
	set /a inFileLineCount=0
	for /f "tokens=*" %%a in ('type "%inFile%"') do set /a inFileLineCount+=1
)
if %inFileIndex% geq !inFileLineCount! set /a inFileIndex=0
if %inFileIndex% lss 0 set /a inFileIndex=!inFileLineCount!-1
set /a cnt=0, initPrep=1, orgPal=0
if not "%~2" == "skip" set /a WVAL=0, updateRate=0, opType=0, slowDeath=0, liveCol=1, XTXT=2, YTXT=4
for /f "tokens=*" %%a in ('type "%inFile%"') do (if !cnt! == !inFileIndex! set pattern="%%a")& set /a cnt+=1
echo "cmdgfx: fbox 0 0 db" - - -
set /a WH=W/2,HH=H/2
set pattern=!pattern:960,540,=%WH%,%HH%,!
if "%~2" == "skip" set pattern=!pattern:set=cmdwiz delay 0!& call :SKIPCHK !pattern!
if "%~2" == "colSkip" for %%c in (redP greenP blueP colChange redNeg greenNeg blueNeg redAnd greenAnd blueAnd stayPatt stayVal topClamp bottomClamp) do set pattern=!pattern:%%c=junk!
%pattern:~1,-1%
set edgeS=skip&if !wrap!==0 set edgeS=
if !orgPal! == 1 call :SETORGPAL

set /a WVAL=0, updateRate=0 & echo "cmdgfx: " W!WVAL!
rem if !srand! geq 0 echo "cmdgfx: " Q!srand! & cmdwiz delay 300
call :EXECUTEPREP
set pattern=
set /a c0pos=0
goto :eof

:SKIPCHK
cmdwiz stringfind %1 "initPrep"
if !errorlevel! geq 0 set /a initPrep=0
goto :eof

:SETORGPAL
set /a "redP=(6), greenP=(6), blueP=(6), colChange=2, redNeg=(2), greenNeg=(2), blueNeg=(2), redAnd=1, greenAnd=2, blueAnd=4, stayPatt=0, stayVal=1, topClamp=1, bottomClamp=1"
goto :eof

:GETCOLPATTERNFROMFILE
set inFile2=data\randMooreColPattern.txt
if not "%inFileIndex2%" == "" set /a inFileIndex2 += %1
if "%inFileIndex2%" == "" (
	set /a inFileIndex2=0
	set /a inFileLineCount2=0
	for /f "tokens=*" %%a in ('type "%inFile2%"') do set /a inFileLineCount2+=1
)
if %inFileIndex2% geq !inFileLineCount2! set /a inFileIndex2=0
if %inFileIndex2% lss 0 set /a inFileIndex2=!inFileLineCount2!-1
set /a cnt=0 & for /f "tokens=*" %%a in ('type "%inFile2%"') do (if !cnt! == !inFileIndex2! set pattern="%%a")& set /a cnt+=1
%pattern:~1,-1%
call :EXECUTEPREP
set pattern=
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

:EXECUTEPREP
if !initPrep! == 1 (
	if !opType! == 0 call :PREP 1
	if !opType! == 1 call :PREP
	if !opType! == 2 call :PREP 2
	if !opType! == 3 call :PREP 0 2
) else (
	if !stateMethod!==1 echo "cmdgfx: block 0 0,0,%w%,%h% 0,0 -1 0 0 - shl(col(x,y),24)" W!WVAL!
)
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

:SAVE_COLPATT
set colPatt=redP=!redP!, greenP=!greenP!, blueP=!blueP!, colChange=!colChange!, redNeg=!redNeg!, greenNeg=!greenNeg!, blueNeg=!blueNeg!, redAnd=!redAnd!, greenAnd=!greenAnd!, blueAnd=!blueAnd!, stayPatt=!stayPatt!, stayVal=!stayVal!, topClamp=!topClamp!, bottomClamp=!bottomClamp!
if "%~1"=="1" echo set /a %colPatt% >> data\randMooreColPattern.txt
goto :eof
