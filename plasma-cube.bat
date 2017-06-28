@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 1 & cls
set /a W=110, H=70
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a RX=0, RY=0, RZ=0
set /a XMID=%W%/2, YMID=%H%/2
set /a DRAWMODE=0, ROTMODE=0, DIST=2300
set ASPECT=0.75

set STREAM="01??=00db,11??=60b1,21??=60db,31??=e6b1,41??=e6db,51??=e6db,61??=efb1,71??=feb1,81??=fedb,91??=feb1,a1??=efb1,b1??=e6db,c1??=e6b1,d1??=60db,e1??=60b1,f1??=00db,08??=00db,18??=20b1,28??=20db,38??=a2b1,48??=a2db,58??=a2db,68??=afb1,78??=afb1,88??=fadb,98??=fadb,a8??=afb1,b8??=a2db,c8??=a2b1,d8??=20db,e8??=20b1,f8??=00db,05??=00db,15??=40b1,25??=40db,35??=c4b1,45??=c4db,55??=c4db,65??=c7b1,75??=7cdb,85??=7fb1,95??=7cdb,a5??=c7b1,b5??=c4db,c5??=c4b1,d5??=40db,e5??=40b1,f5??=00db,0???=00db,1???=10b1,2???=10db,3???=91b1,4???=91db,5???=9bb2,6???=9bb1,7???=b9db,8???=bfb1,9???=9bb0,a???=9bb2,b???=91db,c???=91b1,d???=10db,e???=10b1,f???=00db"
set PAL=0 0 db 0 0 db  0 0 db 0 0 db  0 0 db 0 0 db  0 0 db 0 0 db   9 0 b2 9 0 b2  7 0 b2 7 0 b2 
set FNAME=cube-block.obj& set MOD=380,380,380, 0,0,0 1

:REP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /a COLCNT+=1,COLCNT2+=3
	
	start /B /HIGH cmdgfx_gdi "block 0 0,0,70,50 110,0 -1 0 0 %STREAM% sin((x+!COLCNT!/1)/110)*13*sin((y+!COLCNT2!/5)/65)*8 & 3d objects\!FNAME! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 !MOD!,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !PAL!" Z300f1:0,0,181,%H%,110,%H%
	
	cmdgfx "" nW10k
	
	set KEY=!ERRORLEVEL!
	if !ROTMODE! == 0 set /a RX+=3&set /a RY+=6&set /a RZ-=4
	if !KEY! == 13 set /A ROTMODE=1-!ROTMODE!&set RX=0&set RY=0&set RZ=0
	if !KEY! == 331 if !ROTMODE!==1 set /A RY+=20
	if !KEY! == 333 if !ROTMODE!==1 set /A RY-=20
	if !KEY! == 328 if !ROTMODE!==1 set /A RX+=20
	if !KEY! == 336 if !ROTMODE!==1 set /A RX-=20
	if !KEY! == 122 if !ROTMODE!==1 set /A RZ+=20
	if !KEY! == 90 if !ROTMODE!==1 set /A RZ-=20
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto REP

endlocal
bg font 6 & mode 80,50 & cls
