:: 3dworld maze with with perspective correct texture mapping : Mikael Sollenborn 2016
@echo off
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 0
set /a W=180, H=80
mode con lines=%H% cols=%W%
mode con rate=0 delay=10000
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==W if not %%v==H set "%%v="

set /a W*=4, H*=6
cmdwiz getdisplaydim w & set SW=!errorlevel!
cmdwiz getdisplaydim h & set SH=!errorlevel!
set /a SW=%SW%/2, SH=%SH%/2
set /a WPX=%SW%-%W%/2, WPY=%SH%-%H%/2-20
cmdwiz setwindowpos %WPX% %WPY%
cmdgfx.exe "text 8 0 0 Generating_world... 82,36"

set /a XMID=%W%/2, YMID=%H%/2-10, RX=0, RY=720, RZ=0
set /a DIST=0, DRAWMODE=5, GROUNDCOL=2, MULVAL=800, YMULVAL=125"
set ASPECT=1.9

set CUBECOLS=0 0 b2 0 0 b2  0 0 b1  0 0 b1  0 0 b0 0 0 b0
set GROUNDCOLS=0 0 b2  0 0 b0

set /a CNT=0, SLOTS=0
set FWORLD=3dworld-maze.dat
if not "%~1" == "" if exist %1 set FWORLD=%1
for /F "tokens=*" %%i in (%FWORLD%) do (if !SLOTS!==0 cmdwiz stringlen "%%i"&set SLOTS=!ERRORLEVEL!)& set WRLD!CNT!=%%i&set /a CNT+=1
set /a YSLOTS=%CNT%

set FN=3dworld-maze.obj
set FN2=3dworld-ground-maze.obj

set /a PLX=%SLOTS%/2, PLZ=%YSLOTS%/2
set /a XC=-%SLOTS%, SLOTM=%SLOTS%-1
set /a YC=-%YSLOTS%, YSLOTM=%YSLOTS%-1
set /a CNT=0 & for /l %%i in (0,1,%YSLOTM%) do set SS=!WRLD%%i!& for /l %%j in (0,1,%SLOTM%) do set S=!SS:~%%j,1!&if not "!S!"=="-" for %%a in (!CNT!) do set t%%a=!S!&set sx%%a=1&set sz%%a=1&set sy%%a=!S!&set /a dx%%a = %XC%+%%j*2 & set /a dy%%a=3 & set /a dz%%a = %YC%+%%i*2 & set /a CNT+=1&(if "!S!"=="o" set /a CNT-=1&set /a PLX=%%j*2&set /a PLZ=%%i*2)&(if "!S!"=="M" set /a sy%%a=6)

set /a "TX=(%XC%+%PLX%)*%MULVAL%, TY=0, TZ=(%YC%+%PLZ%)*-%MULVAL%"

if exist %FN% if exist %FN2% goto SKIPGEN

set /a NOF_OBJECTS=%CNT%, NOF_V=%CNT%*8, NOF_F=%CNT%*6

echo usemtl img\wall.pcx >%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo vt 1 0 >>%FN%

set /a Vx0=-1, Vy0=-1, Vz0=-1
set /a Vx1=1,  Vy1=-1, Vz1=-1
set /a Vx2=1,  Vy2=1,  Vz2=-1
set /a Vx3=-1, Vy3=1,  Vz3=-1
set /a Vx4=-1, Vy4=-1, Vz4=1
set /a Vx5=1,  Vy5=-1, Vz5=1
set /a Vx6=1,  Vy6=1,  Vz6=1
set /a Vx7=-1, Vy7=1,  Vz7=1

set /a F0_0=0, F0_1=3, F0_2=2, F0_3=1
set /a F1_0=5, F1_1=6, F1_2=7, F1_3=4
set /a F2_0=6, F2_1=5, F2_2=1, F2_3=2
set /a F3_0=3, F3_1=0, F3_2=4, F3_3=7
set /a F4_0=7, F4_1=6, F4_2=2, F4_3=3
set /a F5_0=5, F5_1=4, F5_2=0, F5_3=1

set /a NOF_O=%NOF_OBJECTS%-1
set CNT=1&for /l %%a in (0,1,%NOF_O%) do for /l %%b in (0,1,7) do set /a vx=!Vx%%b!&(if not "!sx%%a!"=="" set /a vx*=!sx%%a!)&set /a vx-=!dx%%a!&set /a vx*=%MULVAL% & set /a vy=!Vy%%b!&(if not "!sy%%a!"=="" if !vy! lss 0 set /a vy*=!sy%%a!)&set /a vy+=!dy%%a!&set /a vy*=%YMULVAL% & set /a vz=!Vz%%b!&(if not "!sz%%a!"=="" set /a vz*=!sz%%a!)&set /a vz+=!dz%%a!&set /a vz*=%MULVAL%&echo v !vx! !vy! !vz!>>%FN%&set /a CNT+=1
for /l %%a in (0,1,%NOF_O%) do for /l %%b in (0,1,5) do if not !t%%a!==M if not !t%%a!==N set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN%
echo usemtl img\dos_shade4.pcx >>%FN%
for /l %%a in (0,1,%NOF_O%) do for /l %%b in (0,1,5) do if !t%%a!==M set /a f0=!F%%b_0!+%%a*8+1&set /a f1=!F%%b_1!+%%a*8+1&set /a f2=!F%%b_2!+%%a*8+1&set /a f3=!F%%b_3!+%%a*8+1&echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN%

for /l %%a in (0,1,7) do set Vx%%a=&set Vy%%a=&set Vz%%a=&set F%%a_0=&set F%%a_1=&set F%%a_2=&set F%%a_3=
for /l %%a in (0,1,%CNT%) do set sx%%a=&set sy%%a=&set sz%%a=&set dx%%a=&set dy%%a=&set dz%%a=&set t%%a=

echo usemtl img\grass_tile.pcx >%FN2%
echo vt 0 0 >>%FN2%
echo vt 0 1 >>%FN2%
echo vt 1 1 >>%FN2%
echo vt 1 0 >>%FN2%

set /a TILESIZE=2000, CNT=1, CNT2=0
for /l %%a in (-25000,%TILESIZE%,25000) do for /l %%b in (-25000,%TILESIZE%,25000) do set /a V1=%%a,V2=%%a+%TILESIZE%,V3=%%b,V4=%%b+%TILESIZE% & echo v !V1! 500 !V3! >>%FN2% & echo v !V2! 500 !V3! >>%FN2% & echo v !V2! 500 !V4! >>%FN2% & echo v !V1! 500 !V4! >>%FN2%&set /a CNT2+=1
for /l %%a in (1,1,%CNT2%) do set /a f0=!CNT!, f1=!CNT!+1, f2=!CNT!+2, f3=!CNT!+3, CNT+=4 & echo f !f0!/1/ !f1!/2/ !f2!/3/ !f3!/4/ >>%FN2% 

set TILESIZE=&set vx=&set vy=&set vz=&set PLX=&set PLZ=&set CNT2=&for /l %%a in (0,1,4) do set f%%a=&set V%%a=

:SKIPGEN
for /l %%a in (0,1,7) do set Vx%%a=&set Vy%%a=&set Vz%%a=&set F%%a_0=&set F%%a_1=&set F%%a_2=&set F%%a_3=
for /l %%a in (0,1,%CNT%) do set sx%%a=&set sy%%a=&set sz%%a=&set dx%%a=&set dy%%a=&set dz%%a=&set t%%a=

set BKSTR="fbox 9 1 b1 0,0,%W%,800"
set /a MAP=0,ZMOD=0,XMOD=0
set MAPTXT=image 3dworld-maze.dat 5 0 0 - 680,5

set /a "f0=%NOF_V%+1,f1=%NOF_V%+1+1,f2=%NOF_V%+1+2,f3=%NOF_V%+1+3"
set /a XP1=0,XP2=500,DELT=300, CNT=0, BOUNDSCHECK=1

cmdwiz setwindowpos %WPX% %WPY%
set /a MPY=%SH%-%H%/3 & cmdwiz setmousecursorpos %SW% !MPY!
cmdwiz gettime & set ORGT=!errorlevel!

:LOOP
for /l %%1 in (1,1,300) do if not defined STOP (
	if !MAP!==1 set /a "XP=(!TX!+!XMOD!)/(%MULVAL%*2)+%SLOTS%/2+680, ZP=(%YSLOTS%)/2-(!TZ!+!ZMOD!)/(%MULVAL%*2)+5" & set MAPP=pixel f 0 db !XP!,!ZP!

	cmdgfx_gdi "!BKSTR:~1,-1! & 3d %FN2% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,1,25000,300 %XMID%,!YMID!,%DIST%,!ASPECT! %GROUNDCOLS% & 3d %FN% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,-100,25000,100 %XMID%,!YMID!,%DIST%,%ASPECT% !CUBECOLS! & !MAPT! & !MAPP!" M0fa:0,0,%W%,%H%Z600
	
	set RET=!errorlevel!
   if not !RET! == -1 (
		set /a "ME=!RET! & 1,ML=(!RET!&2)>>1, MR=(!RET!&4)>>2, MWD=MT=(!RET!&8)>>3, MWU=(!RET!&16)>>4, MX=(!RET!>>5)&511, MY=(!RET!>>14)&127"
		if not "!OLDMX!"=="" if !ME!==1 if !ML!==0 if !MWD!==0 if !MWU!==0 set /a "RY+=(!OLDMX!-!MX!)*2,TY-=(!OLDMY!-!MY!)*2,YMID+=(!OLDMY!-!MY!)*2"&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !MWD!==1 set /a RY+=720&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !MWU!==1 set /a RY+=720&(if !RY! gtr 1440 set /a RY=!RY!-1440)&(if !RY! lss 0 set /a RY=1440+!RY!)
		if !ME!==1 if !MWD!==0 if !MWU!==0 set /a OLDMX=!MX!,OLDMY=!MY!
		set /a "NKEY=!RET!>>22, NKD=(!RET!>>21) & 1"
		if not !NKEY!==0 (
			if !NKD!==0 (
			   set KEY=!NKEY!
				if !KEY! == 109 set MAPP=&set /a MAP=1-!MAP!&(if !MAP!==0 set MAPT=)&(if !MAP!==1 set MAPT=%MAPTXT%)
				if !KEY! == 112 cmdwiz getch
				if !KEY! == 32 set /a YMID=%H%/2-4 & set TY=0&set BOUNDSCHECK=1
				if !KEY! == 13 set /a DRAWTMP=!DRAWMODE! & (if !DRAWTMP! == 0 set DRAWMODE=5) & (if !DRAWTMP! == 5 set DRAWMODE=0)
				if !KEY! == 27 set STOP=1
				set KEY=0
			)
			if !NKD!==1 set KEY=!NKEY!
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
	)
)
if not defined STOP goto LOOP
::cmdwiz gettime&set /a TLAPSE=(!errorlevel!-%ORGT%)/100&echo !TLAPSE! cs&pause&pause

::del /q %FN% %FN2%
endlocal
mode con cols=80 lines=50
mode con rate=31 delay=0
cls & cmdwiz setfont 6
goto :eof

:MOVE <direction> <div>
if !RY! lss 360 set /a AZ=-(360-!RY!)&set /a AX=360-(-!AZ!)
if !RY! geq 360 if !RY! lss 720 set /a AZ=360-(720-!RY!)&set /a AX=360-!AZ!
if !RY! geq 720 if !RY! lss 1080 set /a AZ=360-(!RY!-720)&set /a AX=-(360-!AZ!)
if !RY! geq 1080 set /a AZ=360-(!RY!-720)&set /a AX=-(360-(-!AZ!))

set /a TTZ=%TZ%, TTX=%TX%
set /a ZMOD=%MULVAL% & if !TTZ! lss 0 set /a ZMOD=-%MULVAL%
set /a XMOD=%MULVAL% & if !TTX! lss 0 set /a XMOD=-%MULVAL%
if %BOUNDSCHECK% == 1 for /l %%a in (1,1,3) do set /a TTZ+=%AZ%*%1/%2,TTX+=%AX%*%1/%2 & set /a XP=(!TTX!+%XMOD%)/(%MULVAL%*2)+%SLOTS%/2, ZP=(%YSLOTS%)/2-(!TTZ!+%ZMOD%)/(%MULVAL%*2) & if !ZP! geq 0 if !XP! geq 0 if !ZP! lss %YSLOTS% if !XP! lss %SLOTS% for %%x in (!XP!) do for %%z in (!ZP!) do set SS=!WRLD%%z! & set S=!SS:~%%x,1!& if not "!S!"=="-" if not "!S!"=="0" if not "!S!"=="o" goto :eof

set /a TZ+=%AZ%*%1/%2,TX+=%AX%*%1/%2
