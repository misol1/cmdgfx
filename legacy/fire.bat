@echo off
cd ..
setlocal ENABLEDELAYEDEXPANSION
set W=80&set /a WW=!W!*2
cmdwiz setfont 2 & mode %W%,75
cmdwiz setbuffersize %WW% 130
cmdwiz showcursor 0
for /F "tokens=1 delims==" %%v in ('set') do if not "%%v"=="W" if not "%%v"=="WW" set "%%v="

cmdgfx "fbox 4 0 b0 0,0,%WW%,130 & fbox 4 0 20 %W%,0,%W%,95"

set STREAM="1050=a0++,1051=80++,1052=90++,1053=b0++,1054=90++,1055=80++,1056=80++,1057=70++,?0??=-0??"

:: alternative way of writing same thing, but less options (always start new color at 9 here)
::set STREAM="40b0=40b0,4020=4020,1058=1058,10??=90++,?0??=-0??"

set TRANSF0="??50=fedb,??51=feb1,??52=ecdb,??53=ecb1,??54=c4db,??55=c4b1,??56=c4b0,??57=40b1,??58=4020,00b0=40b0"
set TRANSF1="??50=fbdb,??51=fbb1,??52=b9db,??53=b9b1,??54=91db,??55=91b1,??56=10db,??57=10b0,??58=1020,00b0=10b0"
set TRANSF2="??50=ec23,??51=ec2e,??52=ec3a,??53=c42e,??54=c421,??55=c02e,??56=403a,??57=402e,??58=4020,00b0=40fa"
set TRANSF3="??50=91db,??51=91db,??52=91b1,??53=91b0,??54=9123,??55=913a,??56=9121,??57=912e,??58=9120,00b0=91fa"

set /A PW=1,PH=0,COL=0, MODE=1

set STOP=
:LOOP
for /L %%1 in (1,1,300) do if not defined STOP for %%c in (!COL!) do (

	set OUT=""
	if !MODE!==0 for /L %%a in (0,1,%WW%) do set /a "X=!RANDOM! %% %W%+%W%,J=!RANDOM! %% 50+74"&set OUT="!OUT:~1,-1!pixel c 0 50 !X!,!J!&"
	if !MODE!==1 set /A "nf=75-!PW!*10,PWP=(!PW!+1)*2"&for /L %%a in (0,1,!nf!) do set /a "X=!RANDOM! %% %W%+%W%,J=!RANDOM! %% 50+74"&set /a "J2=!J!+!RANDOM! %% !PWP!-!PW!,X2=!X!+!RANDOM! %% !PWP!-!PW!"&set OUT="!OUT:~1,-1!line e 0 50 !X!,!J!,!X2!,!J2!&"
   if !MODE!==2 for /L %%a in (0,1,%W%) do set /a "X=!RANDOM! %% %W%+%W%,J=!RANDOM! %% 50+74"&set OUT="!OUT:~1,-1!fellipse c 0 50 !X!,!J!,!PW!,!PH!&"

	cmdgfx "!OUT:~1,-1! & block 0 %W%,1,%W%,125 %W%,0 -1 0 0 %STREAM:~1,-1% & block 0 %W%,0,%W%,75 0,0 -1 0 0 !TRANSF%%c:~1,-1!" pk
	set KEY=!errorlevel!
	
	if !KEY! == 32 set /A COL+=1&if !COL! gtr 3 set COL=0
	if !KEY! == 333 set /A PW+=1&if !PW! gtr 6 set PW=6
	if !KEY! == 331 set /A PW-=1&if !PW! lss 1 set PW=1
	if !KEY! == 328 set /A PH+=1
	if !KEY! == 336 set /A PH-=1&if !PH! lss 0 set PH=0
	if !KEY! == 13 set /A MODE+=1&if !MODE! gtr 2 set MODE=0
	if !KEY! == 112 cmdwiz getch
	if !KEY! == 27 set STOP=1
)
if not defined STOP goto LOOP

endlocal
cmdwiz setfont 6 & mode 80,50 & cls
cmdwiz showcursor 1
