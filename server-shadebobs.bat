@echo off
bg font 2 & mode 120,75 & cls
cmdwiz showcursor 0
if defined __ goto :START
cmdwiz getquickedit
set QE=%errorlevel%
cmdwiz setquickedit 0
set __=.
cmdgfx_input.exe m0nW8x | call %0 %* | cmdgfx_gdi "" Sf2:0,0,350,75,120,75
set __=
cmdwiz setquickedit %QE%
set QE=
cls
bg font 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do set "%%v="
echo "cmdgfx: fbox 0 0 db 0,0,350,75"
call centerwindow.bat 0 -20

call sindef.bat

set /a DL=0, DR=0, KEY=0, COL=0, SIZE=1, KD=0, MODE=1, YMID=75/2, XMID=120/2, XMUL=110/3, YMUL=55/2, XMUL2=110/4, YMUL2=55/4, SWCNT=0, DRWMODE=8
set DRAW=""&set STOP=&set OUTP=&set OUTP2=

set PAL0=00??=0???,10??=40b0,20??=40b2,30??=40db,40??=c4b0,50??=c4b1,60??=c4b2,70??=c4db,80??=ecb0,90??=ecb2,a0??=ecdb,b0??=feb0,c0??=feb2,d0??=7fb1,e0??=87b1,f0??=80b1
set PAL1=00??=0???,10??=10b0,20??=10b2,30??=10db,40??=91b0,50??=91b2,60??=91db,70??=b9b0,80??=b9b2,90??=b9db,a0??=fbb0,b0??=fbb2,c0??=fbdb,d0??=efb1,e0??=ecb1,f0??=c8b2
set PAL2=00??=0???,10??=50b0,20??=50b2,30??=50db,40??=d5b0,50??=d5b1,60??=d5b2,70??=d5db,80??=d5db,90??=7db0,a0??=7db2,b0??=f7b0,c0??=f7b2,d0??=afb1,e0??=2ab0,f0??=2ab2

set HELP=text b 0 0 _ENTER=auto/mouse,_SPACE=color,_c=clear,_Up/Down=size,_n=negative,_p=pause,_h=hide_help_ 15,73

:: a circle shape
set /a "MX0=0, MY0=7, MX1=3, MY1=7, MX2=6, MY2=5, MX3=7, MY3=2, MX4=7, MY4=-2, MX5=6, MY5=-5, MX6=4, MY6=-7, MX7=0, MY7=-8"
set /a "MX8=-3, MY8=-8, MX9=-6, MY9=-6, MX10=-8, MY10=-3, MX11=-8, MY11=0, MX12=-7, MY12=3, MX13=-5, MY13=6, MX14=-2, MY14=7"

set /a P1=4,P2=3,P3=-2,P4=-1, SC=285,CC=-30,SC2=-295,CC2=-113
rem set /a P1=24,P2=53,P3=-42,P4=-31, SC=285,CC=-30,SC2=-295,CC2=-113
rem set /a P1=14,P2=13,P3=-12,P4=-11, SC=285,CC=-30,SC2=-295,CC2=-113
rem set /a P1=77,P2=86,P3=-95,P4=-107, SC=285,CC=-30,SC2=-295,CC2=-113

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (

   if !MODE! == 0 (
		echo "cmdgfx: !DRAW:~1,-1! & block 0 200,0,150,75 200,0 -1 0 0 ?1??=?0?? & block 0 200,0,150,75 0,0 -1 0 0 !PAL%%c!& !HELP!" F
		
		set /p INPUT=
		for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L 2>nul ) 
		
		set DRAW=""
		if not "!EV_BASE:~0,1!" == "N" (
			if !M_EVENT!==1 (
				if !M_WHEEL! == 1 set /a SIZE-=1&if !SIZE! lss 1 set SIZE=1
				if !M_WHEEL! == -1 set /a SIZE+=1&if !SIZE! gtr 4 set SIZE=4
				for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!M_X!+200, MYP=!MY%%a!*!SIZE!+!M_Y!"&set OUTP=!OUTP!!MXP!,!MYP!,
				if !M_LB! == 1 set DRAW="ipoly 1 0 ? 8 !OUTP:~0,-1!"
				if !M_RB! == 1 set DRAW="ipoly 1 0 ? 5 !OUTP:~0,-1!"
				set OUTP=
			)
		)
		
		if !KEY! == 328 set /a SIZE+=1&if !SIZE! gtr 4 set SIZE=4
		if !KEY! == 336 set /a SIZE-=1&if !SIZE! lss 1 set SIZE=1
		if !KEY! == 32 set /a COL+=1&if !COL! gtr 2 set COL=0
		if !KEY! == 13 set /a MODE=1-!MODE!,SIZE=1
		if !KEY! == 99 echo "cmdgfx: fbox 0 0 db 0,0,350,75"
		if !KEY! == 115 echo "cmdgfx: " c:0,0,120,75
		if !KEY! == 104 set HELP=
		if !KEY! == 27 set STOP=1
		set /a KEY=0
		
   ) else (

		echo "cmdgfx: !DRAW:~1,-1! & block 0 200,0,150,75 200,0 -1 0 0 ?1??=?0?? & block 0 200,0,150,75 0,0 -1 0 0 !PAL%%c!& !HELP!" F

		set /p INPUT=
		for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D 2>nul )
		
		set DRAW=""

		set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, RAND=!RANDOM! %% 1000"
		if !RAND! lss 100 set /a SC2+=1
		if !RAND! gtr 900 set /a CC-=1
		if !RAND! gtr 500 if !RAND! lss 600 set /a SC+=1
		
		for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A4!*31416/180%*!XMUL2!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A3!*31416/180%*!YMUL2!>>!SHR!)"

		for %%a in (!SC!) do for %%b in (!CC!) do for %%d in (!SC2!) do for %%e in (!CC2!) do set /a A1=%%a,A2=%%b,A3=%%d,A4=%%e & set /a "XPOS2=!XMID!+(%SINE(x):x=!A3!*31416/180%*!YMUL!>>!SHR!)+(%SINE(x):x=!A2!*31416/180%*!XMUL2!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A4!*31416/180%*!XMUL!>>!SHR!)+(%SINE(x):x=!A1!*31416/180%*!YMUL2!>>!SHR!)"
		
		for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS!+200, MYP=!MY%%a!*!SIZE!+!YPOS!"&set OUTP=!OUTP!!MXP!,!MYP!,
		for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS2!+200, MYP=!MY%%a!*!SIZE!+!YPOS2!"&set OUTP2=!OUTP2!!MXP!,!MYP!,
rem		for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!XPOS!+200, MYP=!MY%%a!*!SIZE!+!YPOS2!"&set OUTP3=!OUTP3!!MXP!,!MYP!,
		set DRAW="ipoly 1 0 ? !DRWMODE! !OUTP:~0,-1! & ipoly 1 0 ? !DRWMODE! !OUTP2:~0,-1!& skip ipoly 1 0 ? !DRWMODE! !OUTP3:~0,-1!"
		set OUTP=&set OUTP2=&set OUTP3=

		if !KEY! == 328 set /a SIZE+=1&if !SIZE! gtr 4 set SIZE=4
		if !KEY! == 336 set /a SIZE-=1&if !SIZE! lss 1 set SIZE=1
		if !KEY! == 32 set /a COL+=1&if !COL! gtr 2 set COL=0
		if !KEY! == 13 set /a MODE=1-!MODE!, JUSTSWITCHED=1,SIZE=1
		if !KEY! == 99 echo "cmdgfx: fbox 0 0 db 0,0,350,75"
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 115 echo "cmdgfx: " c:0,0,120,75
		if !KEY! == 104 set HELP=
		if !KEY! == 110 (if !DRWMODE!==8 set TEMP=9)&(if !DRWMODE!==9 set TEMP=8)&set DRWMODE=!TEMP!
		if !KEY! == 27 set STOP=1
		set /a KEY=0
	)
	
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
