@echo off
setlocal ENABLEDELAYEDEXPANSION
bg font 0 & cls
set /a W=274, H=109
mode %W%,%H%
for /F "Tokens=1 delims==" %%v in ('set') do if not %%v==H if not %%v==W set "%%v="
for /L %%a in (0,1,30) do set /a R%%a=!RANDOM! %% 20
set /a BW=125, WD=-2, BWM=145, BXF=0

:REP
for /L %%1 in (1,1,300) do if not defined STOP  (
   set OUT=""
	set /a MC=0
   for /L %%a in (0,1,8) do for %%c in (!MC!) do set /a "Y=%%a*11+3, R!MC!+=1, I=(!R%%c!/8) %% 2 + 1, MC+=1" & set OUT="!OUT:~1,-1! & image img\mario!I!.gxy 0 0 0 0 1,!Y! 1 1 13,11"
	for /L %%a in (0,1,5) do for %%c in (!MC!) do set /a "Y=%%a*18, R!MC!+=1, I=(!R%%c!/10) %% 2 + 1, MC+=1" & set OUT="!OUT:~1,-1! & image img\mario!I!.gxy 0 0 0 0 19,!Y! 0 0 21,18"
   for /L %%a in (0,1,3) do for %%c in (!MC!) do set /a "Y=%%a*27-1, R!MC!+=1, I=(!R%%c!/9) %% 2 + 1, MC+=1" & set OUT="!OUT:~1,-1! & image img\mario!I!.gxy 0 0 0 0 45,!Y! 0 1 28,27"
   for /L %%a in (0,1,1) do for %%c in (!MC!) do set /a "Y=%%a*54+1, R!MC!+=1, I=(!R%%c!/7) %% 2 + 1, MC+=1" & set OUT="!OUT:~1,-1! & image img\mario!I!.gxy 0 0 0 0 80,!Y! 1 0 60,56"
	for %%c in (!MC!) do set /a "R!MC!+=1, I=(!R%%c!/6) %% 2 + 1" & set OUT="!OUT:~1,-1! & image img\mario!I!.gxy 0 0 0 0 !BWM!,4 !BXF! 0 !BW!,108"
	
	cmdgfx_gdi "fbox 8 0 . 0,0,%W%,%H% & !OUT:~1,-1!" kf0
	set KEY=!ERRORLEVEL!
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
	set /a "RB+=1, BW+=!WD!, BWM=145+(125-!BW!)/2"
	if !BW! lss 2 set /a WD=2, BXF=1-!BXF!
	if !BW! gtr 125 set WD=-2
)
if not defined STOP goto REP

endlocal
bg font 6
mode 80,50 & cls
