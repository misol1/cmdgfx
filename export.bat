@echo off
mkdir export
copy /Y *.bat export
del /Q export\makeall.bat export\bit-balls.bat export\emma.bat export\export.bat export\panic.bat
for %%a in (3dworld.dat 3dworld2.dat bg.exe cmdgfx.exe cmdgfx_gdi.exe cmdwiz.exe) do copy /Y %%a export
xcopy /Y /S /I img export\img
xcopy /Y /S /I objects export\objects
cd export
zip -r cmdgfx .
cd ..
