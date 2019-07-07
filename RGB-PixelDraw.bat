<# :
@echo off
cd /D "%~dp0"
if defined __ goto :START

pixelfnt.exe 1 & cls
cmdwiz showmousecursor 0 & cmdwiz fullscreen 1
if %ERRORLEVEL% lss 0 set TOP=U
cmdwiz showcursor 0
cmdwiz getconsoledim sw
set /a W=%errorlevel%
cmdwiz getconsoledim sh
set /a H=%errorlevel%, HH=H*2
set __=.
cmdgfx_input.exe mW8x | call %0 %* | cmdgfx_RGB "fbox 0 0 db" %TOP%eSfa:0,0,%W%,%HH%,%W%,%H%v
set __=
cls
cmdwiz fullscreen 0 & cmdwiz setfont 6 & cmdwiz showcursor 1 & mode 80,50
set TOP=
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="H" if not "%%v"=="HH" if /I not "%%v"=="PATH" if /I not "%%v"=="SystemRoot" set "%%v="
::preserve SystemRoot for file dialog to work
 
set /a BORD=60, DH=H+340, DG=H-100, WB=W-BORD*2, WBB=WB+1, GUI_H=50, GUI_HB=GUI_H+1

:: a circle shape
set /a "MX0=0,MY0=2000, MX1=539,MY1=1925, MX2=1039,MY2=1708, MX3=1461,MY3=1365, MX4=1775,MY4=920, MX5=1958,MY5=406, MX6=1995,MY6=-136, MX7=1884,MY7=-669, MX8=1633,MY8=-1153, MX9=1262,MY9=-1551, MX10=796,MY10=-1834, MX11=272,MY11=-1981, MX12=-272,MY12=-1981, MX13=-796,MY13=-1834, MX14=-1262,MY14=-1551, MX15=-1633,MY15=-1153, MX16=-1884,MY16=-669, MX17=-1995,MY17=-136, MX18=-1958,MY18=406, MX19=-1775,MY19=920, MX20=-1461,MY20=1365, MX21=-1039,MY21=1708, MX22=-539,MY22=1925"

:: a box shape
set /a "BMX0=-1600,BMY0=-1600, BMX1=1600,BMY1=-1600, BMX2=1600,BMY2=1600, BMX3=-1600,BMY3=1600"

set /a CO0=48, CR0=255, CG0=34, CB0=153, SIZE0=24, SHAPE=0
call :MAKECOL 0
call :MAKEPOLYSTR 0
set /a CO1=60, CR1=0, CG1=0, CB1=0, SIZE1=36
call :MAKECOL 1
call :MAKEPOLYSTR 1

set DRAW=""
set GUI=
set /a FGUI=1 & if !FGUI!==0 set GUI=rem
set /a GUI_UPD=1, SELCOL=0, MOUSE_D=0, INGUI=0, COLPICK=0, IGNORE_M=0

set REMOVEGUI=block 0 !BORD!,!DH!,!WBB!,!GUI_HB! !BORD!,!DG!
set SAVEFORGUI=block 0 !BORD!,!DG!,!WBB!,!GUI_HB! !BORD!,!DH!

if not "%~1"=="" echo "cmdgfx: image %~1 0 0 db -1 0,0 0 0 !W!,!H! & !SAVEFORGUI!"

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	if !GUI_UPD!==1 call :MAKEGUI & set /a GUI_UPD=0
	echo "cmdgfx: !REMOVEGUI! & !DRAW:~1,-1! & !SAVEFORGUI! & !GUI! !GENGUI:~1,-1!"
	
	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L 2>nul ) 
	
	set DRAW=""
	if not "!EV_BASE:~0,1!" == "N" (
		if !M_EVENT!==1 (
			if !M_WHEEL! == 1 for %%c in (!SELCOL!) do set /a SIZE%%c-=1,GUI_UPD=1&(if !SIZE%%c! lss 1 set SIZE%%c=1) & call :MAKEPOLYSTR !SELCOL!
			if !M_WHEEL! == -1 for %%c in (!SELCOL!) do set /a SIZE%%c+=1,GUI_UPD=1&(if !SIZE%%c! gtr 60 set SIZE%%c=60) & call :MAKEPOLYSTR !SELCOL!
			set /a SIZEI=0&if !M_RB!==1 set /a SIZEI=1
			for %%c in (!SIZEI!) do set OUTP=!OUTP!!M_X!,!M_Y!,!POLYSTR%%c!
			if !IGNORE_M! leq 0 if !M_LB! == 1 (if !MOUSE_D!==0 set /a MOUSE_D=1,TSTX=BORD+WB, TSTY=DG+GUI_H & if !M_X! gtr !BORD! if !M_Y! gtr !DG! if !M_Y! lss !TSTY! if !M_X! lss !TSTX! if !FGUI!== 1 set /a INGUI=1) & (if !INGUI!==0 (if !COLPICK!==0 set DRAW="ipoly !CURRCOL0! 0 db 20 !OUTP:~0,-1!") & (if !COLPICK!==1 call :COLPICK !M_X! !M_Y!) ) & if !INGUI!==1 call :PROCESS_GUI
			if !M_LB! == 0 set /a INGUI=0, MOUSE_D=0
			if !M_RB! == 1 set DRAW="ipoly !CURRCOL1! 0 db 20 !OUTP:~0,-1!"& set /a MOUSE_D=0
			set OUTP=
		)
	)
	set /a IGNORE_M-=1
	
	if !KEY! neq 0 (
		if !KEY! == 328 for %%c in (!SELCOL!) do set /a SIZE%%c+=1,GUI_UPD=1 &(if !SIZE%%c! gtr 60 set SIZE%%c=60) & call :MAKEPOLYSTR !SELCOL!
		if !KEY! == 336 for %%c in (!SELCOL!) do set /a SIZE%%c-=1,GUI_UPD=1 &(if !SIZE%%c! lss 1 set SIZE%%c=1) & call :MAKEPOLYSTR !SELCOL!
		if !KEY! == 32 set GUI=& set /a FGUI=1-FGUI & if !FGUI!==0 set GUI=rem
		if !KEY! == 27 set STOP=1

		if !KEY! == 329 set /a GUI_UPD=1, SHAPE+=1 &(if !SHAPE! gtr 5 set /a SHAPE=0) & call :MAKEPOLYSTR 0 & call :MAKEPOLYSTR 1
		if !KEY! == 337 set /a GUI_UPD=1, SHAPE-=1 &(if !SHAPE! lss 0 set /a SHAPE=5) & call :MAKEPOLYSTR 0 & call :MAKEPOLYSTR 1
		
		if !KEY! == 114 set /a "GUI_UPD=1, CR!SELCOL!+=2" & (for %%c in (!SELCOL!) do if !CR%%c! gtr 255 set /a CR!SELCOL!=255) & call :MAKECOL !SELCOL!
		if !KEY! == 82  set /a "GUI_UPD=1, CR!SELCOL!-=2" & (for %%c in (!SELCOL!) do if !CR%%c! lss 0 set /a CR!SELCOL!=0) & call :MAKECOL !SELCOL!
		if !KEY! == 103 set /a "GUI_UPD=1, CG!SELCOL!+=2" & (for %%c in (!SELCOL!) do if !CG%%c! gtr 255 set /a CG!SELCOL!=255) & call :MAKECOL !SELCOL!
		if !KEY! == 71  set /a "GUI_UPD=1, CG!SELCOL!-=2" & (for %%c in (!SELCOL!) do if !CG%%c! lss 0 set /a CG!SELCOL!=0) & call :MAKECOL !SELCOL!
		if !KEY! == 98 set /a "GUI_UPD=1, CB!SELCOL!+=2" & (for %%c in (!SELCOL!) do if !CB%%c! gtr 255 set /a CB!SELCOL!=255) & call :MAKECOL !SELCOL!
		if !KEY! == 66  set /a "GUI_UPD=1, CB!SELCOL!-=2" & (for %%c in (!SELCOL!) do if !CB%%c! lss 0 set /a CB!SELCOL!=0) & call :MAKECOL !SELCOL!
		if !KEY! == 111 set /a "GUI_UPD=1, CO!SELCOL!+=2" & (for %%c in (!SELCOL!) do if !CO%%c! gtr 255 set /a CO!SELCOL!=255) & call :MAKECOL !SELCOL!
		if !KEY! == 79  set /a "GUI_UPD=1, CO!SELCOL!-=2" & (for %%c in (!SELCOL!) do if !CO%%c! lss 0 set /a CO!SELCOL!=0) & call :MAKECOL !SELCOL!
		if !KEY! == 115 set /a "GUI_UPD=1, SIZE!SELCOL!+=1" & (for %%c in (!SELCOL!) do if !SIZE%%c! gtr 60 set /a SIZE!SELCOL!=60) & call :MAKEPOLYSTR !SELCOL!
		if !KEY! == 83  set /a "GUI_UPD=1, SIZE!SELCOL!-=1" & (for %%c in (!SELCOL!) do if !SIZE%%c! lss 1 set /a SIZE!SELCOL!=1) & call :MAKEPOLYSTR !SELCOL!

		set /a KEY=0
	)
)
if not defined STOP goto LOOP

endlocal
cmdwiz delay 100
echo "cmdgfx: quit"
title input:Q
goto :eof

:MAKECOL
set /a GUI_UPD=1
set /a CC=0 & for %%a in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do set HX!CC!=%%a&set /a CC+=1
set CURRCOL=
for %%c in (%1) do set /a CO=CO%%c, CR=CR%%c, CG=CG%%c, CB=CB%%c
set /a "BH=CO / 16, BL=CO %% 16"
for %%h in (!BH!) do for %%l in (!BL!) do set CURRCOL=!CURRCOL!!HX%%h!!HX%%l!
set /a "BH=CR / 16, BL=CR %% 16"
for %%h in (!BH!) do for %%l in (!BL!) do set CURRCOL=!CURRCOL!!HX%%h!!HX%%l!
set /a "BH=CG / 16, BL=CG %% 16"
for %%h in (!BH!) do for %%l in (!BL!) do set CURRCOL=!CURRCOL!!HX%%h!!HX%%l!
set /a "BH=CB / 16, BL=CB %% 16"
for %%h in (!BH!) do for %%l in (!BL!) do set CURRCOL=!CURRCOL!!HX%%h!!HX%%l!
set CURRCOL%1=!CURRCOL!
goto :eof

:MAKEGUI
for %%c in (%SELCOL%) do set /a CO=CO%%c, CR=CR%%c, CG=CG%%c, CB=CB%%c, SIZE=SIZE%%c
set GENGUI="fbox 7 0 db !BORD!,!DG!,!WB!,!GUI_H!"
set /a XP=0
set /a TXTY=GUI_HH=DG + GUI_H/2 + 9
set /a "OBX=BORD+20+XP, OPOS=BORD + 20 + CO/2 + XP, GUI_HH=DG + GUI_H/2 - 6"
set /a GUIP0=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Opacity_(o/O) !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 0 0 db !OBX!,!GUI_HH!,128,0 & fellipse 0 0 db !OPOS!,!GUI_HH!,5,5"
set /a XP+=128+30
set /a "OBX=BORD+20+XP, OPOS=BORD + 20 + CR/2 + XP"
set /a GUIP1=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Red_(r/R) !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 0 0 db !OBX!,!GUI_HH!,128,0 & fellipse 0 0 db !OPOS!,!GUI_HH!,5,5"
set /a XP+=128+30
set /a "OBX=BORD+20+XP, OPOS=BORD + 20 + CG/2 + XP"
set /a GUIP2=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Green_(g/G) !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 0 0 db !OBX!,!GUI_HH!,128,0 & fellipse 0 0 db !OPOS!,!GUI_HH!,5,5"
set /a XP+=128+30
set /a "OBX=BORD+20+XP, OPOS=BORD + 20 + CB/2 + XP"
set /a GUIP3=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Blue_(b/B) !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 0 0 db !OBX!,!GUI_HH!,128,0 & fellipse 0 0 db !OPOS!,!GUI_HH!,5,5"

set /a XP+=128+30+20
set /a "OPOS=BORD + 20 + XP, OPOS2=OPOS-8"
set /a GUIP4=OPOS
set GENGUI="!GENGUI:~1,-1! & text 0 0 db LMB !OPOS2!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fellipse !CURRCOL0! 0 db !OPOS!,!GUI_HH!,12,12 & ellipse 0 0 db !OPOS!,!GUI_HH!,12,12"
if !SELCOL! == 0 set GENGUI="!GENGUI:~1,-1! & ellipse a 0 db !OPOS!,!GUI_HH!,13,13"

set /a XP+=40
set /a "OPOS=BORD + 20 + XP, OPOS2=OPOS-8"
set /a GUIP5=OPOS
set GENGUI="!GENGUI:~1,-1! & text 0 0 db RMB !OPOS2!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fellipse !CURRCOL1! 0 db !OPOS!,!GUI_HH!,12,12 & ellipse 0 0 db !OPOS!,!GUI_HH!,12,12"
if !SELCOL! == 1 set GENGUI="!GENGUI:~1,-1! & ellipse a 0 db !OPOS!,!GUI_HH!,13,13"

set /a XP+=60
set /a "OBX=BORD+20+XP, OPOS=BORD + 20 + (SIZE-1)*2 + XP"
set /a GUIP6=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Size_(s/S,scroll_wheel) !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 0 0 db !OBX!,!GUI_HH!,120,0 & fellipse 0 0 db !OPOS!,!GUI_HH!,5,5"

set /a XP+=120 + 60
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6"
set /a GUIP7=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Load !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & box 0 0 db !OBX!,!GUI_YP!,24,24"

set /a XP+=50
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6"
set /a GUIP8=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Save !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & box f 0 db !OBX!,!GUI_YP!,24,24"

set /a XP+=50
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6"
set /a GUIP9=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Clear !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & box 4 0 db !OBX!,!GUI_YP!,24,24"

set /a XP+=90
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6"
set /a GUIP10=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Gray !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 8 0 db !OBX!,!GUI_YP!,24,24"

set /a XP+=40
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6"
set /a GUIP11=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Invert !OBX!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & fbox 226677 0 db !OBX!,!GUI_YP!,24,24"

set /a XP+=80
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6, OBX2=OBX-20"
set /a GUIP12=OBX
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Pick_col !OBX2!,!TXTY! 1"
set GENGUI="!GENGUI:~1,-1! & ellipse d 0 db !OBX!,!GUI_HH!,12,12"

set /a XP+=80
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6, OBX2=OBX-10, TXTY2=TXTY-16"
set GENGUI="!GENGUI:~1,-1! & text 0 0 db Space=\nswitch !OBX2!,!TXTY2! 1"

set /a XP+=70
set /a "OBX=BORD+20+XP, GUI_YP=DG + 6, OBX2=OBX-20"
set GENGUI="!GENGUI:~1,-1! & text 0 0 db ESC=\nquit !OBX2!,!TXTY2! 1"

goto :eof

:PROCESS_GUI
set /a TSTX=GUIP0+128 & if !M_X! gtr !GUIP0! if !M_X! lss !TSTX! set /a "GUI_UPD=1, CO!SELCOL!=(M_X-GUIP0)*2+1" & call :MAKECOL  !SELCOL!& goto :EOF
set /a TSTX=GUIP1+128 & if !M_X! gtr !GUIP1! if !M_X! lss !TSTX! set /a "GUI_UPD=1, CR!SELCOL!=(M_X-GUIP1)*2" & call :MAKECOL !SELCOL!& goto :EOF
set /a TSTX=GUIP2+128 & if !M_X! gtr !GUIP2! if !M_X! lss !TSTX! set /a "GUI_UPD=1, CG!SELCOL!=(M_X-GUIP2)*2" & call :MAKECOL !SELCOL!& goto :EOF
set /a TSTX=GUIP3+128 & if !M_X! gtr !GUIP3! if !M_X! lss !TSTX! set /a "GUI_UPD=1, CB!SELCOL!=(M_X-GUIP3)*2" & call :MAKECOL !SELCOL!& goto :EOF
set /a TSTX=GUIP6+128 & if !M_X! gtr !GUIP6! if !M_X! lss !TSTX! set /a "GUI_UPD=1, SIZE!SELCOL!=(M_X-GUIP6)/2+1" & call :MAKEPOLYSTR !SELCOL! & goto :EOF

set /a TSTX=GUIP4-12,TSTX2=GUIP4+12 & if !M_X! gtr !TSTX! if !M_X! lss !TSTX2! set /a GUI_UPD=1, SELCOL=0 & goto :EOF
set /a TSTX=GUIP5-12,TSTX2=GUIP5+12 & if !M_X! gtr !TSTX! if !M_X! lss !TSTX2! set /a GUI_UPD=1, SELCOL=1 & goto :EOF

set /a TSTX=GUIP7+24 & if !M_X! gtr !GUIP7! if !M_X! lss !TSTX! (
	for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
		echo "cmdgfx: !REMOVEGUI! & image %%I 0 0 0 -1 0,0 0 0 !W!,!H! & !SAVEFORGUI! & !GUI! !GENGUI:~1,-1!"
	)
	set /a IGNORE_M=3
)
set /a TSTX=GUIP8+24 & if !M_X! gtr !GUIP8! if !M_X! lss !TSTX! echo "cmdgfx: !REMOVEGUI!" c:0,0,!W!,!H!,2,0& goto :EOF
set /a TSTX=GUIP9+24 & if !M_X! gtr !GUIP9! if !M_X! lss !TSTX! echo "cmdgfx: fbox 0 0 db"& goto :EOF

set /a TSTX=GUIP10+24 & if !M_X! gtr !GUIP10! if !M_X! lss !TSTX! echo "cmdgfx: !REMOVEGUI! & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(fgcol(x,y),0)+store((fgr(s0)*0.2126+fgg(s0)*0.7152+fgb(s0)*0.0722),1)+makecol(s1,s1,s1) & !SAVEFORGUI!"& goto :EOF
set /a TSTX=GUIP11+24 & if !M_X! gtr !GUIP11! if !M_X! lss !TSTX! echo "cmdgfx: !REMOVEGUI! & block 0 0,0,!W!,!H! 0,0 -1 0 0 - store(fgcol(x,y),0)+makecol(255-fgr(s0),255-fgg(s0),255-fgb(s0)) & !SAVEFORGUI!"& goto :EOF

set /a TSTX=GUIP12-12,TSTX2=GUIP12+12 & if !M_X! gtr !TSTX! if !M_X! lss !TSTX2! set /a COLPICK=1
goto :eof

:COLPICK
del /Q capture-99.bmp colpick.hex >nul 2>nul
echo "cmdgfx: " c:%1,%2,1,1,2,99
:WAITLOOP
if not exist capture-99.bmp goto :WAITLOOP
certutil -encodehex capture-99.bmp colpick.hex 12 >nul 2>nul 
set /p STR=<colpick.hex
set RS=%STR:~112,2%
set GS=%STR:~110,2%
set BS=%STR:~108,2%

call :FROMHEX !RS! VAL & set /a CR!SELCOL!=VAL
call :FROMHEX !GS! VAL & set /a CG!SELCOL!=VAL
call :FROMHEX !BS! VAL & set /a CB!SELCOL!=VAL
call :MAKECOL !SELCOL!
set /a COLPICK=0
del /Q capture-99.bmp colpick.hex  >nul 2>nul
goto :eof

:MAKEPOLYSTR
set POLY=
if !SHAPE!==0 for %%c in (%1) do for /L %%a in (0,1,22) do set /a "MXP=!MX%%a!*!SIZE%%c!/1000, MYP=!MY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
if !SHAPE!==1 for %%c in (%1) do for /L %%a in (0,1,3) do set /a "MXP=!BMX%%a!*!SIZE%%c!/1000, MYP=!BMY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
if !SHAPE!==2 for %%c in (%1) do for /L %%a in (2,4,22) do set /a "MXP=!MX%%a!*!SIZE%%c!/1000, MYP=!MY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
if !SHAPE!==3 for %%c in (%1) do for %%a in (2 16 7 21 11) do set /a "MXP=!MX%%a!*!SIZE%%c!/1000, MYP=!MY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
if !SHAPE!==4 for %%c in (%1) do for %%a in (4 19 11) do set /a "MXP=!MX%%a!*!SIZE%%c!/1000, MYP=!MY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
if !SHAPE!==5 for %%c in (%1) do for %%a in (1 2 15 16) do set /a "MXP=!MX%%a!*!SIZE%%c!/1000, MYP=!MY%%a!*!SIZE%%c!/1000"&set POLY=!POLY!!MXP!,!MYP!,
set POLYSTR%1=!POLY!& set POLY=
goto :eof

:FROMHEX
set NN=%1
set /a CNT=0 & for %%c in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do (if %%c==%NN:~0,1% set /a %2=CNT*16) & set /a CNT+=1
set /a CNT=0 & for %%c in (0 1 2 3 4 5 6 7 8 9 a b c d e f) do (if %%c==%NN:~1,1% set /a %2+=CNT) & set /a CNT+=1
goto :eof

:: https://stackoverflow.com/a/15885133/1683264
: end Batch portion / begin PowerShell hybrid chimera #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "BMP Files (*.bmp)|*.bmp|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $false
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }
