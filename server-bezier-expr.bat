@echo off
set /a F6W=220/2, F6H=95/2
cmdwiz setfont 6 & mode %F6W%,%F6H% & cls & title Bezier expression background
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW15xR | call %0 %* | cmdgfx_gdi "" Sf0:0,0,220,95
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=95
echo "cmdgfx: fbox 0 0 00 0,0,!W!,!H!"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
call centerwindow.bat 0 -15

call sindef.bat

set /a DIV=2 & set /a XMID=!W!/2/!DIV!,YMID=!H!/2/!DIV!, XMUL=88/!DIV!, YMUL=38/!DIV!, SXMID=!W!/2,SYMID=!H!/2
set /a NOFLINES=30, LNCNT=1, DCNT=0, REP=80, CCYCLE=1
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

::set /a P1=5,P2=8,P3=9,P4=6,P5=4,P6=2,P7=6,P8=13
::set /a P1=10,P2=7,P3=13,P4=4,P5=7,P6=11,P7=10,P8=12
::set /a P1=2,P2=9,P3=2,P4=14,P5=5,P6=13,P7=8,P8=13
::set /a P1=6,P2=6,P3=10,P4=4,P5=3,P6=16,P7=10,P8=11,SC1=65,CC1=256,SC2=568,CC2=424,SC3=619,CC3=710,SC4=716,CC4=65
::set /a P1=6,P2=7,P3=5,P4=13,P5=13,P6=2,P7=17,P8=13,SC1=161,CC1=43,SC2=711,CC2=691,SC3=494,CC3=405,SC4=267,CC4=173
set /a P1=9,P2=17,P3=4,P4=6,P5=14,P6=13,P7=10,P8=6,SC1=334,CC1=62,SC2=599,CC2=352,SC3=671,CC3=254,SC4=56,CC4=96
::set /a P1=9,P2=6,P3=2,P4=7,P5=8,P6=8,P7=16,P8=16,SC1=627,CC1=253,SC2=674,CC2=648,SC3=264,CC3=520,SC4=217,CC4=180
::set /a P1=13,P2=2,P3=3,P4=3,P5=9,P6=10,P7=10,P8=15,SC1=673,CC1=228,SC2=356,CC2=210,SC3=328,CC3=719,SC4=214,CC4=269
::set /a P1=3,P2=3,P3=9,P4=9,P5=15,P6=11,P7=11,P8=5,SC1=541,CC1=256,SC2=105,CC2=594,SC3=437,CC3=360,SC4=316,CC4=42
::set /a P1=16,P2=8,P3=13,P4=6,P5=17,P6=11,P7=8,P8=16,SC1=57,CC1=96,SC2=469,CC2=493,SC3=363,CC3=415,SC4=292,CC4=493
::set /a P1=7,P2=8,P3=4,P4=3,P5=16,P6=16,P7=12,P8=16,SC1=86,CC1=425,SC2=41,CC2=310,SC3=480,CC3=701,SC4=718,CC4=139

set STREAM="0???=10??,1???=90??,2???=b0??,3???=f0??,4???=f0??,5???=b0??,6???=90??,7???=10??,8???=10??,9???=90??,a???=b0??,b???=f0??,c???=b0??,d???=90??,e???=10??,f???=10??"

set /a SHOWHELP=1
set MSG=text 8 0 0 SPACE\-ENTER\-c\-e\-h 1,92
set SH=skip& if !SHOWHELP!==1 set SH=

set CLS=&set /a SKIPCLS=0

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC1=(!SC1!+!P1!) %% 720, CC1=(!CC1!+!P2!) %% 720, SC2=(!SC2!+!P3!) %% 720, CC2=(!CC2!+!P4!) %% 720, SC3=(!SC3!+!P5!) %% 720, CC3=(!CC3!+!P6!) %% 720, SC4=(!SC4!+!P7!) %% 720, CC4=(!CC4!+!P8!) %% 720"

	for /L %%a in (1,1,4) do set /a SV=!SC%%a!,CV=!CC%%a! & set /a "XPOS%%a=!XMID!+(%SINE(x):x=!SV!/2*31416/180%*!XMUL!>>%SHR%), YPOS%%a=!YMID!+(%SINE(x):x=!CV!/2*31416/180%*!YMUL!>>%SHR%)"

	for %%a in (!DCNT!) do set LN!LCNT!=line a 0 !DIC:~%%a,1! !XPOS1!,!YPOS1!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR="!CLS! fbox 0 0 20 0,0,!W!,!H! & "&set REP=1
	for /L %%a in (1,1,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	
	set /a PLC1+=3, PLC2+=10
	if !DIV! == 1 if !CCYCLE!==1 echo "cmdgfx: !STR:~1,-1! & block 0 0,0,!W!,!H! 0,0 -1 0 0 %STREAM:~1,-1% sin(x/100+y/160-!PLC1!/240)*4+5 & !SH! !MSG!" f0:0,0,!W!,!H!
rem	if !DIV! == 1 if !CCYCLE!==1 echo "cmdgfx: !STR:~1,-1! & block 0 0,0,!W!,!H! 0,0 -1 0 0 %STREAM:~1,-1% sin((x+!PLC1!/4)/110)*4+sin((y+!PLC2!/5)/65)*4+8 & !SH! !MSG!" f0:0,0,!W!,!H!
	if !DIV! == 1 if !CCYCLE!==0 echo "cmdgfx: !STR:~1,-1! & !SH! !MSG!" f0:0,0,!W!,!H!
	if !DIV! == 2 if !CCYCLE!==1 echo "cmdgfx: !STR:~1,-1! & block 0 0,0,!SXMID!,!SYMID! !SXMID!,0 -1 1 0 & block 0 0,0,!SXMID!,!SYMID! 0,!SYMID! -1 0 1 & block 0 0,0,!SXMID!,!SYMID! !SXMID!,!SYMID! -1 1 1 & block 0 0,0,!W!,!H! 0,0 -1 0 0 %STREAM:~1,-1% sin(x/100+y/160-!PLC1!/240)*4+5 & !SH! !MSG!" f0:0,0,!W!,!H!
rem	if !DIV! == 2 if !CCYCLE!==1 echo "cmdgfx: !STR:~1,-1! & block 0 0,0,!SXMID!,!SYMID! !SXMID!,0 -1 1 0 & block 0 0,0,!SXMID!,!SYMID! 0,!SYMID! -1 0 1 & block 0 0,0,!SXMID!,!SYMID! !SXMID!,!SYMID! -1 1 1 & block 0 0,0,!W!,!H! 0,0 -1 0 0 %STREAM:~1,-1% sin((x+!PLC1!/4)/110)*4+sin((y+!PLC2!/5)/65)*4+8 & !SH! !MSG!" f0:0,0,!W!,!H!
	if !DIV! == 2 if !CCYCLE!==0 echo "cmdgfx: !STR:~1,-1! & block 0 0,0,!SXMID!,!SYMID! !SXMID!,0 -1 1 0 & block 0 0,0,!SXMID!,!SYMID! 0,!SYMID! -1 0 1 & block 0 0,0,!SXMID!,!SYMID! !SXMID!,!SYMID! -1 1 1 & !SH! !MSG!" f0:0,0,!W!,!H!

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a "W=SCRW*2+2, H=SCRH*2+2, XMID=W/2/DIV, YMID=H/2/DIV, SXMID=W/2, SYMID=H/2, XMUL=W/2/DIV, YMUL=H/2/DIV, HLPY=H-4" & cmdwiz showcursor 0 & set MSG=text 8 0 0 SPACE\-ENTER\-c\-e\-h 1,!HLPY! 
	
	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 32 (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 20 + 2") & for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=!W!/2/!DIV!, YMID=!H!/2/!DIV!, XMUL=W/2/!DIV!, YMUL=H/2/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 101 set CLS=&set /a SKIPCLS=1-!SKIPCLS! & if !SKIPCLS!==1 set CLS=skip
	if !KEY! == 99 set /a CCYCLE=1-!CCYCLE!
	if !KEY! == 104  set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set SH=skip)&if !SHOWHELP!==1 set SH=
	if !KEY! == 97 cls & echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC1=!SC!,CC1=!CC!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
endlocal
echo "cmdgfx: quit"
title input:Q
