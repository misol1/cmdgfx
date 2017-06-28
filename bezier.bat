@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=95
bg font 0 & mode %W%,%H%
cmdgfx "fbox 0 0 00 0,0,%W%,%H%"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="& set /A SHR=13

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=88/!DIV!, YMUL=38/!DIV!, SXMID=%W%/2,SYMID=%H%/2
set /a NOFLINES=50, LNCNT=1, DCNT=0, REP=80, COL=10, CCYCLE=0, CCYCLELEN=10
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

::set /a P1=5,P2=8,P3=9,P4=6,P5=4,P6=2,P7=6,P8=13
::set /a P1=10,P2=7,P3=13,P4=4,P5=7,P6=11,P7=10,P8=12
::set /a P1=2,P2=9,P3=2,P4=14,P5=5,P6=13,P7=8,P8=13
::set /a P1=6,P2=6,P3=10,P4=4,P5=3,P6=16,P7=10,P8=11,SC1=65,CC1=256,SC2=568,CC2=424,SC3=619,CC3=710,SC4=716,CC4=65
::set /a P1=16,P2=8,P3=13,P4=6,P5=17,P6=11,P7=8,P8=16,SC1=57,CC1=96,SC2=469,CC2=493,SC3=363,CC3=415,SC4=292,CC4=493
::set /a P1=6,P2=7,P3=5,P4=13,P5=13,P6=2,P7=17,P8=13,SC1=161,CC1=43,SC2=711,CC2=691,SC3=494,CC3=405,SC4=267,CC4=173
::set /a P1=8,P2=2,P3=4,P4=3,P5=4,P6=4,P7=16,P8=7,SC1=209,CC1=597,SC2=274,CC2=362,SC3=547,CC3=276,SC4=208,CC4=216
::set /a P1=6,P2=15,P3=2,P4=17,P5=14,P6=6,P7=2,P8=6,SC1=497,CC1=704,SC2=245,CC2=693,SC3=432,CC3=59,SC4=245,CC4=560
::set /a P1=15,P2=17,P3=6,P4=8,P5=16,P6=5,P7=13,P8=14,SC1=526,CC1=338,SC2=304,CC2=306,SC3=338,CC3=309,SC4=18,CC4=278
::set /a P1=12,P2=8,P3=13,P4=2,P5=7,P6=14,P7=16,P8=7,SC1=263,CC1=681,SC2=388,CC2=117,SC3=618,CC3=330,SC4=191,CC4=192
set /a P1=2,P2=10,P3=9,P4=9,P5=17,P6=14,P7=10,P8=13,SC1=263,CC1=413,SC2=521,CC2=248,SC3=403,CC3=296,SC4=351,CC4=133

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC1=(!SC1!+!P1!) %% 720, CC1=(!CC1!+!P2!) %% 720, SC2=(!SC2!+!P3!) %% 720, CC2=(!CC2!+!P4!) %% 720, SC3=(!SC3!+!P5!) %% 720, CC3=(!CC3!+!P6!) %% 720, SC4=(!SC4!+!P7!) %% 720, CC4=(!CC4!+!P8!) %% 720"

	for /L %%a in (1,1,4) do set /a SV=!SC%%a!,CV=!CC%%a! & set /a "XPOS%%a=!XMID!+(%SINE(x):x=!SV!/2*31416/180%*!XMUL!>>%SHR%), YPOS%%a=!YMID!+(%SINE(x):x=!CV!/2*31416/180%*!YMUL!>>%SHR%)"

	for %%a in (!DCNT!) do set LN!LCNT!=line !COL! 0 !DIC:~%%a,1! !XPOS1!,!YPOS1!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	for /L %%a in (1,1,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	
	if !DIV! == 1 cmdgfx "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1!" kf0
	if !DIV! == 2 cmdgfx "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 1 0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 0 1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 1 1" kf0
		
	set /a KEY=!errorlevel!
	if !KEY! == 32 (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 16 + 2") & 	for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=%W%/2/!DIV!, YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 99 set /a "COL=(!COL! %% 15) + 1"
	if !KEY! == 115 set /a CCYCLE=1-!CCYCLE!
	if !KEY! == 97 cls&echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC1=!SC1!,CC1=!CC1!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
	if !CCYCLE!==1 set /a "CCNT=(!CCNT!+1) %% (16*!CCYCLELEN!)"&set /a COL=!CCNT!/!CCYCLELEN!
)
if not defined STOP goto LOOP
endlocal
bg font 6 & mode 80,50 & cls
cmdwiz showcursor 1
