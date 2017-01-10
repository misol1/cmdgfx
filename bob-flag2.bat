@echo off
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cls & mode 180,80 & cmdwiz showcursor 0
for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="

set /a XC=0, YC=0, XCP=10, YCP=11
set /a BXA=15, BYA=9 & set /a BY=-!BYA!
set BALLS=""
cmdwiz setbuffersize 360 k
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a == 4 set S=_s) & (if %%b == 3 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4 & (if %%a gtr 1 if %%a lss 6 if %%b gtr 1 if %%b lss 7 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a "S=4,RND=(%%a+%%b) %% 2"& (if !RND! == 0 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set /a S=4,RND=!RANDOM! & (if !RND! lss 10000 set S=_s) & set BALLS="!BALLS:~1,-1! & image img\ball!S!-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
rem for /L %%a in (1,1,7) do set /a BY+=!BYA!,BX=180 & for /L %%b in (1,1,10) do set BALLS="!BALLS:~1,-1! & image img\ball4-t.gxy 0 0 0 -1 !BX!,!BY!"& set /a BX+=!BXA!
cmdgfx "fbox 1 0 db 180,0,180,80 & %BALLS:~1,-1%"
cmdwiz saveblock btemp 180 0 180 80
cmdwiz setbuffersize 180 k
set BALLS=

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
  start /B /HIGH cmdgfx_gdi "fbox 1 0 db 180,0,180,80 & fbox 1 0 b1 0,0,180,80 & image btemp.gxy 0 0 0 -1 180,0 & block 0 0,0,330,80 0,0 -1 0 0 ? ? 17+x-180+sin(!XC!/100+floor((x-180)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*10+eq(fgcol(x,y),1)*500  9+y+cos(!YC!/100+floor((x-180)/!BXA!)*0.4+floor(y/!BYA!)*0.4)*12" f1:0,0,330,80
  
  cmdgfx_gdi.exe "" kfa:0,0,0,0W10
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
