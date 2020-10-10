:: 3dworld with textures : Mikael Sollenborn 2016
@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cls & cmdwiz setfont 0
set /a W=180, H=110
mode %W%,%H%
mode con rate=31 delay=0
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

cmdgfx.exe "text 8 0 0 Generating_world...\n\n\n___(H_for_help) 82,50"

set /a XMID=%W%/2, YMID=%H%/2-4
set /a DIST=0, DRAWMODE=5, GROUNDCOL=2, MULVAL=250, YMULVAL=125"
set ASPECT=0.69259
set /a RX=0, RY=720, RZ=0

set CUBECOLS=0 4 b1 0 4 b1  0 4 b1  0 4 b1  0 4 b0 0 4 b0  0 1 b1 0 1 b1  0 1 b1  0 1 b1  0 1 b0 0 1 b0
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
set BKSTR="fbox 0 1 b1 0,0,%W%,30 & fbox 0 1 20 0,30,%W%,10 & fbox 9 1 b1 0,40,%W%,6 & fbox 9 1 db 0,46,%W%,4  &  fbox 0 0 20 0,51,%W%,5 & fbox 0 %GROUNDCOL% b2 0,53,%W%,5 & fbox 0 %GROUNDCOL% b1 0,57,%W%,10 & fbox 0 %GROUNDCOL% b0 0,64,%W%,22 & fbox 8 %GROUNDCOL% 20 0,80,%W%,100 "

set /A MAP=0,ZMOD=0,XMOD=0
set MAPTXT=image data/3dworld2.dat e 0 0 - 146,2

set HELPT=box c 0 fe 28,106,126,2^& text 7 0 0 \e0_LEFT/RIGHT\r_ROTATE___\e0UP/DOWN\r_MOVE___\e0PGUP/PGDWN\r_RISE/SINK___\e0HOME/END\r_LOOK_UP/DOWN___\e0SPACE_\rRESET_Y___\e0M\r_MAP___\e0H\r_HELP___\e0ESC\r_QUIT_ 29,107
set HELP=&set /a HLP=0

set RENDERER=_gdi&set REND=0
set STOP=
cmdwiz gettime&set ORGT=!errorlevel!

:LOOP
for /L %%1 in (1,1,30) do if not defined STOP for /L %%2 in (1,1,10) do if not defined STOP (
	if !MAP!==1 set /A "XP=(!TX!+!XMOD!)/(%MULVAL%*2)+%SLOTS%/2+146, ZP=(%YSLOTS%)/2-(!TZ!+!ZMOD!)/(%MULVAL%*2)+2" & set MAPP=pixel c 0 db !XP!,!ZP!

	cmdgfx!RENDERER! "%BKSTR:~1,-1% & 3d %FN2% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,300,0,300 %XMID%,!YMID!,%DIST%,%ASPECT% %GROUNDCOLS% & 3d %FN% !DRAWMODE!,-1 !RX!,!RY!,!RZ! 0,0,0 1,1,1,!TX!,!TY!,!TZ! 1,300,0,300 %XMID%,!YMID!,%DIST%,%ASPECT% !CUBECOLS! & !MAPT! & !MAPP! & !HELP!" kf0Z300
	set KEY=!ERRORLEVEL!

	if !KEY! == 331 set /A RY+=8&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)
	if !KEY! == 333 set /A RY-=8&(if !RY! gtr 1440 set /A RY=!RY!-1440)&(if !RY! lss 0 set /A RY=1440+!RY!)

	if !KEY! == 328 call :MOVE 1
	if !KEY! == 336 call :MOVE -1

	if !KEY! == 337 set /A TY-=30
	if !KEY! == 329 set /A TY+=30

	if !KEY! == 109 set MAPP=&set /A MAP=1-!MAP!&(if !MAP!==0 set MAPT=)&(if !MAP!==1 set MAPT=%MAPTXT%)

	if !KEY! == 335 set /A TY+=30&set /A YMID-=12
	if !KEY! == 327 set /A TY-=30&set /A YMID+=12

	if !KEY! == 104 set /A HLP=1-!HLP! & (if !HLP!==1 set HELP=!HELPT!)&(if !HLP!==0 set HELP=)

	if !KEY! == 114 set /A REND=1-!REND! & (if !REND!==0 set RENDERER=_gdi)&(if !REND!==1 set RENDERER=)
				
	if !KEY! == 13 set /a DRAWTMP=!DRAWMODE! & (if !DRAWTMP! == 0 set DRAWMODE=5) & (if !DRAWTMP! == 5 set DRAWMODE=0)
				
	if !KEY! == 32 set /a YMID=%H%/2-4 & set TY=0
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP
::cmdwiz gettime&set /A TLAPSE=(!errorlevel!-%ORGT%)/100&echo !TLAPSE! cs&pause&pause

::if !KEY! == 97 set /A RX+=2
::if !KEY! == 122 set /A RX-=2

endlocal
mode 80,50
cls
cmdwiz setfont 6
goto :eof

:MOVE <direction>
if !RY! lss 360 set /A AZ=-(360-!RY!)&set /A AX=360-(-!AZ!)
if !RY! geq 360 if !RY! lss 720 set /A AZ=360-(720-!RY!)&set /A AX=360-!AZ!
if !RY! geq 720 if !RY! lss 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-!AZ!)
if !RY! geq 1080 set /A AZ=360-(!RY!-720)&set /A AX=-(360-(-!AZ!))

set TTZ=%TZ%
set TTX=%TX%
set /A ZMOD=%MULVAL% & if !TTZ! lss 0 set /A ZMOD=-%MULVAL%
set /A XMOD=%MULVAL% & if !TTX! lss 0 set /A XMOD=-%MULVAL%
if %TY% == 0 for /L %%a in (1,1,4) do set /A TTZ+=%AZ%*%1,TTX+=%AX%*%1 & set /A XP=(!TTX!+%XMOD%)/(%MULVAL%*2)+%SLOTS%/2, ZP=(%YSLOTS%)/2-(!TTZ!+%ZMOD%)/(%MULVAL%*2) & if !ZP! geq 0 if !XP! geq 0 if !ZP! lss %YSLOTS% if !XP! lss %SLOTS% for %%x in (!XP!) do for %%z in (!ZP!) do set SS=!WRLD%%z! & set S=!SS:~%%x,1!& if not "!S!"=="-" if not "!S!"=="0" if not "!S!"=="o" goto :eof
::gotoxy 1 1 "!S!\K" 9 0 & 

::gotoxy 0 0&for /L %%a in (1,1,6) do set /A TTZ+=%AZ%*%1,TTX+=%AX%*%1 & set /A XP=(!TTX!+%XMOD%)/(%MULVAL%*2)+%SLOTS%/2 & set /A ZP=%YSLOTS%/2-(!TTZ!+!ZMOD!)/(%MULVAL%*2) & for %%x in (!XP!) do for %%z in (!ZP!) do set SS=!WRLD%%z! & set S=!SS:~%%x,1! & set /A XPP=!XP!+1,ZPP=!ZP!+1&gotoxy k k " !XPP! !ZPP! !S! \n" f 0 c
::cmdwiz getch

set /A TZ+=%AZ%*%1
set /A TX+=%AX%*%1
