@echo off
setlocal EnableDelayedExpansion
set /a rW=100, rH=100
cmdwiz getdisplayscale
if !errorlevel! neq 100 if !errorlevel! neq 0 (
	set /a cnt=0, FSX=8  & for %%a in (4 6 8 16 5  7  8  16 12 10 1 2 3 4 5 6) do (if %1==!cnt! set /a FSX=%%a) & set /a cnt+=1
	set /a cnt=0, FSY=12 & for %%a in (6 8 8 8  12 12 12 12 16 18 1 2 3 4 5 6) do (if %1==!cnt! set /a FSY=%%a) & set /a cnt+=1
	cmdwiz getwindowbounds w e & set /a "aW=!errorlevel!, pW=W*FSX, rW=(aW*100)/pW"
	cmdwiz getwindowbounds h e & set /a "aH=!errorlevel!, pH=H*FSY, rH=(aH*100)/pH"
	if "%~2" == "1" (
		for /F "tokens=2,4,6,8" %%a in ('cmdwiz getconsoledim') do @set /a "WT=%%a*100/%%c, HT=%%b*100/%%d"
		set /a "rW=rW*WT/100, rH=rH*HT/100"
	)
	set /a W=W*rW/100, H=H*rH/100
	rem cmdwiz setbuffersize - -
)
endlocal & set /a W=%W%,H=%H%,rW=%rW%,rH=%rH%
