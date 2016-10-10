@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=140 & set /a WW=!W!*2
cmdwiz setfont 5 & mode %W%,52
cmdwiz setbuffersize %WW% 120
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="

set STREAM="0???=00db,1???=10b1,2???=10db,3???=91b1,4???=91db,5???=91db,6???=97b1,7???=79db,8???=7fb1,9???=79db,a???=97b1,b???=91db,c???=91b1,d???=10db,e???=10b1,f???=00db"
set STREAM="01??=00db,11??=60b1,21??=60db,31??=e6b1,41??=e6db,51??=e6db,61??=efb1,71??=feb1,81??=fedb,91??=feb1,a1??=efb1,b1??=e6db,c1??=e6b1,d1??=60db,e1??=60b1,f1??=00db,08??=00db,18??=20b1,28??=20db,38??=a2b1,48??=a2db,58??=a2db,68??=afb1,78??=afb1,88??=fadb,98??=fadb,a8??=afb1,b8??=a2db,c8??=a2b1,d8??=20db,e8??=20b1,f8??=00db,05??=00db,15??=40b1,25??=40db,35??=c4b1,45??=c4db,55??=c4db,65??=c7b1,75??=7cdb,85??=7fb1,95??=7cdb,a5??=c7b1,b5??=c4db,c5??=c4b1,d5??=40db,e5??=40b1,f5??=00db,0???=00db,1???=10b1,2???=10db,3???=91b1,4???=91db,5???=9bb2,6???=9bb1,7???=b9db,8???=bfb1,9???=9bb0,a???=9bb2,b???=91db,c???=91b1,d???=10db,e???=10b1,f???=00db"
::set STREAM="?"

set /a MODE=0, COLCNT=0, COLCNT2=0

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	if !MODE! == 0 set /a COLCNT+=2,COLCNT2+=9 & cmdgfx_gdi "block 0 0,0,%W%,75 0,0 -1 0 0 %STREAM% sin((x+!COLCNT!/1)/110)*13*sin((y+!COLCNT2!/5)/65)*8" kf6W25
   if !MODE! == 1 set /a COLCNT+=4,COLCNT2+=12 & cmdgfx_gdi "block 0 0,0,%W%,75 0,0 -1 0 0 %STREAM% sin((x+!COLCNT!/4)/110)*8*sin((y+!COLCNT2!/5)/65)*8" kf6W25
   if !MODE! == 2 set /a COLCNT+=1,COLCNT2+=3 & cmdgfx_gdi "block 0 0,0,%W%,75 0,0 -1 0 0 %STREAM% sin((x+!COLCNT!)/80)*128+cos((y+!COLCNT2!/1.5)/35)*68" kf6W25
   if !MODE! == 3 set /a COLCNT+=1,COLCNT2+=3 & cmdgfx_gdi "block 0 0,0,%W%,75 0,0 -1 0 0 %STREAM% sin((x+!COLCNT!/10)/110)*88*sin((y+!COLCNT2!/5)/65)*98" kf6W25
	if !MODE! == 4 set /a COLCNT+=2,COLCNT2+=9 & cmdgfx_gdi "block 0 0,0,%W%,75 0,0 -1 0 0 %STREAM% random()*2+cos(x/60*y/85+!COLCNT!/19)*190" kf6W25

	set KEY=!errorlevel!
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 4 set MODE=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
