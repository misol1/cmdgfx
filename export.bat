@echo off
mkdir export
copy /Y *.bat export
del /Q export\makeall.bat export\emma.bat export\export.bat export\panic.bat export\cpmake.bat export\altmakeall.bat export\distrib.bat
for %%a in (3dworld.dat 3dworld2.dat cmdgfx.exe cmdgfx_gdi.exe cmdwiz.exe 3dworld-maze.dat 3dGUI.dat 3dGUI2.dat cmdgfx_input.exe BG.exe FSCREEN.exe) do copy /Y %%a export
xcopy /Y /S /I img export\img
xcopy /Y /S /I objects export\objects
xcopy /Y /S /I games export\games
xcopy /Y /S /I legacy export\legacy
cd export
zip -r cmdgfx .
cd ..
