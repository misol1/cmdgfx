@echo off
cmdwiz setfont 6 & cls & cmdwiz showcursor 0 & title RGB Plasma
if defined __ goto :START
set __=.
cmdgfx_input.exe knW35xR | call %0 %* | cmdgfx_RGB "" Sf0:0,0,238,102t4
set __=
cls
cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set F6W=&set F6H=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=238, H=102
set /a F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" set "%%v="

call centerwindow.bat 0 -12
call prepareScale.bat 0

set STREAM="0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=91db,6???=9704,7???=79db,8???=7f04,9???=79db,a???=9704,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
rem set STREAM="?"

call sindef.bat

set /a MODE=2, XMUL=300, YMUL=280, A1=155, A2=0, RANDPIX=3, COLCNT3=0, FADEIN=0, FADEVAL=0, WH=%W%/2, XMID=W/2, YMID=H/2, HLPY=H-2
set ASPECT=0.58846
set HELPMSG="text 7 0 0 SPACE,_UP/DOWN,_ENTER,_P,_H 1,%HLPY%"
set /a SHOWHELP=1
set HELP=""& if !SHOWHELP!==1 set HELP=%HELPMSG%

set /a CNT=0
for %%a in (12 18 16 15 16 14 12 16) do set /a WVAL!CNT!=%%a, CNT+=1
echo W!WVAL%MODE%!>inputflags.dat

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!), RX+=7,RY+=12,RZ+=2, COLCNT3-=1, FADEIN+=!FADEVAL!/2, FADEVAL+=1

	if !MODE! == 0 set /a A1+=1, A2-=2 & echo "cmdgfx: block 0 0,0,!W!,!H! 0,0 -1 0 0 !STREAM:~1,-1! random()*!RANDPIX!/2+sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5)/35)*(x/3) & !HELP:~1,-1! & 3d objects\plane-block.obj 5,-1 !RX!,!RY!,!RZ! 0,0,0 10,10,10, 3,3,3 0,0,0,0 !XMID!,!YMID!,600,%ASPECT% 0 0 db" Ff0:0,0,!W!,!H!


	if !MODE! == 1 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/5)/35)*(x/3),1)+store(sin((y/12*(!COLCNT!/100))/25)*127+127,3)+makecol(s3,s1/2,s1) & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!

	if !MODE! == 2 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(sin(((cos(x/140+!COLCNT!/70)*y/5)*(!COLCNT!/116))/36)*127+127,1)+store(sin(((cos(x/190+!COLCNT3!/40)*y/6)*(!COLCNT!/116))/36)*127+127,2)+store(sin((y/12*(!COLCNT!/100))/25)*127+127,3)+makecol(s3,s2,s1) & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!
	rem makecol(s3,s2,s1) = or(or(s1,shl(s2,8)),shl(s3,16))

	
	if !MODE! == 3 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store((cos((x+!COLCNT2!)/(y+30))*15)+(tan((y+x+!COLCNT!)/100*x/120)),1)+store(cos((x+y)/8)+sin((y/6+(!COLCNT!/4))/25)*127+127,3)+makecol(s3,s3,s1) & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!

	
	if !MODE! == 4 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(((floor(x/20+floor(y/15))%%2))*255,1)+store(sin(((cos(x/190+!COLCNT3!/40)*y/6)*(!COLCNT!/116))/36)*127+127,2)+store(sin((y/12*(!COLCNT!/100))/25)*127+127,3)+makecol(s3,s2,s1) & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!
	
	if !MODE! == 5 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(sin(((cos(x/140+!COLCNT!/70)*y/5)*(!COLCNT!/116))/36)*127+127,1)+store(sin((x/3*(!COLCNT2!/400))/25)*127+127,2)+store(sin((y/12*(!COLCNT!/200))/25)*127+127,3)+makecol(s3,s2,s1) & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!

	if !MODE! == 6 set /a A1+=1, A2-=2 & echo "cmdgfx: fbox 0 0 db & block 0 0,0,!W!,!H! 0,0 -1 0 0 - sin((x-!COLCNT!/6+y/3)/60)*(x/15+y/9)*15+cos((y/2+!COLCNT2!/5)/35)*(x/8)*15+36000 & !HELP:~1,-1!& skip 3d objects\eye-block.obj 5,-1 70,0,!RY! 0,0,0 2,2,2, 0,-132,0 0,0,0,0 !XMID!,!YMID!,1400,%ASPECT% 0 6 ? & skip 3d objects\eye-block.obj 5,-1 0,40,!RX! 60,40,0 2,2,2, 0,-132,0 0,0,0,0 130,51,2200,%ASPECT% 0 c ?" Ff0:0,0,!W!,!H!

		
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul ) 
	
	if "!RESIZED!"=="1" set /a W=SCRW*2*rW/100+1, H=SCRH*2*rH/100+1, XMID=W/2, YMID=H/2, HLPY=H-3 & cmdwiz showcursor 0 & set HELPMSG="text 7 0 0 SPACE,_UP/DOWN,_ENTER,_P,_H 1,!HLPY!"&if !SHOWHELP!==1 set HELP=!HELPMSG!
		
	if !KEY! == 32 set /A MODE+=1&(if !MODE! gtr 6 set MODE=1) & for %%a in (!MODE!) do echo W!WVAL%%a!>inputflags.dat

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 104 set /A SHOWHELP=1-!SHOWHELP!&(if !SHOWHELP!==0 set HELP="")&if !SHOWHELP!==1 set HELP=!HELPMSG!
	if !KEY! == 328 set /a RANDPIX+=1
	if !KEY! == 336 set /a RANDPIX-=1 & if !RANDPIX! lss 0 set RANDPIX=0
	if !KEY! == 13 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
	if !KEY! == 27 set STOP=1
	
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
