@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
set /a W=260,H=102
cmdwiz setfont 0 & mode %W%,%H%
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set STREAM="0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=91db,6???=9704,7???=79db,8???=7f04,9???=79db,a???=9704,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
::set STREAM="?"

call sindef.bat

set /a MODE=0, XMUL=300, YMUL=280, A1=155, A2=0, RANDPIX=3, COLCNT3=0, FADEIN=0, FADEVAL=0, WH=%W%/2
set HELP=text 7 0 0 SPACE,_UP/DOWN,_ENTER,_P,_H 1,100

:: & 3d objects\hulk.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 130,51,1600,1.5 0 0 0
:: & 3d objects\cube-block-env.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 130,51,600,1.5 0 0 0
:: & 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 0 db
:: & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,600,1.5 0 0 db
:: & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 170,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,1200,1.5 0 0 db & 3d objects\plane-block2.obj 5,-1 !RZ!,!RX!,75 -40,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,600,1.5 0 0 db 
:: & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 170,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,1200,1.5 0 0 db & 3d objects\plane-block2.obj 5,-1 !RZ!,!RX!,75 -40,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,600,1.5 0 0 db & block 0 30,0,%WH%,%H% 130,0 -1 0 0 !STREAM! random()*!RANDPIX!+sin((x+130-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*((x+130)/3) & 3d objects\plane-block2.obj 5,-1 !RZ!,!RX!,75 -40,0,0 10,10,10, 3,3,3 0,0,0,0 130,51,600,1.5 0 0 db
:: & 3d objects\cube-block-env.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 130,51,400,1.5 0 c ?
:: & 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 c ?
:: & 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 6 ?
:: & 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 6 ? & & 3d objects\eye-block.obj 5,-1 !RX!,!RY!,!RZ! 60,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2400,1.5 0 c ?
:: & 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 6 ? & & 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,1.5 0 c ? 
:: & 3d objects\hulk.obj 0,-1 !RX!,!RY!,!RZ! 0,0,0 100,100,100,0,0,0 1,0,0,0 130,51,1600,1.5 0 9 ?
 
rem if !MODE! == 0 set /a A1+=1, A2-=2 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 %STREAM% sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*(x/3)" kf0:0,0,%W%,%H% 000000,000033,881166,cc1199,e49555,923322,000000,000000,000000,66bb00,7730ee,9949ff,bb59ff,dd66ff

rem if !MODE! == 0 (if !FADEIN! gtr 4850 set FADEIN=4850) & set /a A1+=1, A2-=2 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!+sin(sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*(x/3))*(!FADEIN!/250) & !HELP!" kf0:0,0,%W%,%H%
	
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), RX+=7,RY+=12,RZ+=2, COLCNT3-=1, FADEIN+=!FADEVAL!/2, FADEVAL+=1
	
	if !MODE! == 0 set /a A1+=1, A2-=2 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5.5)/35)*(x/3) & !HELP!" kf0:0,0,%W%,%H%
	if !MODE! == 1 set /a A1+=1, A2-=3 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/1)/160)*(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10) & !HELP!" kf0:0,0,%W%,%H% 	
	if !MODE! == 2 set /a A1+=1, A2-=3 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/1)/160)*(cos(x/(y+30))*8)*sin((y+!COLCNT2!/5)/65)*(tan((y+x)/500)*10) & !HELP!" kf0:0,0,%W%,%H%	
	if !MODE! == 3 set /a A1+=1, A2-=3 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/1)/110)*(cos(x/(y+30))*8)*sin((y+!COLCNT2!/5)/65)*(sin((y+x)/100)*10) & !HELP!" kf0:0,0,%W%,%H%	
   if !MODE! == 4 set /a A1+=4, A2-=2 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/4)/110)*((x/19-y/6)*1)*sin((y+!COLCNT2!/5)/65)*((x-y)/10) & !HELP!" kf0:0,0,%W%,%H%
   if !MODE! == 5 set /a A1+=2, A2+=1 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x+!COLCNT!/10)/110)*88*sin((y+!COLCNT2!/5)/65)*98 & !HELP!" kf0:0,0,%W%,%H%
	if !MODE! == 6 set /a A1+=1, A2-=3 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+tan((x+!COLCNT!/1)/60)*(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10) & !HELP!" kf0:0,0,%W%,%H% 	
	if !MODE! == 7 set /a A1+=1, A2-=3 & cmdgfx_gdi "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin(tan((x+!COLCNT!/1)/60)/(tan(x/(y+30))*3)*tan((y+!COLCNT2!/5)/165)*(tan((y+x)/500)*10))*15 & !HELP!" kf0:0,0,%W%,%H% 	

	set KEY=!errorlevel!
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 7 set MODE=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 104 set HELP=
	if !KEY! == 328 set /a RANDPIX+=1
	if !KEY! == 336 set /a RANDPIX-=1 & if !RANDPIX! lss 0 set RANDPIX=0
	if !KEY! == 13 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
