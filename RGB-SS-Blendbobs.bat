@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off

cd /D "%~dp0"
if defined __ goto :START

cmdwiz setfont 2
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100

cmdwiz getdisplaydim w
set /a W=%errorlevel%/8+1
cmdwiz getdisplaydim h
set /a H=%errorlevel%/8+1

set /a WWW=W*3

set __=.
cmdgfx_input.exe m0nW8xR | call %0 %* | cmdgfx_RGB "" %TOP%Sf2:0,0,%W%,%H%
set __=
cls
cmdwiz fullscreen 0 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
echo "cmdgfx: fbox 0 0 db"

call sindef.bat

set /a WWW=W*3, W150=W+30, W200=W+80
set /a DL=0, DR=0, KEY=0, COL=0, SIZE=2, KD=0, MODE=1, YMID=75/2, XMID=120/2, XMUL=110/3, YMUL=55/2, XMUL2=110/4, YMUL2=55/4, SWCNT=0, DRWMODE=21
set DRAW=""&set STOP=&set OUTP=&set OUTP2=

set PAL0=00??=0???,10??=40b0,20??=40b2,30??=40db,40??=c4b0,50??=c4b1,60??=c4b2,70??=c4db,80??=ecb0,90??=ecb2,a0??=ecdb,b0??=feb0,c0??=feb2,d0??=7fb1,e0??=87b1,f0??=80b1
set PAL1=00??=0???,10??=10b0,20??=10b2,30??=10db,40??=91b0,50??=91b2,60??=91db,70??=b9b0,80??=b9b2,90??=b9db,a0??=fbb0,b0??=fbb2,c0??=fbdb,d0??=efb1,e0??=ecb1,f0??=c8b2
set PAL2=00??=0???,10??=50b0,20??=50b2,30??=50db,40??=d5b0,50??=d5b1,60??=d5b2,70??=d5db,80??=d5db,90??=7db0,a0??=7db2,b0??=f7b0,c0??=f7b2,d0??=afb1,e0??=2ab0,f0??=2ab2

:: a circle shape
set /a "MX0=0, MY0=7, MX1=3, MY1=7, MX2=6, MY2=5, MX3=7, MY3=2, MX4=7, MY4=-2, MX5=6, MY5=-5, MX6=4, MY6=-7, MX7=0, MY7=-8"
set /a "MX8=-3, MY8=-8, MX9=-6, MY9=-6, MX10=-8, MY10=-3, MX11=-8, MY11=0, MX12=-7, MY12=3, MX13=-5, MY13=6, MX14=-2, MY14=7"

set /a P1=4,P2=3,P3=-2,P4=-1, SC=285,CC=-30,SC2=-295,CC2=-113

set /a "XMID=W/2, YMID=H/2, HLPY=H-3, HLPX=W/2-102/2, W150=W+30, W200=W+80, XMUL=(W-20)/4, YMUL=(H-20)/3, XMUL2=(W-30)/4, YMUL2=(H-20)/4"

set /a NOFSB=3, TIMEOUT=6000

set t1=!time: =0!

set FG1=06dd9966& set BG1=03000000& set FG2=03ffffff& set BG2=0300ee55& set FG3=05000000& set BG3=040000000

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (

	echo "cmdgfx: !DRAW:~1,-1!" Ff2:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, MOUSE_EVENT=%%E 2>nul )
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	
	set DRAW=""

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d)*10,a+=(a>>31)&8640000"
	if !a! geq !TIMEOUT! (
		set /a "SIZE=2, RS=!RANDOM! %% 4, BS=!RANDOM! %% 9, NOFSB=2 + !RANDOM! %% 2, TIMEOUT=4500+!RANDOM! %% 2000"
		call :GETCOLORS
rem		echo "cmdgfx: fbox 0 0 !CHAR!"& set /a "OLDCOL=COL, COL=!RANDOM! %% 3, DRWMODE=21" & if !COL!==!OLDCOL! set /a "COL=!RANDOM! %% 3"
rem		set /a BINR=!RANDOM! %% 10 & if !BINR!==1 echo "cmdgfx: block 0 0,0,!W!,!H! 0,0 -1 0 0 00??=0031,????=0030 random()*5"
		set /a BINR=!RANDOM! %% 10 & if !BINR!==1 echo "cmdgfx: block 0 0,0,!W!,!H! 0,0 -1 0 0 00??=0031,10??=0030,????=0020 random()*5"
		set /a BINR=!RANDOM! %% 2 & if !BINR!==0 echo "cmdgfx: fbox 0 0 !CHAR!"& set /a "OLDCOL=COL, COL=!RANDOM! %% 3, DRWMODE=21" & if !COL!==!OLDCOL! set /a "COL=!RANDOM! %% 3"
		if !BS! geq 7 set /a SIZE=3
		set t1=!time: =0!
	)

	set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, RAND=!RANDOM! %% 1000"
	if !RAND! lss 100 set /a SC2+=1
	if !RAND! gtr 900 set /a CC-=1
	if !RAND! gtr 500 if !RAND! lss 600 set /a SC+=1
	
	for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A4!*31416/180%*!XMUL2!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A3!*31416/180%*!YMUL2!>>!SHR!)"

	for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS2=!XMID!+(%SINE(x):x=!A3!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A2!*31416/180%*!XMUL2!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A4!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A1!*31416/180%*!YMUL2!>>!SHR!)"
	
	for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS!, MYP=!MY%%a!*!SIZE!+!YPOS!"&set OUTP=!OUTP!!MXP!,!MYP!,
	set SS2=skip&set SS3=skip
	if !NOFSB! geq 2 set SS2=&for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS2!, MYP=!MY%%a!*!SIZE!+!YPOS2!"&set OUTP2=!OUTP2!!MXP!,!MYP!,
	if !NOFSB! geq 3 set SS3=& for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS!, MYP=!MY%%a!*!SIZE!+!YPOS2!"&set OUTP3=!OUTP3!!MXP!,!MYP!,
	set DRAW="ipoly !FG1! !BG1! ? !DRWMODE! !OUTP:~0,-1! & !SS2! ipoly !FG2! !BG2! ? !DRWMODE! !OUTP2:~0,-1!& !SS3! ipoly !FG3! !BG3! ? !DRWMODE! !OUTP3:~0,-1!"
	set OUTP=&set OUTP2=&set OUTP3=

	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:GETCOLORS
set /a CC=0 & for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set HX!CC!=%%a&set /a CC+=1
for /L %%a in (1,1,3) do set /a "STRENGTH=3+!RANDOM! %% 7, R1=!RANDOM! %% 16, G1=!RANDOM! %% 16, B1=!RANDOM! %% 16, R2=!RANDOM! %% 16, G2=!RANDOM! %% 16, B2=!RANDOM! %% 16" & for %%b in (!R1!) do for %%c in (!R2!) do for %%d in (!G1!) do for %%e in (!G2!) do for %%f in (!B1!) do for %%g in (!B2!) do set FG%%a=0!STRENGTH!!HX%%b!!HX%%c!!HX%%d!!HX%%e!!HX%%f!!HX%%g!
for /L %%a in (1,1,3) do set /a "STRENGTH=2+!RANDOM! %% 5, R1=!RANDOM! %% 16, G1=!RANDOM! %% 16, B1=!RANDOM! %% 16, R2=!RANDOM! %% 16, G2=!RANDOM! %% 16, B2=!RANDOM! %% 16" & for %%b in (!R1!) do for %%c in (!R2!) do for %%d in (!G1!) do for %%e in (!G2!) do for %%f in (!B1!) do for %%g in (!B2!) do set BG%%a=0!STRENGTH!!HX%%b!!HX%%c!!HX%%d!!HX%%e!!HX%%f!!HX%%g!
set /a CH1=!RANDOM! %% 16, CH2=!RANDOM! %% 16 
for %%a in (!CH1!) do for %%b in (!CH2!) do set CHAR=!HX%%a!!HX%%b!
set /a CHRND=!RANDOM! %% 3
if !CHRND!==0 set CHAR=db
rem set CHAR=DB
rem echo !FG1! !FG2! !FG3! & cmdwiz getch
