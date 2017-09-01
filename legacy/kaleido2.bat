@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
bg font 2 & cls & cmdwiz showcursor 0
set /a W=120, H=80
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="

set /a XMID=%W%/2, YMID=%H%/2, DIST=7000, DRAWMODE=0
set /a CRX=0,CRY=0,CRZ=0
set ASPECT=1

set /a S1=66, S2=12, S3=30
if "%~1" == "1" set /a S1=33, S2=24, S3=15
if "%~1" == "2" set /a S1=100, S2=8, S3=45
if "%~1" == "3" set /a S1=25, S2=30, S3=12

set FN=tri.obj
echo usemtl cmdblock 0 0 70 70 >%FN%
echo v  0 0 0 >>%FN%
echo v  0 100 0 >>%FN%
echo v  %S1% 100 0 >>%FN%
echo vt 0 0 >>%FN%
echo vt 0 1 >>%FN%
echo vt 1 1 >>%FN%
echo f 1/1/ 2/2/ 3/3/ >>%FN%

set STREAM="01??=00db,11??=6004,21??=60db,31??=e604,41??=e6db,51??=e6db,61??=ef04,71??=fe04,81??=fedb,91??=fe04,a1??=ef04,b1??=e6db,c1??=e604,d1??=60db,e1??=6004,f1??=00db,03??=00db,13??=2004,23??=20db,33??=a204,43??=a2db,53??=a2db,63??=af04,73??=af04,83??=fadb,98??=fadb,a8??=af04,b8??=a2db,c8??=a204,d8??=20db,e8??=2004,f8??=00db,0e??=00db,1e??=4004,2e??=40db,3e??=c404,4e??=c4db,5e??=c4db,6e??=cfb2,7e??=cf04,8e??=cf20,9e??=fdb2,ae??=df04,be??=d4db,ce??=d504,de??=50db,ee??=5004,fe??=00db,0???=00db,1???=1004,2???=10db,3???=9104,4???=91db,5???=9bb2,6???=9b04,7???=b9db,8???=bf04,9???=9bb0,a???=9bb2,b???=91db,c???=9104,d???=10db,e???=1004,f???=00db"
set /a XMUL=360, YMUL=240, RANDPIX=3, A1=155, A2=0

call sindef.bat

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP (

	set /a A1+=1, A2-=2, TRZ=!CRZ!
	set /a "COLCNT=(%SINE(x):x=!A1!*31416/180%*!XMUL!>>!SHR!), COLCNT2=(%SINE(x):x=!A2!*31416/180%*!YMUL!>>!SHR!)"
	
	set OUTP="fbox 7 0 20 0,0,%W%,%H% & block 0 0,0,70,70 0,0 -1 0 0 !STREAM! random()*!RANDPIX!/2+sin((x-!COLCNT!/4)/80)*(y/2)+cos((y+!COLCNT2!/9.5)/35)*(x/3)"
   for /L %%1 in (1,1,%S2%) do set OUTP="!OUTP:~1,-1! & 3d %FN% %DRAWMODE%,-1 0,0,!TRZ! 0,0,0 10,10,10,0,0,0 0,0,0,10 %XMID%,%YMID%,!DIST!,%ASPECT% 0 0 db"&set /A TRZ+=%S3%*4
	
	start /B /High cmdgfx_gdi !OUTP! f2:0,0,%W%,%H%
	cmdgfx "" knW12
	set KEY=!ERRORLEVEL!

	set /a CRZ+=3

	if !KEY! == 112 cmdwiz getch
	if !KEY! == 32 set STREAM=?
	if !KEY! == 27 set STOP=1
	if !KEY! == 13 cmdwiz stringfind "!STREAM!" "04," & (if !errorlevel! gtr -1 set STREAM=!STREAM:04,=b1,!) & (if !errorlevel! equ -1 set STREAM=!STREAM:b1,=04,!)
)
if not defined STOP goto LOOP

endlocal
bg font 6 & cmdwiz showcursor 1 & mode 80,50
del /Q tri.obj
