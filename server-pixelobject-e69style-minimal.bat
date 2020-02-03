@echo off
cmdwiz setfont 8 & mode 65,40
if "%_%"=="" set _=. & call %0 | cmdgfx_gdi "" SW10f1:0,0,130,80
setlocal EnableDelayedExpansion
set dist=25000
for /l %%1 in () do (
	set /a rx+=3, ry-=4, rz+=5 & if !dist! gtr 7000 set /a dist-=100
	set S=3d objects\plot-sphere.ply 0,-1 !rx!,!ry!,!rz! 0,0,0 1.2,1.2,1.2,0,0,0
	set E=65,40,!dist!,0.75 7 0
	echo "cmdgfx: fbox 0 0 0 & !S! 0,1,0,10 !E! 07 & !S! 0,0,1,10 !E! 40 & text 7 0 0 [FRAMECOUNT] 1,1"
)
