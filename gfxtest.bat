@echo off

cls & bg font 6 & mode 80,50

cmdgfx "fellipse 0 b b0 40,25,40,30 & fellipse 0 0 b0 40,25,35,25 & ellipse 5 0 03 40,25,18,18 & line f 4 : 18,40,27,33 & ipoly 6 0 # 0 50,37,80,37,55,49,65,30,75,49 & poly 0 1 20 27,20,50,33,18,10"

cmdwiz getch
