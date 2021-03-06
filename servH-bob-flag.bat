@echo off
cmdwiz setfont 8 & cls & title Bob flag (cursor up/down, left/right)
set /a F8W=180/2, F8H=80/2
mode %F8W%,%F8H%
cmdwiz showcursor 0
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12xR | call %0 %* | cmdgfx_gdi "" Sf1:0,0,330,80,180,80
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F8W=&set F8H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==FNT set "%%v="
call centerwindow.bat 0 -20
set /a W=180, H=80, WW=W*2-30, XP=163, YP=9, WM=W-30, HM=H-10, MODMOD=0

call :MAKEBALLS

set FCNT=0
set NOF_STARS=200
set SDIST=3000
set /a XMID=W/2/2, YMID=H/2
set /A TX=0,TX2=-2600,RX=0,RY=0,RZ=0,CRX=0,CRY=0,CRZ=0,TZ=0,TZ2=0
set BGCOL=0
set COLS=f %BGCOL% 04   f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% . f %BGCOL% .  f %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% . 7 %BGCOL% . 7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  7 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% .  8 %BGCOL% .  8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% . 8 %BGCOL% .  8

if exist objects\starfield200_0.ply goto REP

:SETUPLOOP
set WNAME=objects\starfield200_%FCNT%.ply
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

  ::hardcode processed block area to !W!,0,150,70, because org image is this size no matter the resolution
  echo "cmdgfx: fbox 0 0 04 !W!,0,!W!,!H! & fbox 1 %BGCOL% 20 0,0,!W!,!H! & 3d objects\starfield200_0.ply 1,1 0,0,0 !TX!,0,0 10,10,10,0,0,0 0,0,2000,10 !XMID!,!YMID!,%SDIST%,0.3 %COLS% & 3d objects\starfield200_1.ply 1,1 0,0,0 !TX2!,0,0 10,10,10,0,0,0 0,0,2000,10 !XMID!,!YMID!,%SDIST%,0.3 %COLS% & fbox 1 0 db !W!,0,!W!,!H! & image capture-0.gxy 0 0 0 -1 !W!,0 & block 0 0,0,!WW!,!H! 0,0 -1 0 0 ?2??=?6??,?a??=?e??,c4??=91??,?4??=?1??,?c??=?9??,c???=9??? ? x-!XP!+sin(!XC!/100+floor((x-!MODMOD!)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*10+eq(fgcol(x,y),1)*1000  !YP!+y+cos(!YC!/100+floor((x-!MODMOD!)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*12 to !W!,0,150,70" Ff1:0,0,!WW!,!H!,!W!,!H!Z500

  set /p INPUT=
  for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
		
  if "!RESIZED!"=="1" set /a "W=SCRW*2+2, WW=W*2-30, H=SCRH*2+2, XMID=W/2/2, YMID=H/2, XP=163+(SCRW*2-180)/2, YP=9+(SCRH*2-80)/2, WM=W-30, HM=H-10, MODMOD=W %% 15" & cmdwiz showcursor 0
  
  if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
  if !KEY! == 331 set /a XCP-=1 & if !XCP! lss 0 set /a XCP=0
  if !KEY! == 333 set /a XCP+=1
  if !KEY! == 336 set /a YCP-=1 & if !YCP! lss 0 set /a YCP=0
  if !KEY! == 328 set /a YCP+=1
  if !KEY! == 112 cmdwiz getch
  if !KEY! == 27 set STOP=1
  set /a XC+=!XCP!, YC+=!YCP!
  set /a KEY=0
)
if not defined STOP goto REP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
del /Q capture-0.gxy >nul 2>nul
goto :eof

:MAKEBALLS
set /a XC=0, YC=0, XCP=10, YCP=11
set /a BXA=15, BYA=9 & set /a BY=-!BYA!
set BALLS=""
for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=!W! & for /L %%b in (1,1,10) do set /a S=4 & (if %%a == 4 set S=_s) & (if %%b == 3 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=!W! & for /L %%b in (1,1,10) do set /a S=4 & (if %%a gtr 1 if %%a lss 6 if %%b gtr 1 if %%b lss 7 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=!W! & for /L %%b in (1,1,10) do set /a "S=4,RND=(%%a+%%b) %% 2"& (if !RND! == 0 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=!W! & for /L %%b in (1,1,10) do set /a S=4,RND=!RANDOM! & (if !RND! lss 10000 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=!W! & for /L %%b in (1,1,10) do set BALLS="!BALLS:~1,-1! & image img\ball4-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
echo "cmdgfx: fbox 1 0 db & %BALLS:~1,-1%" c:!W!,0,!WM!,!H!,1,0
set BALLS=