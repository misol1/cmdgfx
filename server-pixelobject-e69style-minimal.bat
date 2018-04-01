@echo off
cmdwiz setfont 8 & mode 65,40
if not defined __ set __=. & call %0 %* | cmdgfx_gdi "" SW10f1:0,0,130,80
setlocal EnableDelayedExpansion
set /a dist=25000
for /l %%1 in () do (
	set /a rx+=3, ry-=4, rz+=5, dist-=100 & if !dist! lss 7000 set /a dist=7000
	echo "cmdgfx: fbox 7 0 20 0,0,130,80 & 3d objects\plot-sphere.ply 0,-1 !rx!,!ry!,!rz! 0,0,0 1.2,1.2,1.2,0,0,0 0,1,0,10 65,40,!dist!,0.75 7 0 07 & 3d objects\plot-sphere.ply 0,-1 !rx!,!ry!,!rz! 0,0,0 1.2,1.2,1.2,0,0,0 0,0,1,10 65,40,!dist!,0.75 7 0 40 & text 7 0 0 [FRAMECOUNT] 1,1"
)
