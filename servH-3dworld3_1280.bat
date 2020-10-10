:: 3dworld with perspective correct texture mapping : Mikael Sollenborn 2016-17
@echo off
cls & cmdwiz setfont 6 & title 3d World big pixel (Mouse + left/right/j/k up/down/w/s a/d PgUp/PgDwn Home/End Space m e)
cmdwiz showcursor 0
if defined __ goto :START
set /a F6W=320/2, F6H=110/2
mode %F6W%,%F6H%
set __=.
cmdgfx_input.exe M0unW25xR | call %0 %* | cmdgfx_gdi "" Sfa:0,0,1280,680Z800
set __=
mode 80,50
cls & cmdwiz setfont 6
set F6W=&set F6H=
goto :eof

:START
@echo off
setlocal ENABLEDELAYEDEXPANSION
for /F "Tokens=1 delims==" %%v in ('set') do if /I not %%v==PATH set "%%v="

set /a W=1280, H=680

call centerwindow.bat 0 -20
call prepareScale.bat 10

set /a TXTX=142*rW/100, TXTY=51*rH/100

echo "cmdgfx: text 8 0 0 Generating_world... %TXTX%,%TXTY%" f0:0,0,620,310

set /a XMID=%W%/2, YMID=%H%/2-10
set /a DIST=0, DRAWMODE=5, GROUNDCOL=2, MULVAL=250, YMULVAL=125"
set ASPECT=1.00937
set /a RX=0, RY=720, RZ=0

::set CUBECOLS=0 4 b1 0 4 b1  0 4 b1  0 4 b1  0 4 b0 0 4 b0  0 1 b1 0 1 b1  0 1 b1  0 1 b1  0 1 b0 0 1 b0
set CUBECOLS=0 0 b2 0 0 b2  0 0 b1  0 0 b1  0 0 b0 0 0 b0
set GROUNDCOLS=0 0 b2  0 0 b0

set /A CNT=0, SLOTS=0
set FWORLD=data\3dworld2.dat
if not "%~1" == "" if exist %1 set FWORLD=%1
for /F "tokens=*" %%i in (%FWORLD%) do (if !SLOTS!==0 cmdwiz stringlen "%%i"&set SLOTS=!ERRORLEVEL!)& set WRLD!CNT!=%%i&set /A CNT+=1
set YSLOTS=%CNT%

set FN=objects\3dworld.obj
set FN2=objects\3dworld-ground.obj

set /A PLX=%SLOTS%/2,PLZ=%YSLOTS%/2
set /A XC=-%SLOTS%
set /A SLOTM=%SLOTS%-1
set /A YC=-%YSLOTS%
set /A YSLOTM=%YSLOTS%-1
set /A CNT=0 & for /L %%i in (0,1,%YSLOTM%) do set SS=!WRLD%%i!& for /L %%j in (0,1,%SLOTM%) do set S=!SS:~%%j,1!&if not "!S!"=="-" for %%a in (!CNT!) do set t%%a=!S!&set sx%%a=1&set sz%%a=1&set sy%%a=!S!&set /A dx%%a = %XC%+%%j*2 & set /A dy%%a=3 & set /A dz%%a = %YC%+%%i*2 & set /A CNT+=1&(if "!S!"=="o" set /A CNT-=1&set /A PLX=%%j*2&set /A PLZ=%%i*2)&(if "!S!"=="M" set /A sy%%a=9)&(if "!S!"=="N" set /A sy%%a=6)

set /A TX=(%XC%+%PLX%)*%MULVAL%&set TY=0&set /A TZ=(%YC%+%PLZ%)*%MULVAL%*-1

set NOF_OBJECTS=%CNT%
set /A NOF_V=%NOF_OBJECTS%*8
set /A NOF_F=%NOF_OBJECTS%*6

if exist %FN% if exist %FN2% set /A TX=(%XC%+%PLX%)*%MULVAL%&set TY=0&set /A TZ=(%YC%+%PLZ%)*%MULVAL%*-1 & goto SKIPGEN

cmdwiz print "usemtl img\\tile_door.pcx\nvt 0 0\nvt 0 1\nvt 1 1\nvt 1 0\n">%FN%

set Vx0=-1&set Vy0=-1&set Vz0=-1
set Vx1=1& set Vy1=-1&set Vz1=-1
set Vx2=1& set Vy2=1& set Vz2=-1
set Vx3=-1&set Vy3=1& set Vz3=-1
set Vx4=-1&set Vy4=-1&set Vz4=1
set Vx5=1& set Vy5=-1&set Vz5=1
set Vx6=1& set Vy6=1& set Vz6=1
set Vx7=-1&set Vy7=1& set Vz7=1

set F0_0=0&set F0_1=3&set F0_2=2&set F0_3=1
set F1_0=5&set F1_1=6&set F1_2=7&set F1_3=4
set F2_0=6&set F2_1=5&set F2_2=1&set F2_3=2
set F3_0=3&set F3_1=0&set F3_2=4&set F3_3=7
set F4_0=7&set F4_1=6&set F4_2=2&set F4_3=3
set F5_0=5&set F5_1=4&set F5_2=0&set F5_3=1

set /A NOF_O=%NOF_OBJECTS%-1
set OUTP=
set /a WCNT=0
set CNT=1&for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,7) do set /a vx=!Vx%%b!&(if not "!sx%%a!"=="" set /a vx*=!sx%%a!)&set /a vx-=!dx%%a!&set /a vx*=%MULVAL% & set /a vy=!Vy%%b!&(if not "!sy%%a!"=="" if !vy! lss 0 set /a vy*=!sy%%a!)&set /a vy+=!dy%%a!&set /a vy*=%YMULVAL% & set /a vz=!Vz%%b!&(if not "!sz%%a!"=="" set /a vz*=!sz%%a!)&set /a vz+=!dz%%a!&set /a vz*=%MULVAL%&set OUTP=!OUTP!v !vx! !vy! !vz!\n&set /A CNT+=1, WCNT+=1&if !WCNT! gtr 60 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN% & set OUTP=
cmdwiz print "!OUTP!">>%FN%&set OUTP=
set /a WCNT=0
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if not !t%%a!==M if not !t%%a!==N set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&set OUTP=!OUTP!f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/\n& set /a WCNT+=1&if !WCNT! gtr 60 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN% & set OUTP=
cmdwiz print "!OUTP!">>%FN%&set OUTP=
echo usemtl img\dos_shade4.pcx >>%FN%
set /a WCNT=0
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if !t%%a!==M set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&set OUTP=!OUTP!f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/\n& set /a WCNT+=1&if !WCNT! gtr 60 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN% & set OUTP=
cmdwiz print "!OUTP!">>%FN%&set OUTP=
echo usemtl img\dos_shade2.pcx >>%FN%
set /a WCNT=0
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if !t%%a!==N set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&set OUTP=!OUTP!f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/\n& set /a WCNT+=1&if !WCNT! gtr 60 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN% & set OUTP=
cmdwiz print "!OUTP!">>%FN%&set OUTP=

for /L %%a in (0,1,7) do set Vx%%a=&set Vy%%a=&set Vz%%a=&set F%%a_0=&set F%%a_1=&set F%%a_2=&set F%%a_3=
for /L %%a in (0,1,%CNT%) do set sx%%a=&set sy%%a=&set sz%%a=&set dx%%a=&set dy%%a=&set dz%%a=&set t%%a=

cmdwiz print "usemtl img\\tile_ground.pcx\nvt 0 0\nvt 0 1\nvt 1 1\nvt 1 0\n">%FN2%

set TILESIZE=1000
set /A CNT=1, CNT2=0, WCNT=0
set OUTP=
for /L %%a in (-20000,%TILESIZE%,20000) do for /L %%b in (-20000,%TILESIZE%,20000) do set /A V1=%%a,V2=%%a+%TILESIZE%,V3=%%b,V4=%%b+%TILESIZE% & set OUTP=!OUTP!v !V1! 500 !V3!\nv !V2! 500 !V3!\nv !V2! 500 !V4!\nv !V1! 500 !V4!\n&set /A CNT2+=1, WCNT+=1&if !WCNT! gtr 90 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN2% & set OUTP=
cmdwiz print "!OUTP!">>%FN2%&set OUTP=
set /a WCNT=0
for /L %%a in (1,1,%CNT2%) do set /a f0=!CNT!&set /a f1=!CNT!+1&set /a f2=!CNT!+2&set /a f3=!CNT!+3 & set OUTP=!OUTP!f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/\n& set /A CNT+=4,WCNT+=1&if !WCNT! gtr 90 set /a WCNT=0 & cmdwiz print "!OUTP!">>%FN2% & set OUTP=
cmdwiz print "!OUTP!">>%FN2%&set OUTP=

set TILESIZE=&set vx=&set vy=&set vz=&set PLX=&set PLZ=&set CNT2=&for /L %%a in (0,1,4) do set f%%a=&set V%%a=

:SKIPGEN
call :MAKEBKG

set /A MAP=0,ZMOD=0,XMOD=0, XMAP=W-40*rW/100
set MAPTXT=image data/3dworld2.dat e 0 0 - %XMAP%,15

set STOP=
cmdwiz gettime&set ORGT=!errorlevel!
set FN4=wrld-temp.obj
set /a ENEMY=0, WCNT=0
set DELOBJ=& if !ENEMY! == 1 set DELOBJ=D

set /A "f0=%NOF_V%+1,f1=%NOF_V%+1+1,f2=%NOF_V%+1+2,f3=%NOF_V%+1+3"
set /A XP1=0,XP2=500,DELT=300, CNT=0, BOUNDSCHECK=1
copy /Y %FN% %FN4%>nul
for /l %%a in (1,1,10) do set /p INPUT=

set /a SW/=2, SH/=2
set /a MPY=%SH%-%H%/4 & cmdwiz setmousecursorpos %SW% !MPY!
set /a ZVAL=800

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (
	if !MAP!==1 set /A "XP=(!TX!+!XMOD!)/(%MULVAL%*2)+%SLOTS%/2+(W-40*rW/100), ZP=(%YSLOTS%)/2-(!TZ!+!ZMOD!)/(%MULVAL%*2)+15" & set MAPP=pixel c 0 db !XP!,!ZP!

	set FN3=%FN4%
	if !ENEMY! == 1 (
		set /a WCNT+=1
		if !WCNT! gtr 9 set /a WCNT=0
		set FN3=wrld-temp!WCNT!.obj
		
		copy /Y %FN% !FN3!>nul
		set /A "XP1+=!DELT!, XP2+=!DELT!"
		if !XP1! gtr 3500 set DELT=-300
		if !XP1! lss -5000 set DELT=300

		echo v 250 -100 !XP1! >>!FN3!
		echo v 750 -100 !XP1! >>!FN3!
		echo v 750 500 !XP1! >>!FN3!
		echo v 250 500 !XP1! >>!FN3!

		set /A "CNT+=1,FRM=(!CNT!/8) %% 2"
		echo usemtl img\ugly!FRM!.pcx e >>!FN3!
		echo f !f0!/1/ !f1!/4/ !f2!/3/ !f3!/2/>>!FN3!
		echo f !f0!/1/ !f3!/2/ !f2!/3/ !f1!/4/>>!FN3!
	)
	
	echo "cmdgfx: !BKSTR:~1,-1! & 3d %FN2% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,-200,0,300 !XMID!,!YMID!,%DIST%,!ASPECT! %GROUNDCOLS% & 3d !FN3! !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,-200,0,300 !XMID!,!YMID!,%DIST%,%ASPECT% !CUBECOLS! & !MAPT! & !MAPP!" F!DELOBJ!fa:0,0,!W!,!H!Z!ZVAL!
	
	set /p INPUT=
rem echo !INPUT!
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22, 24,26,28" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, K_KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L, RESIZED=%%M, SCRW=%%N, SCRH=%%O 2>nul )

	if "!RESIZED!"=="1" set /a W=SCRW*2*4*rW/100+6, H=SCRH*2*6*rH/100+8, XMID=W/2, YMID=H/2, HLPY=H-3, XMAP=W-40*rW/100, ZVAL=480+W/4 & cmdwiz showcursor 0 & call :MAKEBKG & set MAPTXT=image data/3dworld2.dat e 0 0 - !XMAP!,15& if !MAP!==1 set MAPT=!MAPTXT!
	
	if not "!EV_BASE:~0,1!" == "N" (
	
		if not "!OLDMX!"=="" if !M_EVENT!==1 if !M_LB!==0 if !M_WHEEL!==0 set /a "RY+=(!OLDMX!-!M_X!)*2,TY-=(!OLDMY!-!M_Y!)*2,YMID+=(!OLDMY!-!M_Y!)*2"&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !M_WHEEL!==1 set /a RY+=720&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !M_WHEEL!==-1 set /a RY+=720&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !M_EVENT!==1  if !M_WHEEL!==0 set /a OLDMX=!M_X!,OLDMY=!M_Y!

		if !K_EVENT!==1 (
			if !K_DOWN!==0 (
			   set /a KEY=!K_KEY!
				if !KEY! == 10 cmdwiz getfullscreen & set /a ISFS=!errorlevel! & (if !ISFS!==0 cmdwiz fullscreen 1) & (if !ISFS! gtr 0 cmdwiz fullscreen 0)
				if !KEY! == 109 set MAPP=&set /a MAP=1-!MAP!&(if !MAP!==0 set MAPT=)&(if !MAP!==1 set MAPT=!MAPTXT!)
				if !KEY! == 112 cmdwiz getch
				if !KEY! == 32 set /a YMID=%H%/2-4, TY=0, BOUNDSCHECK=1
				if !KEY! == 27 set STOP=1
				if !KEY! == 101 set /A ENEMY=1-!ENEMY! & set DELOBJ=&if !ENEMY! == 1 set DELOBJ=D
				set /a KEY=0
			)
			if !K_DOWN!==1 set /a KEY=!K_KEY!
		)
	)

	if not !KEY! == 0 (
		if !KEY! == 331 set /a RY+=16&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !KEY! == 333 set /a RY-=16&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !KEY! == 106 set /a RY+=16&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !KEY! == 107 set /a RY-=16&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !KEY! == 97 set ORY=!RY!&set /a RY+=360&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)&call :MOVE 1 2&set RY=!ORY!
		if !KEY! == 100 set ORY=!RY!&set /a RY+=360&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)&call :MOVE -1 2&set RY=!ORY!

		if !KEY! == 328 call :MOVE 1 1
		if !KEY! == 336 call :MOVE -1 1
		if !KEY! == 119 call :MOVE 1 1
		if !KEY! == 115 call :MOVE -1 1

		if !KEY! == 337 set /a TY-=30&set BOUNDSCHECK=0
		if !KEY! == 329 set /a TY+=30&set BOUNDSCHECK=0
		if !KEY! == 335 set /a TY+=10&set /a YMID-=12
		if !KEY! == 327 set /a TY-=10&set /a YMID+=12

		if !KEY! == 27 set STOP=1
	)
)
if not defined STOP goto LOOP
::cmdwiz gettime&set /A TLAPSE=(!errorlevel!-%ORGT%)/100&echo !TLAPSE! cs&pause&pause

rem del /Q %FN% %FN2% %FN4% wrld-temp?.obj
endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
del /Q %FN4% wrld-temp?.obj
goto :eof

:MAKEBKG
set /a GR_Y=H/2+3, GR_Y2=GR_Y+1, GR_YH=H-GR_Y2, SKY_H=H/2
set BKSTR="fbox 0 1 20 0,0,!W!,120 & fbox 9 1 b1 0,120,!W!,!SKY_H! & fbox 9 1 b1 0,105,!W!,10 & fbox 9 1 b1 0,90,!W!,5 & fbox 9 1 b1 0,75,!W!,2 & fbox 9 1 b1 0,60,!W!,1  & fbox 0 0 20 0,!GR_Y!,!W!,5 & fbox 0 2 20 0,!GR_Y2!,!W!,!GR_YH!"
goto :eof

:MOVE <direction> <div>
if !RY! lss 360 set /A AZ=-(360-!RY!)&set /A AX=360-(-!AZ!)
if !RY! geq 360 if !RY! lss 720 set /A AZ=360-(720-!RY!)&set /A AX=360-!AZ!
if !RY! geq 720 if !RY! lss 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-!AZ!)
if !RY! geq 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-(-!AZ!))

set /a TTZ=%TZ%, TTX=%TX%
set /A ZMOD=%MULVAL% & if !TTZ! lss 0 set /A ZMOD=-%MULVAL%
set /A XMOD=%MULVAL% & if !TTX! lss 0 set /A XMOD=-%MULVAL%
if %BOUNDSCHECK% == 1 for /L %%a in (1,1,2) do set /A TTZ+=%AZ%*%1/%2,TTX+=%AX%*%1/%2 & set /A XP=(!TTX!+%XMOD%)/(%MULVAL%*2)+%SLOTS%/2, ZP=(%YSLOTS%)/2-(!TTZ!+%ZMOD%)/(%MULVAL%*2) & if !ZP! geq 0 if !XP! geq 0 if !ZP! lss %YSLOTS% if !XP! lss %SLOTS% for %%x in (!XP!) do for %%z in (!ZP!) do set SS=!WRLD%%z! & set S=!SS:~%%x,1!& if not "!S!"=="-" if not "!S!"=="0" if not "!S!"=="o" goto :eof

set /a TZ+=%AZ%*%1/%2,TX+=%AX%*%1/%2
