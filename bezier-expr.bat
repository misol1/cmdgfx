@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=95
cmdwiz setfont 0 & mode %W%,%H%
cmdgfx "fbox 0 0 00 0,0,%W%,%H%"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="
call sintable.bat

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV!, SXMID=%W%/2,SYMID=%H%/2
set /a NOFLINES=30, LNCNT=1, DCNT=0, REP=80, CCYCLE=1
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

::set /a P1=5,P2=8,P3=9,P4=6,P5=4,P6=2,P7=6,P8=13
::set /a P1=10,P2=7,P3=13,P4=4,P5=7,P6=11,P7=10,P8=12
::set /a P1=2,P2=9,P3=2,P4=14,P5=5,P6=13,P7=8,P8=13
::set /a P1=6,P2=6,P3=10,P4=4,P5=3,P6=16,P7=10,P8=11,SC=65,CC=256,SC2=568,CC2=424,SC3=619,CC3=710,SC4=716,CC4=65
::set /a P1=6,P2=7,P3=5,P4=13,P5=13,P6=2,P7=17,P8=13,SC=161,CC=43,SC2=711,CC2=691,SC3=494,CC3=405,SC4=267,CC4=173
set /a P1=9,P2=17,P3=4,P4=6,P5=14,P6=13,P7=10,P8=6,SC=334,CC=62,SC2=599,CC2=352,SC3=671,CC3=254,SC4=56,CC4=96
::set /a P1=9,P2=6,P3=2,P4=7,P5=8,P6=8,P7=16,P8=16,SC=627,CC=253,SC2=674,CC2=648,SC3=264,CC3=520,SC4=217,CC4=180
::set /a P1=13,P2=2,P3=3,P4=3,P5=9,P6=10,P7=10,P8=15,SC=673,CC=228,SC2=356,CC2=210,SC3=328,CC3=719,SC4=214,CC4=269
::set /a P1=3,P2=3,P3=9,P4=9,P5=15,P6=11,P7=11,P8=5,SC=541,CC=256,SC2=105,CC2=594,SC3=437,CC3=360,SC4=316,CC4=42
::set /a P1=16,P2=8,P3=13,P4=6,P5=17,P6=11,P7=8,P8=16,SC=57,CC=96,SC2=469,CC2=493,SC3=363,CC3=415,SC4=292,CC4=493
::set /a P1=7,P2=8,P3=4,P4=3,P5=16,P6=16,P7=12,P8=16,SC=86,CC=425,SC2=41,CC2=310,SC3=480,CC3=701,SC4=718,CC4=139

set STREAM="0???=10??,1???=90??,2???=b0??,3???=f0??,4???=f0??,5???=b0??,6???=90??,7???=10??,8???=10??,9???=90??,a???=b0??,b???=f0??,c???=b0??,d???=90??,e???=10??,f???=10??"

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC=(!SC!+!P1!) %% 720, CC=(!CC!+!P2!) %% 720, SC2=(!SC2!+!P3!) %% 720, CC2=(!CC2!+!P4!) %% 720, SC3=(!SC3!+!P5!) %% 720, CC3=(!CC3!+!P6!) %% 720, SC4=(!SC4!+!P7!) %% 720, CC4=(!CC4!+!P8!) %% 720"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a "XPOS=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a "XPOS2=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS2=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a "XPOS3=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS3=!YMID!+(!SIN%%b!*!YMUL!>>14)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a "XPOS4=!XMID!+(!SIN%%a!*!XMUL!>>14), YPOS4=!YMID!+(!SIN%%b!*!YMUL!>>14)"

	for %%a in (!DCNT!) do set LN!LCNT!=line a 0 !DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	for /L %%a in (1,1,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	
	set /a PLC1+=3, PLC2+=10
	if !DIV! == 1 if !CCYCLE!==1 cmdgfx_gdi "!STR:~1,-1! & block 0 0,0,%W%,%H% 0,0 -1 %STREAM% sin((x+!PLC1!/4)/110)*4+sin((y+!PLC2!/5)/65)*4+8" kf0
	if !DIV! == 1 if !CCYCLE!==0 cmdgfx_gdi "!STR:~1,-1!" kf0
	if !DIV! == 2 if !CCYCLE!==1 cmdgfx_gdi "!STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 - - %SXMID%-x-1 y+0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 - - x+0 %SYMID%-y-1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 - - %SXMID%-x-1 %SYMID%-y-1 & block 0 0,0,%W%,%H% 0,0 -1 %STREAM% sin((x+!PLC1!/4)/110)*4+sin((y+!PLC2!/5)/65)*4+8" kf0
	if !DIV! == 2 if !CCYCLE!==0 cmdgfx_gdi "!STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 - - %SXMID%-x-1 y+0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 - - x+0 %SYMID%-y-1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 - - %SXMID%-x-1 %SYMID%-y-1" kf0
		
	set KEY=!errorlevel!
	if !KEY! == 32 (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 16 + 2") & 	for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=%W%/2/!DIV!, YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 99 set /a CCYCLE=1-!CCYCLE!
	if !KEY! == 97 cls & echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC=!SC!,CC=!CC!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP
endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
