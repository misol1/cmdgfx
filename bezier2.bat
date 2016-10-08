@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=95
cmdwiz setfont 0 & mode %W%,%H%
cmdgfx "fbox 0 0 00 0,0,%W%,%H%"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
call sintable.bat

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV!, SXMID=%W%/2,SYMID=%H%/2
set /a NOFLINES=100, LINEGAP=10, LNCNT=1, DCNT=0, REP=80, COL=10, CCYCLE=0, CCYCLELEN=10, STARTLINE=1
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

::set /a P1=1,P2=3,P3=3,P4=3,P5=5,P6=4,P7=3,P8=4,SC=263,CC=413,SC2=521,CC2=248,SC3=403,CC3=296,SC4=351,CC4=133
::set /a P1=4,P2=2,P3=5,P4=2,P5=0,P6=4,P7=2,P8=0,SC=170,CC=459,SC2=697,CC2=633,SC3=609,CC3=628,SC4=645,CC4=691
::set /a P1=3,P2=3,P3=4,P4=5,P5=4,P6=1,P7=2,P8=5,SC=421,CC=209,SC2=245,CC2=660,SC3=275,CC3=261,SC4=649,CC4=65
::set /a P1=3,P2=5,P3=5,P4=1,P5=5,P6=6,P7=0,P8=3,SC=676,CC=468,SC2=467,CC2=117,SC3=497,CC3=236,SC4=575,CC4=246
::set /a P1=6,P2=5,P3=4,P4=1,P5=2,P6=6,P7=5,P8=5,SC=420,CC=355,SC2=651,CC2=620,SC3=667,CC3=612,SC4=82,CC4=329
::set /a P1=1,P2=1,P3=5,P4=0,P5=3,P6=6,P7=1,P8=5,SC=265,CC=281,SC2=458,CC2=641,SC3=378,CC3=592,SC4=8,CC4=159
::set /a P1=6,P2=5,P3=3,P4=5,P5=0,P6=2,P7=0,P8=3,SC=69,CC=473,SC2=594,CC2=141,SC3=294,CC3=368,SC4=700,CC4=295
::set /a P1=3,P2=4,P3=3,P4=0,P5=6,P6=6,P7=6,P8=4,SC=429,CC=526,SC2=22,CC2=419,SC3=227,CC3=471,SC4=60,CC4=300
::set /a P1=2,P2=1,P3=0,P4=5,P5=1,P6=3,P7=4,P8=0,SC=683,CC=78,SC2=460,CC2=69,SC3=11,CC3=671,SC4=108,CC4=274
::set /a P1=1,P2=2,P3=1,P4=5,P5=6,P6=0,P7=4,P8=5,SC=326,CC=364,SC2=537,CC2=38,SC3=308,CC3=676,SC4=187,CC4=0
::set /a P1=3,P2=5,P3=2,P4=6,P5=5,P6=3,P7=4,P8=4,SC=503,CC=560,SC2=684,CC2=711,SC3=493,CC3=53,SC4=244,CC4=2
set /a P1=1,P2=6,P3=4,P4=6,P5=0,P6=4,P7=4,P8=4,SC=123,CC=278,SC2=61,CC2=666,SC3=294,CC3=66,SC4=140,CC4=482

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC=(!SC!+!P1!) %% 720, CC=(!CC!+!P2!) %% 720, SC2=(!SC2!+!P3!) %% 720, CC2=(!CC2!+!P4!) %% 720, SC3=(!SC3!+!P5!) %% 720, CC3=(!CC3!+!P6!) %% 720, SC4=(!SC4!+!P7!) %% 720, CC4=(!CC4!+!P8!) %% 720"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a "XPOS=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a "XPOS2=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS2=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a "XPOS3=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS3=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a "XPOS4=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS4=!YMID!+(!SIN%%b!*!YMUL!>>14)"

	for %%a in (!DCNT!) do set LN!LCNT!=line !COL! 0 !DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	for /L %%a in (!STARTLINE!,%LINEGAP%,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	set /a STARTLINE+=1&if !STARTLINE! gtr %LINEGAP% set STARTLINE=1
	
	if !DIV! == 1 cmdgfx "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1!" kf0
	if !DIV! == 2 cmdgfx "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 - - %SXMID%-x-1 y+0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 - - x+0 %SYMID%-y-1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 - - %SXMID%-x-1 %SYMID%-y-1" kf0
		
	set KEY=!errorlevel!
	if !KEY! == 32 (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 7 + 0") & 	for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=%W%/2/!DIV!, YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 99 set /a "COL=(!COL! %% 15) + 1"
	if !KEY! == 115 set /a CCYCLE=1-!CCYCLE!
	if !KEY! == 97 cls&echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC=!SC!,CC=!CC!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
	if !CCYCLE!==1 set /a "CCNT=(!CCNT!+1) %% (16*!CCYCLELEN!)"&set /a COL=!CCNT!/!CCYCLELEN!
)
if not defined STOP goto LOOP
endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
