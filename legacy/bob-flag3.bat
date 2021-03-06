@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cls & mode 180,80 & cmdwiz showcursor 0
set FNT=1& rem 1 or a
if "%FNT%"=="a" mode 30,10
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==FNT set "%%v="

set /a XC=0, YC=0, XCP=10, YCP=11
set /a BXA=15, BYA=9 & set /a BY=-!BYA!
set BALLS=""
cmdwiz setbuffersize 360 80
for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a == 4 set S=_s) & (if %%b == 3 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a gtr 1 if %%a lss 6 if %%b gtr 1 if %%b lss 7 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a "S=4,RND=(%%a+%%b) %% 2"& (if !RND! == 0 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4,RND=!RANDOM! & (if !RND! lss 10000 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set BALLS="!BALLS:~1,-1! & image img\ball4-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
cmdgfx "fbox 1 0 db 180,0,180,80 & %BALLS:~1,-1%"
cmdwiz saveblock btemp 180 0 180 80
cmdwiz setbuffersize 180 80
set BALLS=
if "%FNT%"=="a" cmdwiz setbuffersize 30 10

set FCNT=0
set NOF_STARS=200
set SDIST=3000
set /a XMID=90/2&set /a YMID=80/2
set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,CRX=0,CRY=0,CRZ=0,TZ=0,TZ2=0
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
set /A FCNT+=1
if %FCNT% lss 2 goto SETUPLOOP

:REP
for /L %%1 in (1,1,300) do if not defined STOP (

  set /a TX+=7&if !TX! gtr 2600 set TX=-2600
  set /a TX2+=7&if !TX2! gtr 2600 set TX2=-2600

  start /B /HIGH cmdgfx_gdi "fbox 0 0 04 180,0,180,80 & fbox 1 %BGCOL% 20 0,0,180,80 & & 3d starfield0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & 3d starfield0.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 %XMID%,%YMID%,%SDIST%,0.3 %COLS% & image btemp.gxy 0 0 0 -1 180,0 & block 0 0,0,330,80 0,0 -1 0 0 ?2??=?6??,?a??=?e??,c4??=91??,?4??=?1??,?c??=?9??,c???=9??? ? 17+x-180+sin(!XC!/100+floor((x-180)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*10+(eq(fgcol(x,y),1)+eq(char(x,y),46)+eq(char(x,y),4))*1000  9+y+cos(!YC!/100+floor((x-180)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*12 to 180,0,150,70" f%FNT%:0,0,330,80,180,80
  
  cmdgfx.exe "" knW10
  set KEY=!errorlevel!
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1  
  set /a XC+=!XCP!, YC+=!YCP!
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100 & mode 80,50 & cls
cmdwiz setfont 6 & cmdwiz showcursor 1
del /Q btemp.gxy >nul 2>nul
del /Q starfield?.ply >nul
