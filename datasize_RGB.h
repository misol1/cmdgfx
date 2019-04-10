
#ifndef DATASIZE_H
#define DATASIZE_H

#define _RGB32

#define uchar unsigned long long
#define BITSHL 32
#define AND_MASK 0xffffff
#define BG_AND_MASK 0xffffff00000000
#define MYMEMSET(a, b, c)	for (int __i = 0; __i < (c); __i++) (a)[__i] = (b);
#define MYMEMCPY(a, b, c)	for (int __i = 0; __i < (c); __i++) (a)[__i] = (b)[__i];
#define PREPCOL unsigned long long 
#define TRANSPVAL 0x1000000
#define SAFE_AND & 0xff
#define PLUSVAL_OP ^

#endif