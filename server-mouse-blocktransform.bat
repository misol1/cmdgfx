@echo off
cls & bg font 2
cmdwiz showcursor 0
if defined __ goto :START
mode 150,75
set __=.
cmdgfx_input.exe mW13 | call %0 %* | cmdgfx_gdi "" Sf2:0,0,350,75,150,75
set __=
mode 80,50
cls & bg font 6
goto :eof

:START
setlocal ENABLEDELAYEDEXPANSION
for /F "tokens=1 delims==" %%v in ('set') do set "%%v="
if "%~1"=="" echo "cmdgfx: image img\mm.txt 0 0 0 -1 200,0 & image img\mm.txt 0 0 0 -1 275,0"
if not "%~1"=="" echo "cmdgfx: image img\fract.txt 0 0 0 -1 200,0 & image img\fract.txt 0 0 0 -1 275,0"

set /a DL=0, DR=0, KEY=0, COL=0, SIZE=2, KD=0
set DRAW=""&set STOP=&set OUTP=

set PAL0=0???=0???,1???=1???,2???=1???,3???=1???,4???=9???,5???=9???,6???=9???,7???=b???,8???=b???,9???=b???,a???=f???,b???=f???,c???=f???,d???=e???,e???=e???,f???=c???
set PAL1=0???=0???,1???=1???,2???=1???,3???=1???,4???=9???,5???=9???,6???=9???,7???=b???,8???=b???,9???=b301,a???=f301,b???=f???,c???=f???,d???=e???,e???=e???,f???=c???
set PAL2=0???=0???,1???=4???,2???=4???,3???=4???,4???=c???,5???=c???,6???=c???,7???=c???,8???=e???,9???=e???,a???=e???,b???=f???,c???=f???,d???=7???,e???=8???,f???=8???
set PAL3=0???=0???,1???=5???,2???=5???,3???=5???,4???=d???,5???=d???,6???=d???,7???=d???,8???=d???,9???=7???,a???=7???,b???=f???,c???=f???,d???=a???,e???=2???,f???=2???
set PAL4=

:: a circle shape
set /a "MX0=0, MY0=7, MX1=3, MY1=7, MX2=6, MY2=5, MX3=7, MY3=2, MX4=7, MY4=-2, MX5=6, MY5=-5, MX6=4, MY6=-7, MX7=0, MY7=-8"
set /a "MX8=-3, MY8=-8, MX9=-6, MY9=-6, MX10=-8, MY10=-3, MX11=-8, MY11=0, MX12=-7, MY12=3, MX13=-5, MY13=6, MX14=-2, MY14=7"

set EXTRA=&for /L %%a in (1,1,100) do set EXTRA=!EXTRA!xtra

:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (
	echo "cmdgfx: !DRAW:~1,-1! & block 0 200,0,150,75 0,0 -1 0 0 !PAL%%c! & skip %EXTRA%%EXTRA%%EXTRA%%EXTRA%%EXTRA%"

	set /p INPUT=
	for /f "tokens=1,2,4,6, 8,10,12,14,16,18,20,22" %%A in ("!INPUT!") do ( set EV_BASE=%%A & set /a K_EVENT=%%B, K_DOWN=%%C, K_KEY=%%D,  M_EVENT=%%E, M_X=%%F, M_Y=%%G, M_LB=%%H, M_RB=%%I, M_DBL_LB=%%J, M_DBL_RB=%%K, M_WHEEL=%%L 2>nul ) 

	set DRAW=""

	if not "!EV_BASE:~0,1!" == "N" (
		if !M_EVENT!==1 (
			for /L %%a in (0,1,14) do set /a "MXP=!MX%%a!*!SIZE!+!M_X!+200, MYP=!MY%%a!*!SIZE!+!M_Y!"&set OUTP=!OUTP!!MXP!,!MYP!,
			if !M_WHEEL! == 1 set /a SIZE-=1&if !SIZE! lss 1 set SIZE=1
			if !M_WHEEL! == -1 set /a SIZE+=1&if !SIZE! gtr 4 set SIZE=4
			if !M_LB! == 1 set DRAW="ipoly 1 0 ? 4 !OUTP:~0,-1!"
			if !M_RB! == 1 set DRAW="ipoly 1 0 ? 5 !OUTP:~0,-1!"
			set OUTP=
		)
		if !K_EVENT!==1 if !K_DOWN!==1 (
				if !K_KEY! == 32 set /a COL+=1&if !COL! gtr 4 set COL=0
				if !K_KEY! == 27 set STOP=1
			)
		)
	)
)
if not defined STOP goto LOOP

endlocal
echo "cmdgfx: quit"
echo Q>inputflags.dat