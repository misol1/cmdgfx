@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
set /a W=220, H=95

bg font 0 & mode %W%,%H%
cmdgfx "fbox 0 0 00 0,0,%W%,%H%"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

call sindef.bat

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV!, SXMID=%W%/2,SYMID=%H%/2, DELAY=12
set /a NOFLINES=100, LINEGAP=10, LNCNT=1, DCNT=0, REP=80, COL=10, CCYCLE=1, CCYCLELEN=20, STARTLINE=1
set /a ENDCYCLE=!CCYCLELEN!*16-1, CCNT=10*!CCYCLELEN!
for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

::set /a P1=1,P2=3,P3=2,P4=3,P5=-1,P6=2,P7=2,P8=2,SC=123,CC=278,SC2=61,CC2=666,SC3=294,CC3=66,SC4=140,CC4=482
::set /a P1=0,P2=-2,P3=-1,P4=-1,P5=1,P6=1,P7=2,P8=-1,SC=51,CC=-44,SC2=-316,CC2=-143,SC3=239,CC3=155,SC4=102,CC4=-255
set /a P1=1,P2=0,P3=0,P4=-2,P5=2,P6=2,P7=0,P8=2,SC=285,CC=-300,SC2=-295,CC2=-113,SC3=41,CC3=70,SC4=64,CC4=270
set /a P1=1,P2=0,P3=1,P4=3,P5=1,P6=-2,P7=3,P8=0,SC=129,CC=-3889,SC2=219,CC2=2900,SC3=-5736,CC3=-1766,SC4=6525,CC4=311
set /a P1=-2,P2=2,P3=-1,P4=1,P5=-3,P6=-1,P7=3,P8=2,SC=-863,CC=-1570,SC2=-1120,CC2=-2522,SC3=-1496,CC3=2092,SC4=3099,CC4=3240

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, SC3+=!P5!, CC3+=!P6!, SC4+=!P7!, CC4+=!P8!"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a A1=%%a,A2=%%b & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a A1=%%a,A2=%%b & set /a "XPOS2=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a A1=%%a,A2=%%b & set /a "XPOS3=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS3=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a A1=%%a,A2=%%b & set /a "XPOS4=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS4=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"

	for %%a in (!DCNT!) do set LN!LCNT!=line !COL! 0 !DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	for /L %%a in (!STARTLINE!,%LINEGAP%,%NOFLINES%) do set STR="!STR:~1,-1!&!LN%%a!"
	set /a STARTLINE+=1&if !STARTLINE! gtr %LINEGAP% set STARTLINE=1
	
	if !DIV! == 1 start /B /High cmdgfx_gdi "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1!" f0
	if !DIV! == 2 start /B /High cmdgfx_gdi "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 0 0 - - %SXMID%-x-1 y+0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 0 0 - - x+0 %SYMID%-y-1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 0 0 - - %SXMID%-x-1 %SYMID%-y-1" f0
	
	cmdgfx "" knW!DELAY!
	
	set KEY=!errorlevel!
	if !KEY! == 32 (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 7 - 3") & 	for /L %%a in (1,1,%NOFLINES%) do set LN%%a=  
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=%W%/2/!DIV!, YMID=%H%/2/!DIV!, XMUL=110/!DIV!, YMUL=48/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 99 set /a COL+=1 & if !COL!==16 set COL=10
	if !KEY! == 115 set /a CCYCLE=1-!CCYCLE!
	if !KEY! == 97 cls&echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC=!SC!,CC=!CC!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
	if !CCYCLE!==1 set /a CCNT+=1&(if !CCNT! gtr !ENDCYCLE! set /a CCNT=10*!CCYCLELEN!)&set /a COL=!CCNT!/!CCYCLELEN!
)
if not defined STOP goto LOOP
endlocal
bg font 6 & mode 80,50 & cls
cmdwiz showcursor 1
