@rem Use with "Screen Launcher": http://www.softpedia.com/get/Desktop-Enhancements/Screensavers/Screen-Launcher.shtml
@echo off
cd /D "%~dp0"
if defined __ goto :START
cmdwiz setfont 6 & cls
mode 80,50 & cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0 & cmdwiz setmousecursorpos 10000 100
cmdwiz getconsoledim sw
set /a W=%errorlevel% * 2 * 4 + 4
cmdwiz getconsoledim sh
set /a H=%errorlevel% * 2 * 6 + 10
set __=.
call %0 %* | cmdgfx_gdi "" W10m0O%TOP%eSfa:0,0,!W!,!H!
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set TOP=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" if /I not "%%v"=="PATH" set "%%v="

call sindef.bat
set /a DIV=2 & set /a XMID=%W%/2/!DIV!,YMID=%H%/2/!DIV!, XMUL=%W%/2/!DIV!, YMUL=%H%/2/!DIV!, SXMID=%W%/2,SYMID=%H%/2, SHR=13, DELAY=0, KEY=0
set /a LINEGAP=15, NOFBEZ=11, LNCNT=1, DCNT=0, REP=80, COL=10, STARTLINE=1, REALCOL=4, CHANGE=1, CHANGESTEPS=200 & set /a NOFLINES=!NOFBEZ!*!LINEGAP!& set /a CHANGECOUNT=!CHANGESTEPS!,STARTCNT=0
set PALETTE1=000000,000000,000000,000000,000000,0020ff,0040ff,0060ff,0080ff,20a0ff,20b0ff,50c0ff,80e0ff,b0f0ff,f0ffff,ffffff
set PALETTE2=-
set PALETTE3=000000,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00,00ff00
set PALETTE4=000000,000000,000000,000000,000000,000080,0050a0,0050a0,0050a0,2090e0,2090e0,50b0ff,80d0ff,b0f0ff,f0ffff,ffffff
for %%a in (!REALCOL!) do set PAL=!PALETTE%%a!
set DRAWOP=0&set D0=line&set D1=ipoly&set D2=fellipse&set D3=fbox&set D4=fcircle&set D5=ellipse&set BITOP=3
for /L %%a in (1,1,%NOFLINES%) do set LN%%a= 
set "DIC=QWERTYUIOPASDFGHJKLZXCVBNM@#$+[]{}"
cmdwiz stringlen %DIC% & set /a DICLEN=!errorlevel!

set /a P1=-1,P2=1,P3=-1,P4=2,P5=-1,P6=2,P7=-1,P8=0,SC=21211,CC=17675,SC2=-15297,CC2=7463,SC3=60228,CC3=-32628,SC4=-25759,CC4=16335

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "LCNT+=1, DCNT=(!DCNT!+1) %% %DICLEN%"
   if !LCNT! gtr %NOFLINES% set LCNT=1
	
	for /L %%a in (1,1,!REP!) do set /a "SC+=!P1!, CC+=!P2!, SC2+=!P3!, CC2+=!P4!, SC3+=!P5!, CC3+=!P6!, SC4+=!P7!, CC4+=!P8!"

	for %%a in (!SC!) do for %%b in (!CC!) do set /a A1=%%a,A2=%%b & set /a "XPOS=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC2!) do for %%b in (!CC2!) do set /a A1=%%a,A2=%%b & set /a "XPOS2=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS2=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC3!) do for %%b in (!CC3!) do set /a A1=%%a,A2=%%b & set /a "XPOS3=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS3=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	for %%a in (!SC4!) do for %%b in (!CC4!) do set /a A1=%%a,A2=%%b & set /a "XPOS4=!XMID!+(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), YPOS4=!YMID!+(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"

	set /a CHANGECOUNT-=1,STARTCNT-=1 & if !CHANGECOUNT!==0 if !CHANGE!==1 set /a CHANGECOUNT=!CHANGESTEPS!, RAND=!RANDOM! %% 8 + 1 & for %%a in (!RAND!) do set /a "P%%a+=(!RANDOM! %% 2)*2 - 1" & (if !P%%a! gtr 2 set /a P%%a=2) & (if !P%%a! lss -1 set /a P%%a=-1)
	
	if not !DRAWOP!==1 for %%a in (!DCNT!) do set LN!LCNT!=!DIC:~%%a,1! !XPOS!,!YPOS!,!XPOS2!,!YPOS2! !XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	if !DRAWOP!==1 for %%a in (!DCNT!) do set LN!LCNT!=!DIC:~%%a,1! !BITOP! !XPOS!,!YPOS!,!XPOS2!,!YPOS2!,!XPOS3!,!YPOS3!,!XPOS4!,!YPOS4!
	set STR=""&set REP=1
	set /a CNT=!LCNT!+!LINEGAP!, COLVAL=4 & if !CNT! gtr %NOFLINES% set /a CNT-=%NOFLINES%

   for %%a in (!DRAWOP!) do set DRAW=!D%%a!
	for /L %%a in (!STARTLINE!,%LINEGAP%,%NOFLINES%) do for %%b in (!CNT!) do (if not "!LN%%b!"==" " set STR="!STR:~1,-1!&!DRAW! !COLVAL! 0 !LN%%b!")& set /a CNT+=!LINEGAP!,COLVAL+=1 & if !CNT! gtr %NOFLINES% set /a CNT-=%NOFLINES%
	set /a STARTLINE+=1&if !STARTLINE! gtr %LINEGAP% set STARTLINE=1

	if !STARTCNT! lss 0 if !DIV! == 1 echo "cmdgfx: fbox !COL! 0 00 & !STR:~1,-1!" fa:0,0,!W!,!H! !PAL!
 	if !STARTCNT! lss 0 if !DIV! == 2 echo "cmdgfx: fbox !COL! 0 00 & !STR:~1,-1! & block 0 0,0,!SXMID!,!SYMID! !SXMID!,0 -1 1 0 & block 0 0,0,!SXMID!,!SYMID! 0,!SYMID! -1 0 1 & block 0 0,0,!SXMID!,!SYMID! !SXMID!,!SYMID! -1 1 1" fa:0,0,!W!,!H! !PAL!
	set STR=

	if exist EL.dat set /p EVENTS=<EL.dat & del /Q EL.dat >nul 2>nul & set /a "KEY=!EVENTS!>>22, MOUSE_EVENT=!EVENTS!&1"
	
	if !KEY! == 112 set /a KEY=0 & cmdwiz getch
	if !KEY! neq 0 set STOP=1
	if !MOUSE_EVENT! neq 0 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
