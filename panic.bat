@if exist cmdgfx.exe move /Y cmdgfx.exe cmdgfx_crash.exe>nul 2>nul&echo Moved faulty)(?) cmdgfx&goto phase2
@if exist cmdgfx_crash.exe move /Y cmdgfx_crash.exe cmdgfx.exe>nul 2>nul&echo Restored cmdgfx
:phase2
@if exist  cmdgfx_gdi.exe move /Y  cmdgfx_gdi.exe  cmdgfx_gdi_crash.exe>nul 2>nul&echo Moved faulty(?) cmdgfx_gdi&goto :eof
@if exist  cmdgfx_gdi_crash.exe move /Y  cmdgfx_gdi_crash.exe  cmdgfx_gdi.exe>nul 2>nul&echo Restored cmdgfx_gdi
