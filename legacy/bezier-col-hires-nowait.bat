@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
set /a W=335, H=110
set /a W=289, H=100
::set /a W=180, H=80
cmdwiz setfont 0 & mode %W%,%H%
cmdgfx "fbox 0 0 00 0,0,%W%,%H%"
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" if /I not "%%v"=="PATH" set "%%v="
set /a W*=4, H*=6

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SIN(x)=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832) + (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a) ), %_SIN%)"
set "_SIN="

set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=%W%/2/!DIV!, YMUL=%H%/2/!DIV!, SXMID=%W%/2,SYMID=%H%/2, SHR=13, DELAY=0, KEY=0
set /a LINEGAP=5, NOFBEZ=11, LNCNT=1, DCNT=0, REP=80, COL=10, STARTLINE=1, REALCOL=1, CHANGE=1, CHANGESTEPS=400 & set /a NOFLINES=!NOFBEZ!*!LINEGAP!& set /a CHANGECOUNT=!CHANGESTEPS!,STARTCNT=!NOFLINES!
set PALETTE1=000000,000000,000000,000000,000000,0020ff,0040ff,0060ff,0080ff,20a0ff,20b0ff,50c0ff,80e0ff,b0f0ff,f0ffff,ffffff
set PALETTE3=000000,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00
:: color components below FF for at least one of R/G/B causes some sort of "blinking" phenomenon on my display which is visually disturbing in line drawing mode
set PALETTE4=000000,000000,000000,000000,000000,000080,0050a0,0050a0,0050a0,2090e0,2090e0,50b0ff,80d0ff,b0f0ff,f0ffff,ffffff
set PAL=!PALETTE1!
set DRAWOP=0&set D0=line&set D1=ipoly&set D2=fellipse&set D3=fbox&set D4=fcircle&set D5=ellipse&set BITOP=3
for /L %%a in (1,1,%NOFLINES%) do set LN%%a= 
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

set /a P1=-1,P2=1,P3=-1,P4=2,P5=-1,P6=2,P7=-1,P8=2,SC=21211,CC=17675,SC2=-15297,CC2=7463,SC3=60228,CC3=-32628,SC4=-25759,CC4=16335

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, SC3+=!P5!, CC3+=!P6!, SC4+=!P7!, CC4+=!P8!"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a A1=%%a,A2=%%b & set /a "XPOS=!XMID!+(%SIN(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS=!YMID!+(%SIN(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a A1=%%a,A2=%%b & set /a "XPOS2=!XMID!+(%SIN(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS2=!YMID!+(%SIN(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a A1=%%a,A2=%%b & set /a "XPOS3=!XMID!+(%SIN(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS3=!YMID!+(%SIN(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a A1=%%a,A2=%%b & set /a "XPOS4=!XMID!+(%SIN(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS4=!YMID!+(%SIN(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"

	set /a CHANGECOUNT-=1,STARTCNT-=1 & if !CHANGECOUNT!==0 if !CHANGE!==1 set /a CHANGECOUNT=!CHANGESTEPS!, RAND=!RANDOM! %% 8 + 1 & set /a "P!RAND!+=(!RANDOM! %% 2)*2 - 1"
	
	if not !DRAWOP!==1 for %%a in (!DCNT!) do set LN!LCNT!=!DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	if !DRAWOP!==1 for %%a in (!DCNT!) do set LN!LCNT!=!DIC:~%%a,1! !BITOP! !XPOS!,!YPOS!,!XPOS2!,!YPOS2!,!XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	set /a CNT=!LCNT!+!LINEGAP!, COLVAL=4 & if !CNT! gtr %NOFLINES% set /a CNT-=%NOFLINES%

   for %%a in (!DRAWOP!) do set DRAW=!D%%a!
	for /L %%a in (!STARTLINE!,%LINEGAP%,%NOFLINES%) do for %%b in (!CNT!) do (if not "!LN%%b!"==" " set STR="!STR:~1,-1!&!DRAW! !COLVAL! 0 !LN%%b!")& set /a CNT+=!LINEGAP!,COLVAL+=1 & if !CNT! gtr %NOFLINES% set /a CNT-=%NOFLINES%
	set /a STARTLINE+=1&if !STARTLINE! gtr %LINEGAP% set STARTLINE=1

	if !STARTCNT! lss 0 if !DIV! == 1 start "" /high /B cmdgfx_gdi "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1!" koefa:0,0,%W%,%H% !PAL!
 	if !STARTCNT! lss 0 if !DIV! == 2 start "" /high /B cmdgfx_gdi "fbox !COL! 0 00 0,0,%W%,%H% & !STR:~1,-1! & block 0 0,0,%SXMID%,%SYMID% %SXMID%,0 -1 1 0 & block 0 0,0,%SXMID%,%SYMID% 0,%SYMID% -1 0 1 & block 0 0,0,%SXMID%,%SYMID% %SXMID%,%SYMID% -1 1 1" kOefa:0,0,%W%,%H% !PAL!
	set STR=

	rem if !STARTCNT! lss 0 getkey /N & set KEY=!ERRORLEVEL!
	if !STARTCNT! lss 0 if exist EL.dat set /p KEY=<EL.dat 2>nul & del /Q EL.dat >nul 2>nul & if "!KEY!" == "" set KEY=0
	if !KEY! == 32 set /a CHANGECOUNT=!CHANGESTEPS!& (for /L %%a in (1,1,8) do set /a "P%%a=!RANDOM! %% 7 - 3") & for /L %%a in (1,1,%NOFLINES%) do set LN%%a= 
	if !KEY! == 13 set /a "DIV=(!DIV! %% 2) + 1" & set /a XMID=%W%/2/!DIV!, YMID=%H%/2/!DIV!, XMUL=%W%/2/!DIV!, YMUL=%H%/2/!DIV! 
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 68 set /a DELAY+=10
	if !KEY! == 100 set /a DELAY-=10 & if !DELAY! lss 0 set DELAY=0
	if !KEY! == 99 set /a REALCOL+=1 & (if !REALCOL! gtr 4 set REALCOL=1) & for %%a in (!REALCOL!) do set PAL=!PALETTE%%a!
	if !KEY! == 115 set /a CHANGE=1-!CHANGE!
	if !KEY! == 111 set /a DRAWOP+=1,BITOP=3 & if !DRAWOP! gtr 5 set DRAWOP=0
	if !KEY! == 98 set /a BITOP+=1 & if !BITOP! gtr 10 set BITOP=1
	if !KEY! == 97 cls&echo set /a P1=!P1!,P2=!P2!,P3=!P3!,P4=!P4!,P5=!P5!,P6=!P6!,P7=!P7!,P8=!P8!,SC=!SC!,CC=!CC!,SC2=!SC2!,CC2=!CC2!,SC3=!SC3!,CC3=!CC3!,SC4=!SC4!,CC4=!CC4! & pause
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
endlocal
cmdwiz delay 30
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
del /Q EL.dat >nul 2>nul
