;############################################kmd
;# Written By: Sam da Costa                 #
;# Uni ID: p11469sd                         #
;# Exercise:  3                             #
;# Purpose: This file demos different parts #
;# of the lcd module                        #
;############################################
INCLUDE os.s
usercode

ADRL      R0, FF
BL printstr
ADRL      R0, test3 ;print hello world
BL printstr
ADRL      R0, LF ;move cursor down by 1
BL printstr
ADRL      R0, test2 ;print C
BL printstr
ADRL      R0, LF ;move cursor down by 1
BL printstr
ADRL      R0, test ;print This should be on line 3
BL printstr
B halt

;definitions
INCLUDE lcd.s
test            DEFB "This should be on line 3",0 ; (lines start at 0)
test2           DEFB "C",0
test3           DEFB "Hello World!",0
