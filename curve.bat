@echo off
setlocal ENABLEDELAYEDEXPANSION
set /a W=260,H=102
cmdwiz setfont 0 & mode %W%,%H%
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

set STREAM="0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=91db,6???=9704,7???=79db,8???=7f04,9???=79db,a???=9704,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
::set STREAM="?"

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "SINE(x)=(a=(x)%%62832, c=(a>>31|1)*a, t=((c-47125)>>31)+1, a-=t*((a>>31|1)*62832)  +  ^^^!t*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_SIN="

set /a MODE=0, XMUL=300, YMUL=280, SHR=13, A1=155, A2=0, RANDPIX=3, COLCNT3=0, FADEIN=0, FADEVAL=0, WH=%W%/2
set HELP=text 7 0 0 SPACE,_UP/DOWN,_ENTER,_P,_H 1,100

:: & 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 130,51,1400,1.5 0 6 ? & & 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,1.5 0 c ?

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), RX+=7,RY+=12,RZ+=2, COLCNT3-=1, FADEIN+=!FADEVAL!/2, FADEVAL+=1

	rem if !MODE! == 1 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! sin((x-!COLCNT!/4+!COLCNT2!/10)/80)*tan(y/90)*(gtr(y,cos((x-!A2!)/55)*(!COLCNT!/6)+50+sin(y+!A1!)/30)*20)*2" f0:0,0,%W%,%H%

	if !MODE! == 0 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x-!COLCNT!/4+!COLCNT2!/10)/80)*(gtr(y,cos((x-!A2!)/55)*(!COLCNT!/6)+50+sin(y+!A1!)/30)*20)*2 & !HELP!" f0:0,0,%W%,%H%
	if !MODE! == 1 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x-!COLCNT!/4+!COLCNT2!/10)/80)*(gtr(y,cos((x-!A2!)/55)*(!COLCNT!/6)+50+sin(y+!A1!)/30)*20)/2 & !HELP!" f0:0,0,%W%,%H%
	if !MODE! == 2 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+1*(gtr(y,cos((x-!A2!)/55)*(!COLCNT!/6)+50+sin(y+!A1!)/30)*20)*1 & !HELP!" f0:0,0,%W%,%H%
	if !MODE! == 3 set /a A1+=1, A2-=2 & start "" /high /B cmdgfx_gdi.exe "block 0 0,0,%W%,%H% 0,0 -1 0 0 !STREAM! sin((x-!COLCNT!/4)/80)*(gtr(y,20))*15 & !HELP!" f0:0,0,%W%,%H%

	rem getkey /N
	cmdwiz.exe getch nowait
	set KEY=!errorlevel!
	
	if !KEY! == 32 set /A MODE+=1&if !MODE! gtr 3 set MODE=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 104 set HELP=
	if !KEY! == 328 set /a RANDPIX+=1
	if !KEY! == 336 set /a RANDPIX-=1 & if !RANDPIX! lss 0 set RANDPIX=0
	if !KEY! == 13 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 30
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
