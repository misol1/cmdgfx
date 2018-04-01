:: 3dworld with textures and moving "enemy" : Mikael Sollenborn 2016
@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 0
set /a W=320,H=110
mode %W%,%H%
mode con rate=0 delay=10000
for /F "Tokens=1 delims==" %%v in ('set') do if /I not %%v==PATH set "%%v="

set /a W=1280,H=680

cmdgfx.exe "text 8 0 0 Generating_world... 142,51"

set /a XMID=%W%/2, YMID=%H%/2-10
set /a DIST=0, DRAWMODE=5, GROUNDCOL=2, MULVAL=250, YMULVAL=125"
set ASPECT=1.00937
set /a RX=0, RY=720, RZ=0

::set CUBECOLS=0 4 b1 0 4 b1  0 4 b1  0 4 b1  0 4 b0 0 4 b0  0 1 b1 0 1 b1  0 1 b1  0 1 b1  0 1 b0 0 1 b0
set CUBECOLS=0 0 b2 0 0 b2  0 0 b1  0 0 b1  0 0 b0 0 0 b0
set GROUNDCOLS=0 0 b2  0 0 b0

set /A CNT=0, SLOTS=0
set FWORLD=3dworld2.dat
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

echo usemtl img\tile_door.pcx >%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo vt 1 0 >>%FN%

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
set CNT=1&for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,7) do set /a vx=!Vx%%b!&(if not "!sx%%a!"=="" set /a vx*=!sx%%a!)&set /a vx-=!dx%%a!&set /a vx*=%MULVAL% & set /a vy=!Vy%%b!&(if not "!sy%%a!"=="" if !vy! lss 0 set /a vy*=!sy%%a!)&set /a vy+=!dy%%a!&set /a vy*=%YMULVAL% & set /a vz=!Vz%%b!&(if not "!sz%%a!"=="" set /a vz*=!sz%%a!)&set /a vz+=!dz%%a!&set /a vz*=%MULVAL%&echo v !vx! !vy! !vz!>>%FN%&set /A CNT+=1
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if not !t%%a!==M if not !t%%a!==N set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN%
echo usemtl img\dos_shade4.pcx >>%FN%
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if !t%%a!==M set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN%
echo usemtl img\dos_shade2.pcx >>%FN%
for /L %%a in (0,1,%NOF_O%) do for /L %%b in (0,1,5) do if !t%%a!==N set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN%

for /L %%a in (0,1,7) do set Vx%%a=&set Vy%%a=&set Vz%%a=&set F%%a_0=&set F%%a_1=&set F%%a_2=&set F%%a_3=
for /L %%a in (0,1,%CNT%) do set sx%%a=&set sy%%a=&set sz%%a=&set dx%%a=&set dy%%a=&set dz%%a=&set t%%a=

echo usemtl img\tile_ground.pcx >%FN2%
echo vt 0 0 >>%FN2%
echo vt 0 1 >>%FN2%
echo vt 1 1 >>%FN2%
echo vt 1 0 >>%FN2%

set TILESIZE=1000
set /A CNT=1, CNT2=0
for /L %%a in (-20000,%TILESIZE%,20000) do for /L %%b in (-20000,%TILESIZE%,20000) do set /A V1=%%a,V2=%%a+%TILESIZE%,V3=%%b,V4=%%b+%TILESIZE% & echo v !V1! 500 !V3! >>%FN2% & echo v !V2! 500 !V3! >>%FN2% & echo v !V2! 500 !V4! >>%FN2% & echo v !V1! 500 !V4! >>%FN2%&set /A CNT2+=1
for /L %%a in (1,1,%CNT2%) do set /a f0=!CNT!&set /a f1=!CNT!+1&set /a f2=!CNT!+2&set /a f3=!CNT!+3 & echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN2% & set /A CNT+=4

set TILESIZE=&set vx=&set vy=&set vz=&set PLX=&set PLZ=&set CNT2=&for /L %%a in (0,1,4) do set f%%a=&set V%%a=

:SKIPGEN
set BKSTR="fbox 0 1 20 0,0,%W%,120 & fbox 9 1 b1 0,120,%W%,250 & fbox 9 1 b1 0,105,%W%,10 & fbox 9 1 b1 0,90,%W%,5 & fbox 9 1 b1 0,75,%W%,2 & fbox 9 1 b1 0,60,%W%,1    & fbox 0 0 20 0,343,%W%,5 & fbox 0 2 20 0,344,%W%,320"

set /A MAP=0,ZMOD=0,XMOD=0
set MAPTXT=image 3dworld2.dat e 0 0 - 1220,15

set STOP=
cmdwiz gettime&set ORGT=!errorlevel!
set FN3=wrld-temp.obj
set ENEMY=1

set /A "f0=%NOF_V%+1,f1=%NOF_V%+1+1,f2=%NOF_V%+1+2,f3=%NOF_V%+1+3"
set /A XP1=0,XP2=500,DELT=300, CNT=0, BOUNDSCHECK=1
copy /Y %FN% %FN3%>nul

:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,10) do if not defined STOP (
	if !MAP!==1 set /A "XP=(!TX!+!XMOD!)/(%MULVAL%*2)+%SLOTS%/2+1220, ZP=(%YSLOTS%)/2-(!TZ!+!ZMOD!)/(%MULVAL%*2)+15" & set MAPP=pixel c 0 db !XP!,!ZP!

	if !ENEMY! == 1 (
		copy /Y %FN% %FN3%>nul
		set /A "XP1+=!DELT!, XP2+=!DELT!"
		if !XP1! gtr 3500 set DELT=-300
		if !XP1! lss -5000 set DELT=300

		echo v 250 -100 !XP1! >>%FN3%
		echo v 750 -100 !XP1! >>%FN3%
		echo v 750 500 !XP1! >>%FN3%
		echo v 250 500 !XP1! >>%FN3%

		set /A "CNT+=1,FRM=(!CNT!/8) %% 2"
		echo usemtl img\ugly!FRM!.pcx e >>%FN3%
		echo f !f0!/1/ !f1!/4/ !f2!/3/ !f3!/2/>>%FN3%
		echo f !f0!/1/ !f3!/2/ !f2!/3/ !f1!/4/>>%FN3%
	)
	
	cmdgfx_gdi "!BKSTR:~1,-1! & 3d %FN2% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,-200,0,300 %XMID%,!YMID!,%DIST%,!ASPECT! %GROUNDCOLS% & 3d %FN3% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,-200,0,300 %XMID%,!YMID!,%DIST%,%ASPECT% !CUBECOLS! & !MAPT! & !MAPP!" M0ufa:0,0,%W%,%H%Z800
	
	set RET=!errorlevel!
   if not !RET! == -1 (
		set /a "ME=!RET! & 1,ML=(!RET!&2)>>1, MR=(!RET!&4)>>2, MWD=MT=(!RET!&8)>>3, MWU=(!RET!&16)>>4, MX=(!RET!>>5)&511, MY=(!RET!>>14)&127"
		if not "!OLDMX!"=="" if !ME!==1 if !ML!==0 if !MWD!==0 if !MWU!==0 set /a "RY+=(!OLDMX!-!MX!),TY-=(!OLDMY!-!MY!),YMID+=(!OLDMY!-!MY!)"&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !MWD!==1 set /A RY+=720&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !MWU!==1 set /A RY+=720&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !ME!==1 if !MWD!==0 if !MWU!==0 set /a OLDMX=!MX!,OLDMY=!MY!
		set /a "NKEY=!RET!>>22, NKD=(!RET!>>21) & 1"
		if not !NKEY!==0 (
			if !NKD!==0 (
			   set KEY=!NKEY!
				if !KEY! == 109 set MAPP=&set /A MAP=1-!MAP!&(if !MAP!==0 set MAPT=)&(if !MAP!==1 set MAPT=%MAPTXT%)

				if !KEY! == 112 cmdwiz getch

				if !KEY! == 101 set /A ENEMY=1-!ENEMY! & copy /Y %FN% %FN3%>nul 

				if !KEY! == 32 set /a YMID=%H%/2-4 & set TY=0&set BOUNDSCHECK=1
				rem if !KEY! == 13 set /a DRAWTMP=!DRAWMODE! & (if !DRAWTMP! == 0 set DRAWMODE=5) & (if !DRAWTMP! == 5 set DRAWMODE=0)
				if !KEY! == 27 set STOP=1
				set KEY=0
			)
			if !NKD!==1 set KEY=!NKEY!
		)
	)

	if not !KEY! == 0 (
		if !KEY! == 331 set /A RY+=16&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !KEY! == 333 set /A RY-=16&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !KEY! == 106 set /A RY+=16&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !KEY! == 107 set /A RY-=16&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
		if !KEY! == 97 set ORY=!RY!&set /A RY+=360&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)&call :MOVE 1 2&set RY=!ORY!
		if !KEY! == 100 set ORY=!RY!&set /A RY+=360&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)&call :MOVE -1 2&set RY=!ORY!

		if !KEY! == 328 call :MOVE 1 1
		if !KEY! == 336 call :MOVE -1 1
		if !KEY! == 119 call :MOVE 1 1
		if !KEY! == 115 call :MOVE -1 1

		if !KEY! == 337 set /A TY-=30&set BOUNDSCHECK=0
		if !KEY! == 329 set /A TY+=30&set BOUNDSCHECK=0

		if !KEY! == 335 set /A TY+=10&set /A YMID-=12
		if !KEY! == 327 set /A TY-=10&set /A YMID+=12		
	)
)
if not defined STOP goto LOOP
::cmdwiz gettime&set /A TLAPSE=(!errorlevel!-%ORGT%)/100&echo !TLAPSE! cs&pause&pause

del /Q %FN3%
endlocal
mode 80,50
mode con rate=31 delay=0
cls
cmdwiz setfont 6
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
