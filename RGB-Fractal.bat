@echo off
cmdwiz setfont 8 & cls & cmdwiz showcursor 0 & title Fractal (Space=Mandel/Julia, Enter=manual/auto, cursor keys=move, x/X=zoom in manual, i/I inc/decr iterations, l=color order, a=anim, m=op)
if defined __ goto :START
set __=.
cmdgfx_input.exe knW12xR | call %0 %* | cmdgfx_RGB "" Sf1:0,0,160,80
set __=
cls & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
set /a W=160, H=80, F6W=W/2, F6H=H/2
mode %F6W%,%F6H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
call centerwindow.bat 0 -18
 
set /a WH=W/2+20, HH=H/2, zoom=300, manual=0, mandel=0, fps=0, light=0, anim=1, A=1, maxCount=10, mcMul1=255/maxCount/2, mcMul2=255/maxCount
set /a imop=0 & set mop=+&set amop=+-*/
set fpskip=skip&if !fps!==1 set fpskip=

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )
	
	if !anim!==1 set /a A=%%1
	if !manual!==0 set STR="store((!A!+80)/10000,4)"
	if !manual!==1 set STR="store(!zoom!/10000,4)"
	if !mandel!==0 set STR="!STR:~1,-1!+store((x-!WH!+20)*s4,0)+store((y-!HH!)*s4,1)+store(0,2)+store(!A!/200,4)"
	if !mandel!==1 set STR="!STR:~1,-1!+store(0,0)+store(0,1)+store(0,2)"
	if !mandel!==0 for /l %%a in (1,1,!maxCount!) do set STR="!STR:~1,-1!+store(s0*s0-s1*s1-0.7,3)+store(min(2*s0*s1+s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0!mop!s1*s1,4)+s2,2)"
	if !mandel!==1 for /l %%a in (1,1,!maxCount!) do set STR="!STR:~1,-1!+store(s0*s0-s1*s1+(x-!WH!)*s4,3)+store(min(2*s0*s1+(y-!HH!)*s4,4),1)+store(min(s3,4),0)+store(lss(s0*s0!mop!s1*s1,4)+s2,2)"
	if !light!==0 set STR="!STR:~1,-1!+makecol(0,s2*!mcMul1!,s2*!mcMul2!)"
	if !light!==1 set STR="!STR:~1,-1!+makecol(0,(!maxCount!-s2)*!mcMul1!,(!maxCount!-s2)*!mcMul2!)"
	echo "cmdgfx: fbox 0 0 b1 & block 0 0,0,!W!,!H! 0,0 -1 0 0 - !STR:~1,-1! & !fpskip! text a 0 0 [FRAMECOUNT] 1,1" Ff1:0,0,!W!,!H!
	
	if "!RESIZED!"=="1" set /a "W=SCRW*2+2, H=SCRH*2+2, WH=W/2+20, HH=H/2" & cmdwiz showcursor 0

	if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
	if !KEY! == 331 set /a WH+=2
	if !KEY! == 333 set /a WH-=2
	if !KEY! == 328 set /a HH+=2
	if !KEY! == 336 set /a HH-=2
	if !KEY! == 120 if !manual!==1 set /a zoom-=2
	if !KEY! == 88  if !manual!==1 set /a zoom+=2
	if !KEY! == 13 set /a manual=1-manual
	if !KEY! == 32 set /a mandel=1-mandel
	if !KEY! == 97 set /a anim=1-anim, manual=1-anim
	if !KEY! == 108 set /a light=1-light
	if !KEY! == 109 set /a imop+=1 & (if !imop! gtr 3 set /a imop=0) & for %%c in (!imop!) do set mop=!amop:~%%c,1!
	if !KEY! == 102 set /a fps=1-fps&set fpskip=skip&if !fps!==1 set fpskip=
	if !KEY! == 105 set /a maxCount+=1, mcMul1=255/maxCount/2, mcMul2=255/maxCount
	if !KEY! == 73 set /a maxCount-=1 & (if !maxCount! lss 1 set /a maxCount=1) & set /a mcMul1=255/maxCount/2, mcMul2=255/maxCount
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit" & title input:Q
