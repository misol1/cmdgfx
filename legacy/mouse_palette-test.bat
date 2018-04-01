:: Return value in ERRORLEVEL from M[wait] flag is: kkkkkkkkkSyyyyyyyxxxxxxxxxUDRLm

:: k are key bits (V>>22)
:: S is 1 if key is pressed, otherwise released ((V>>21)&1)
:: x are mouse x bits ((V>>5)&511)
:: y are mouse y bits ((V>>14)&127)
:: U is mouse scroll wheel up ((V&16)>>4)
:: D is mouse scroll wheel down ((V&8)>>3)
:: R is mouse right button ((V&4)>>1)
:: L is mouse left button ((V&2)>>2)
:: m is 1 if there was a mouse event (V&1)
:: If no events (timeout), the return value is -1

@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
cmdwiz setfont 2 & mode 150,75 & cls
for /F "tokens=1 delims==" %%v in ('set') do set "%%v="
cmdwiz setbuffersize 350 k
cmdwiz getquickedit & set QE=!errorlevel!&cmdwiz setquickedit 0
cmdwiz showcursor 0
if "%~1"=="" cmdgfx "image img\mm.txt 0 0 0 -1 200,0 & image img\mm.txt 0 0 0 -1 275,0"
if not "%~1"=="" cmdgfx "image img\fract.txt 0 0 0 -1 200,0 & image img\fract.txt 0 0 0 -1 275,0"
cmdwiz saveblock bkg 200 0 150 75

set /a DL=0, DR=0, KEY=0, COL=0, SIZE=2, KD=0
set DRAW=""&set STOP=&set OUTP=

set PAL0=0111999bbbfffeec
set PAL1=0444cccceeeff788
set PAL2=0555ddddd77ffa20

:: a circle shape
set /a "MX0=0, MY0=7, MX1=3, MY1=7, MX2=6, MY2=5, MX3=7, MY3=2, MX4=7, MY4=-2, MX5=6, MY5=-5, MX6=4, MY6=-7, MX7=0, MY7=-8"
set /a "MX8=-3, MY8=-8, MX9=-6, MY9=-6, MX10=-8, MY10=-3, MX11=-8, MY11=0, MX12=-7, MY12=3, MX13=-5, MY13=6, MX14=-2, MY14=7"

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (
   if not !DRAW!=="" (
		cmdgfx "image bkg.gxy 9 0 0 -1 200,0 & !DRAW:~1,-1!" p
		set DRAW=""
		cmdwiz saveblock bkg 200 0 150 75
	)
	cmdgfx "image bkg.gxy 9 0 0 -1 0,0" Mp !PAL%%c!
	set MR=!errorlevel!

	if not !MR!==-1 (
		set /a "KEY=!MR!>>22, KD=(!MR!>>21) & 1"
		set /a "ME=!MR! & 1"
		if not !ME! == 0 (
			set /a "ML=(!MR!&2)>>1, MR=(!MR!&4)>>2, MWD=MT=(!MR!&8)>>3, MWU=(!MR!&16)>>4, MX=(!MR!>>5)&511, MY=(!MR!>>14)&127"
			if !MWD! == 1 set /a SIZE-=1&if !SIZE! lss 1 set SIZE=1
			if !MWU! == 1 set /a SIZE+=1&if !SIZE! gtr 4 set SIZE=4
			for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!MX!+200, MYP=!MY%%a!*!SIZE!+!MY!"&set OUTP=!OUTP!!MXP!,!MYP!,
			if !ML! == 1 set DRAW="ipoly 1 0 ? 4 !OUTP:~0,-1!"
			if !MR! == 1 set DRAW="ipoly 1 0 ? 5 !OUTP:~0,-1!"
			set OUTP=
		)
	)
	if !KEY! == 32 set /a COL+=1&if !COL! gtr 2 set COL=0
	if !KEY! == 27 set STOP=1
	set /a KEY=0
)
if not defined STOP goto LOOP

cmdwiz setquickedit %QE%
endlocal
cmdwiz setfont 6 & mode 80,50 & cls
del /Q bkg.gxy>nul 2>nul
cmdwiz showcursor 1
