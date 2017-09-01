@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 1 & cls & mode 180,80 & cmdwiz showcursor 0
set FNT=1& rem 1 or a
if "%FNT%"=="a" mode 30,10s
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==FNT set "%%v="

set /a XC=0, YC=0, XCP=10, YCP=11, MODE=0
set /a BXA=15, BYA=9 & set /a BY=-!BYA!
set BALLS=""
cmdwiz setbuffersize 360 80
for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a == 4 set S=_s) & (if %%b == 3 set S=_s) & set BALLS="!BALLS:~1,-1! & box f 0 db !BX!,!BY!,14,!BYA!"& set /a BX+=!BXA!
cmdgfx "fbox 1 0 04 180,0,180,80 & %BALLS:~1,-1%"
cmdwiz saveblock img\btemp 180 0 136 55
cmdwiz setbuffersize 180 80
set BALLS=
if "%FNT%"=="a" cmdwiz setbuffersize 30 10

set /a FCNT=0, NOF_STARS=200, SDIST=3000
set /a XMID=90/2&set /a YMID=80/2
set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,TZ=0,TZ2=0
set BGCOL=0
set COLS=f %BGCOL% 04   f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% . 7 %BGCOL% . 7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% .  8 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% .  8

:SETUPLOOP
	set WNAME=starfield%FCNT%.ply
	echo ply>%WNAME%
	echo format ascii 1.0 >>%WNAME%
	set /A NOF_V=%NOF_STARS% * 1
	echo element vertex %NOF_V% >>%WNAME%
	echo element face %NOF_STARS% >>%WNAME%
	echo end_header>>%WNAME%

	for /L %%a in (1,1,%NOF_STARS%) do set /A vx=!RANDOM! %% 240 -120 & set /A vy=!RANDOM! %% 200 -100 & set /A vz=!RANDOM! %% 400-160 & echo !vx! !vy! !vz!>>%WNAME%
	set CNT=0&for /L %%a in (1,1,%NOF_STARS%) do set /A CNT1=!CNT!&set /A CNT+=1& echo 1 !CNT1! >>%WNAME%
	set /a FCNT+=1
if %FCNT% lss 2 goto SETUPLOOP

set I0=myface.txt&set I1=evild.txt&set I2=ugly0.pcx&set I3=mario1.gxy&set I4=emma.txt&set I5=glass.txt&set I6=fract.txt&set I7=checkers.gxy&set I8=mm.txt&set I9=wall.pcx&set I10=btemp.gxy
set /a IC=4, CC=15

:REP
for /L %%1 in (1,1,300) do if not defined STOP for %%i in (!IC!) do for %%c in (!CC!) do (

  set /a TX+=7&if !TX! gtr 2600 set TX=-2600
  set /a TX2+=7&if !TX2! gtr 2600 set TX2=-2600
  
  if !MODE!==0 start /B /HIGH cmdgfx_gdi "fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & 3d starfield0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & 3d starfield0.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & image img\!I%%i! %%c 0 0 e 180,0 0 0 140,60& block 0 0,0,330,80 0,0 -1 0 0 ? ? s0+(eq(s2,46)+eq(s2,4)+eq(s2,32)+eq(s2,0))*1000+store(char(s0,s1),2)+store(-9+y+cos(!YC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*12,1)+store(-17+x+180+sin(!XC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*10,0) s1 from 0,0,180,80 & text 9 0 0 Space_c_\g11\g10\g1e\g1f_Enter 1,78" f%FNT%:0,0,330,80,180,80
  
  if !MODE!==1 start /B /HIGH cmdgfx_gdi "fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & 3d starfield0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.5 %COLS% & 3d starfield0.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.5 %COLS% & image img\!I%%i! %%c 0 0 e 180,0 0 0 180,80& block 0 0,0,360,80 0,0 -1 0 0 ? ? s0+(eq(s2,46)+eq(s2,4)+eq(s2,32)+eq(s2,0))*1000+store(char(s0,s1),2)+store(0+y+cos(!YC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*12,1)+store(0+x+180+sin(!XC!/100+((x)/!BXA!)*0.4+(y/!BYA!)*0.4)*10,0) s1 from 0,0,180,80 & text 9 0 0 Space_c_\g11\g10\g1e\g1f_Enter 1,78" f%FNT%:0,0,360,80,180,80

  cmdgfx.exe "" knW14
  set KEY=!errorlevel!
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 32 set /a IC+=1&if !IC! gtr 10 set /a IC=0
  if !KEY! == 99 set /a CC+=1&if !CC! gtr 15 set /a CC=1
  if !KEY! == 27 set STOP=1  
  if !KEY! == 13 set /a MODE=1-!MODE!  
  set /a XC+=!XCP!, YC+=!YCP!
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100 & mode 80,50 & cls
bg font 6 & cmdwiz showcursor 1
del /Q img\btemp.gxy >nul 2>nul
del /Q starfield?.ply >nul
