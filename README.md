# cmdgfx
Windows command line graphic primitives, for text based games/demos by Mikael Sollenborn (2016)

Sorry about the current lack of documentation; have a look at the example files and all will be (kind of) clear...

The gdi version of cmdgfx produces bitmaps instead of text (but looks like text). It sometimes gives very noticeable speed increases. In general, use the non-gdi version.

cmdgfx.exe
----------
```
Usage: cmdgfx [operations] [flags] [fgpalette] [bgpalette]

Drawing operations (separated by &):

poly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
ipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
gpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]
tpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]
image    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip]
box      fgcol bgcol char x,y,w,h
fbox     fgcol bgcol char x,y,w,h
line     fgcol bgcol char x1,y1,x2,y2 [bezierPx1,bPy1[,...,bPx6,bPy6]]
pixel    fgcol bgcol char x,y
circle   fgcol bgcol char x,y,r
fcircle  fgcol bgcol char x,y,r
ellipse  fgcol bgcol char x,y,rx,ry
fellipse fgcol bgcol char x,y,rx,ry
text     fgcol bgcol char string x,y
block    mode[:1233] x,y,w,h x2,y2 [transpchar] [transform] [colExpr] [xExpr yExpr]
3d       objectfile drawmode,drawoption rx,ry,rz tx,ty,tz scalex,scaley,scalez,xmod,ymod,zmod
         face_culling,z_culling_near,z_culling_far,z_sort_levels xpos,ypos,distance,aspect 
         fgcol1 bgcol1 char1 [...fgcol32 bgcol32 char32]
insert   file

Fgcol and bgcol can be specified either as decimal or hex.
Char is specified either as a char or a two-digit hexadecimal ASCII code.
For both char and fgcol+bgcol, specify ? to use existing.

Bitop: 0=Normal, 1=Or, 2=And, 3=Xor, 4=Add, 5=Sub, 6=Sub-n, 7=Normal ipoly.

Image: 256 color pcx file (first 16 colors used), or gxy file, or text file.
If a pcx file is used, transpcol should be specified, otherwise transpchar. Always set transp
to -1 if transparency is not needed!

Gpoly palette follows '1233,' repeated, 1=fgcol, 2=bgcol, 3=char (all in hex).
Transform follows '1233=1233,' repeated, ?/x/- supported. Mode 0=copy, 1=move

String for text op has all _ replaced with ' '. Supports a subset of gxy codes.

Objectfile should point to either a plg, ply or obj file.
Drawmode: 0=flat/texture, 1=flat z-sourced, 2=goraud-shaded z-sourced, 3=wireframe, 4=flat.
Drawoption: Mode 0 textured=transpchar/transpcol(-1 if not used!). Mode 0/4 flat=bitop.
            Mode 1/2: 0=static col, 1=even col. Mode 2: put bitop in high byte.

[flags]: 'p' preserve buffer content, 'k' return code of last keypress, 'K' wait and return key,
         'e/E' suppress/pause errors, 'wn/Wn' wait/await n ms, 'M[wait]' return key/mouse bit
         pattern(see mouse examples).
```

cmdgfx_gdi.exe
--------------
```
Usage: cmdgfx_gdi [operations] [flags] [fgpalette] [bgpalette]

Drawing operations (separated by &):

poly     fgcol bgcol char x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
ipoly    fgcol bgcol char bitop x1,y1,x2,y2,x3,y3[,x4,y4...,y24]
gpoly    palette x1,y1,c1,x2,y2,c2,x3,y3,c3[,x4,y4,c4...,c24]
tpoly    image fgcol bgcol char transpchar/transpcol x1,y1,tx1,ty1,x2,y2,tx2,ty2,x3,y3,tx3,ty3[...,ty24]
image    image fgcol bgcol char transpchar/transpcol x,y [xflip] [yflip]
box      fgcol bgcol char x,y,w,h
fbox     fgcol bgcol char x,y,w,h
line     fgcol bgcol char x1,y1,x2,y2
pixel    fgcol bgcol char x,y
circle   fgcol bgcol char x,y,r
fcircle  fgcol bgcol char x,y,r
ellipse  fgcol bgcol char x,y,rx,ry
fellipse fgcol bgcol char x,y,rx,ry
text     fgcol bgcol char string x,y
block    mode[:1233] x,y,w,h x2,y2 [transform]
3d       objectfile drawmode,drawoption rx,ry,rz tx,ty,tz scalex,scaley,scalez,xmod,ymod,zmod
         face_culling,z_culling_near,z_culling_far,z_sort_levels xpos,ypos,distance,aspect
         fgcol1 bgcol1 char1 [...fgcol32 bgcol32 char32]
insert   file

Fgcol and bgcol can be specified either as decimal or hex.
Char is specified either as a char or a two-digit hexadecimal ASCII code.
For both char and fgcol+bgcol, specify ? to use existing.

Bitop: 0=Normal, 1=Or, 2=And, 3=Xor, 4=Add, 5=Sub, 6=Sub-n, 7=Normal ipoly.

Image: 256 color pcx file (first 16 colors used), or gxy file, or text file.
If a pcx file is used, transpcol should be specified, otherwise transpchar. Always set transp
to -1 if transparency is not needed!

Gpoly palette follows '1233,' repeated, 1=fgcol, 2=bgcol, 3=char (all in hex).
Transform follows '1233=1233,' repeated, ?/x/- supported. Mode 0=copy, 1=move

String for text op has all _ replaced with ' '. Supports a subset of gxy codes.

Objectfile should point to either a plg, ply or obj file.
Drawmode: 0=flat/texture, 1=flat z-sourced, 2=goraud-shaded z-sourced, 3=wireframe, 4=flat.
Drawoption: Mode 0 textured=transpchar/transpcol(-1 if not used!). Mode 0/4 flat=bitop.
            Mode 1/2: 0=static col, 1=even col. Mode 2: put bitop in high byte.

Fgpalette/bgpalette follows '112233,' repeated, 1=red, 2=green, 3=blue (all hex)

[flags]: 'p' preserve buffer content, 'k' return code of last keypress, 'K' wait and return key,
         'e/E' suppress/pause errors, 'wn/Wn' wait/await n ms, 'M[wait]' return key/mouse bit
         pattern(see mouse examples), 'fn[:x,y,w,h]' use font n(0-9, default 6).
```

cmdwiz.exe
----------
```
Usage: cmdwiz [getconsoledim setbuffersize getconsolecolor getch getkeystate 
               flushkeys getquickedit setquickedit getmouse getch_or_mouse
               getch_and_mouse getcharat getcolorat showcursor getcursorpos
               setcursorpos printf saveblock copyblock moveblock inspectblock
               playsound delay stringfind stringlen gettime await getexetype 
               cache setwindowtransparency getwindowpos setwindowpos getdisplaydim
               getmousecursorpos setmousecursorpos insertbmp savefont setfont] [params]
					
Use "cmdwiz operation /?" for info on arguments and return values
```
