@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 8 & cls
set /a W=176, H=80
set /a W8=W/2, H8=H/2
mode %W8%,%H8% & cmdwiz showcursor 0
set FNT=1& rem 1 or a
if "%FNT%"=="a" mode 30,10
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==FNT if not %%v==W if not %%v==H set "%%v="

set /a XC=0, YC=0, XCP=4, YCP=5, MODE=0, WW=W*2, WWM=WW+10
set /a BXA=15, BYA=9 & set /a BY=-!BYA!, RX=0, RY=0, RZ=0
set BALLS=""
cmdwiz setbuffersize 360 80
for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a == 4 set S=_s) & (if %%b == 3 set S=_s) & set BALLS="!BALLS:~1,-1! & box f 0 db !BX!,!BY!,14,!BYA!"& set /a BX+=!BXA!
cmdgfx "fbox 1 0 04 180,0,180,80 & %BALLS:~1,-1%"
cmdwiz saveblock img\btemp 180 0 136 55
cmdwiz setbuffersize 180 80
set BALLS=
cmdwiz setbuffersize - -
if "%FNT%"=="a" cmdwiz setbuffersize 30 10

call centerwindow.bat 0 -15

set /a FCNT=0, NOF_STARS=200, SDIST=3000
set /a XMID=90/2&set /a YMID=80/2
set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,TZ=0,TZ2=0
set BGCOL=0
set COLS=f %BGCOL% 04   f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% . 7 %BGCOL% . 7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% .  8 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% .  8

set I0=myface.txt&set I1=evild.txt&set I2=ugly0.pcx&set I3=mario1.gxy&set I4=emma.txt&set I5=glass.txt&set I6=fract.txt&set I7=checkers.gxy&set I8=mm.txt&set I9=wall.pcx&set I10=btemp.gxy
set /a IC=0, CC=15

set t1=!time: =0!
:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%i in (!IC!) do for %%c in (!CC!) do (

	for /F "tokens=1-8 delims=:.," %%a in ("!t1!:!time: =0!") do set /a "a=((((1%%e-1%%a)*60)+1%%f-1%%b)*6000+1%%g%%h-1%%c%%d),a+=(a>>31)&8640000"
	if !a! geq 1 (
		set /a TX+=7&if !TX! gtr 2600 set TX=-2600
		set /a TX2+=7&if !TX2! gtr 2600 set TX2=-2600
		  
		if !MODE!==0 start /B /HIGH cmdgfx_gdi "fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & 3d objects/starfield200_0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & 3d objects/starfield200_1.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & 3d objects\cube-t2.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 250,31,600,0.75 0 0 db & block 0 0,0,330,80 0,0 -1 0 0 ? ? s0+(eq(s2,46)+eq(s2,4)+eq(s2,32)+eq(s2,0))*1000+store(char(s0,s1),2)+store(-9+y+cos(!YC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*12,1)+store(-17+x+180+sin(!XC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*10,0) s1 from 0,0,180,80 & text 9 0 0 Space_c_\g11\g10\g1e\g1f_Enter 1,78" kOf%FNT%:0,0,!WW!,!H!,!W!,!H!
		  
		if !MODE!==1 start /B /HIGH cmdgfx_gdi "fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & 3d objects/starfield200_0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & 3d objects/starfield200_1.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & image img\!I%%i! %%c 0 0 e 180,0 0 0 180,80& block 0 0,0,360,80 0,0 -1 0 0 ? ? s0+(eq(s2,46)+eq(s2,4)+eq(s2,32)+eq(s2,0))*1000+store(char(s0,s1),2)+store(0+y+cos(!YC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*12,1)+store(0+x+180+sin(!XC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*10,0) s1 from 0,0,180,80 & text 9 0 0 Space_c_\g11\g10\g1e\g1f_Enter 1,78" kOf%FNT%:0,0,!WWM!,!H!,!W!,!H!
		  
		if exist EL.dat set /p KEY=<EL.dat 2>nul & del /Q EL.dat >nul 2>nul & if "!KEY!" == "" set KEY=0
		  
		if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
		if !KEY! == 333 set /a XCP+=1
		if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
		if !KEY! == 328 set /a YCP+=1
		if !KEY! == 112 cmdwiz getch
		if !KEY! == 32 set /a IC+=1&if !IC! gtr 10 set /a IC=0
		if !KEY! == 99 set /a CC+=1&if !CC! gtr 15 set /a CC=1
		if !KEY! == 27 set STOP=1  
		if !KEY! == 13 set /a MODE=1-!MODE!  
		set /a XC+=!XCP!, YC+=!YCP!, RX+=5, RY+=7, RZ+=2
		set /a KEY=0
		set t1=!time: =0!
	)
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100 & mode 80,50 & cls
cmdwiz setfont 6 & cmdwiz showcursor 1
del /Q img\btemp.gxy >nul 2>nul
