@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 1 & cmdwiz showcursor 0
set /a W=160, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a OFFXMID=270
set /a XMID=%W%/2, YMID=%H%/2, DIST=4000, DRAWMODE=1, NOFCUBES=5, COLCNT=0, COLNOF=3
for /L %%a in (1,1,%NOFCUBES%) do set /a CRX%%a=0,CRY%%a=0,CRZ%%a=0
set CNT=1 & for %%a in (3,3,3,3,3) do set /a CRXA!CNT!=%%a, CNT+=1
set CNT=1 & for %%a in (-4,-4,-4,-4,-4) do set /a CRYA!CNT!=%%a, CNT+=1
set CNT=1 & for %%a in (5,5,5,5,5) do set /a CRZA!CNT!=%%a, CNT+=1
set ASPECT=0.7
set COLS1=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COLS2=4 0 db 4 0 db  5 0 db 5 0 db  6 0 db 6 0 db
set COLS3=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COLS4=7 0 db 7 0 db  1 0 db 1 0 db  9 0 db 9 0 db
set COLS5=1 0 db 1 0 db  2 0 db 2 0 db  3 0 db 3 0 db
set COL0=00000f,080820,101030,181840,202050,282860,303070,383880,404090,405090,515995,282870,101030,181840,202050,282860,303070  000820
set COL1=00000f,080820,101030,181834,203050,283858,303070,503880,604090,705090,717995,686870,102040,183840,203050,282860,103070  000820
set /a XP=190, RW=350, CNT=0

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COLCNT!) do (
	start "" /B /High cmdgfx_gdi "fbox 0 0 db 0,0,%RW%,%H% & 3d objects\cube.ply 4,0 !CRX1!,!CRY1!,!CRZ1! 0,0,0 -790,-790,-790,0,0,0 1,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% %COLS5% & fbox 0 0 db 160,0,320,%H% & 3d objects\cube.ply 4,0 !CRX2!,!CRY2!,!CRZ2! 0,0,0 -480,-480,-480,0,0,0 1,0,0,10 %OFFXMID%,%YMID%,!DIST!,%ASPECT% %COLS4% & block 0 0,0,%RW%,80 0,0 -1 0 0 - xor(col(x,y),col(x+%XP%,y)) & fbox 0 0 db 160,0,320,%H% & 3d objects\cube.ply 4,0 !CRX3!,!CRY3!,!CRZ3! 0,0,0 -270,-270,-270,0,0,0 1,0,0,10 %OFFXMID%,%YMID%,!DIST!,%ASPECT% %COLS3% & block 0 20,0,310,80 20,0 -1 0 0 - xor(col(x,y),col(x+%XP%,y)) & fbox 0 0 db 160,0,320,%H% & 3d objects\cube.ply 4,0 !CRX4!,!CRY4!,!CRZ4! 0,0,0 -160,-160,-160,0,0,0 1,0,0,10 %OFFXMID%,%YMID%,!DIST!,%ASPECT% %COLS2% & block 0 40,10,270,60 40,10 -1 0 0 - xor(col(x,y),col(x+%XP%,y)) & fbox 0 0 db 160,0,320,%H% & 3d objects\cube.ply 4,0 !CRX5!,!CRY5!,!CRZ5! 0,0,0 -60,-60,-60,0,0,0 1,0,0,10 %OFFXMID%,%YMID%,!DIST!,%ASPECT% %COLS1% & block 0 50,30,240,20 50,30 -1 0 0 - xor(col(x,y),col(x+%XP%,y)) " f1:0,0,%RW%,80,160,80 !COL%%c!

	cmdgfx "" nkW9
	set KEY=!ERRORLEVEL!
	
	for /L %%a in (1,1,%NOFCUBES%) do set /a CRX%%a+=!CRXA%%a!,CRY%%a+=!CRYA%%a!,CRZ%%a+=!CRZA%%a!
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 100 set /A DIST+=100
	if !KEY! == 68 set /A DIST-=100
	if !KEY! == 27 set STOP=1
	if !KEY! == 32 set /a COLCNT+=1&if !COLCNT! geq !COLNOF! set /a COLCNT=0
	set /a CNT+=1 & if !CNT! gtr 300 set /a "CNT=0, RND=!RANDOM! %% %NOFCUBES%, V=(!RANDOM! %% 2)*2-1, XYZ=!RANDOM! %% 3" & for %%a in (!RND!) do (if !XYZ!==0 set /a CRXA%%a+=!V!) & (if !XYZ!==1 set /a CRYA%%a+=!V!) & (if !XYZ!==2 set /a CRZA%%a+=!V!) 
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & cmdwiz showcursor 1
mode 80,50
