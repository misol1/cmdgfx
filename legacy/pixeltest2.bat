@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cmdwiz showcursor 0
set /a W=160, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W if /I not %%v==PATH set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=1
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=0.75
set COLS_0=f 0 04   f 0 04   f 0 .  7	 0 .   7 0 .   8 0 .  8 0 .  8 0 .  8 0 .   8 0 .   8 0 .  8 0 fa
set COLS_1=f 0 04   f 0 04   b 0 .  9	 0 .   9 0 .   9 0 .  1 0 .  1 0 .  1 0 .   1 0 .   1 0 fa
set /a COLCNT=0, OBJCNT=0
set HELP=text 9 0 0 S\nP\nA\nC\nE\n\n\80t\no\n\ns\nw\ni\nt\nc\nh\n\no\nb\nj\ne\nc\nt\n 157,56
set OBJ0=torus&set OBJ1=sphere&set OBJ2=double-sphere

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do for %%o in (!OBJCNT!) do (
	start "" /B /high cmdgfx_gdi "fbox 7 0 20 0,0,%W%,%H% & 3d objects\plot-!OBJ%%o!.ply %DRAWMODE%,1 !CRX!,!CRY!,!CRZ! 0,0,0 1.2,1.2,1.2,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% !COLS_%%c! & %HELP% " f1
	cmdgfx "" nkW12
	set KEY=!ERRORLEVEL!
	
	set /A CRZ+=5,CRX+=3,CRY-=4
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 13 set /A COLCNT+=1&if !COLCNT! gtr 1 set COLCNT=0
	if !KEY! == 32 set /A OBJCNT+=1&if !OBJCNT! gtr 2 set OBJCNT=0
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1
mode 80,50
