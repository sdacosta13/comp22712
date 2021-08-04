;###############################################
;# Written By: Sam da Costa                    #
;# Uni ID: p11469sd                            #
;# Exercise:  3                                #
;# Purpose: This file contains the subroutines #
;# printc and printstr to enable terminal      #
;# printing                                    #
;###############################################

ALIGN
printc
;takes parameter R0 <- address of character
;leaf procedure
PUSH {R1 - R12}
;setup
LDR         R1, cursorposx
LDR         R2, cursorposy
MOV         R3, #0
MOV         R4, #-1
ADRL        R6, bmask0
; Corrects cursors for newline if needed
CMP         R1, #40
SUBGE       R1, R1, #40
ADDGE       R2, R2, #1
;calculates base address to draw from
LDR         R8, LCD_linediff
MUL         R8, R8, R2
LDR         R9, charwidth
MUL         R9, R9, R1
ADD         R8, R8, R9
LDR         R9, addr_LCD
ADD         R8, R8, R9        ;base now in R8, R9 free
;----
;handles incrememts of byte and bit
;this procedure uses byte and bit as x and y respectively
next
CMP         R4, #7
MOVEQ       R4, #0
ADDEQ       R3, R3, #1
ADDNE       R4, R4, #1
CMP         R3, #7
BEQ         POSTEND





LDRB        R5, [R0, R3] ;loads the font byte
LDRB        R7, [R6, R4] ;loads the mask
AND         R5, R7, R5 ; check the bit

;calculates address to write to
MOV         R9, #3
MUL         R9, R9, R3
LDR         R10, LCD_width
MUL         R10, R10, R4
ADD         R9, R9, R10
ADD         R9, R9, R8      ;address to write in R9

CMP         R5, R7 ;determine which colour to draw in
BEQ high
BNE low

high ;no colour support yet - this would need to be changed
LDRB R10, WHITE
STRB R10, [R9], #1
STRB R10, [R9], #1
STRB R10, [R9]
B next

low
LDRB R10, BLACK
STRB R10, [R9], #1
STRB R10, [R9], #1
STRB R10, [R9]
B next

POSTEND
;draws the 8th blank line
MOV   R10, #3
MUL   R9, R10, R3
LDR   R10, LCD_width
MUL   R10, R10, R4
ADD   R9, R9, R10
LDR   R10, addr_LCD
ADD   R9, R9, R10
LDR   R11, charwidth
MUL   R10, R1, R11
ADD   R9, R10, R9
LDR   R11, LCD_linediff
MUL   R10, R2, R11
ADD   R9, R10, R9

LDRB  R10, BLACK
STRB  R10, [R9], #1
STRB  R10, [R9], #1
STRB  R10, [R9]
ADD   R4, R4, #1
CMP   R4, #8 ;re-uses bit counter reg
BNE POSTEND

;update cursor positions below
ADD   R1, R1, #1
ADRL  R12, cursorposx
STR   R1, [R12]
ADRL  R12, cursorposy
STR   R2, [R12]



;return to program
POP {R1 - R12}
MOV PC, LR

ALIGN
printstr
; address at R0
; assume LR was pushed
PUSH {R1 - R8}
PUSH {LR}
MOV           R8, R0        ; R0 will be overwritten soon
printnextc
LDRB          R1, [R8], #1  ; get the next character
SUBS          R2, R1, #&20  ; subtract to get the ascii value to a known base
BLT control                 ; if branch taken: char is a control symbol else: char is an ascii character
ADRL          R3, font_32
MOV           R4, #7
MUL           R2, R2, R4    ; calculate offset to correct font
ADD           R0, R3, R2
BL printc
B printnextc


; determines which control code needs executing
control
CMP           R1, #00
BEQ           exitstring      ; terminate if 0 seen

CMP           R1, #&08
BEQ           c_backspace

CMP           R1, #&09
BEQ           c_HT

CMP           R1, #&0A
BEQ           c_LF

CMP           R1, #&0B
BEQ           c_VT

CMP           R1, #&0C
BEQ           c_FF

CMP           R1, #&0D
BEQ           c_CR


;the following methods change the cursorposx, cursorposy values
;such that the cursor is in the correct position after a control code
;using R5,6,7
c_backspace
LDR     R5, cursorposx
LDR     R6, cursorposy
CMP     R5, #0
BNE     subtract
CMP     R6, #0
BEQ     quitcontrol
SUB     R6, R6, #1
MOV     R5, #39
B quitcontrol

subtract
SUB     R5, R5, #1
quitcontrol
ADRL    R7, cursorposx
STR     R5, [R7]
ADRL    R7, cursorposy
STR     R6, [R7]
B printnextc

c_HT
LDR     R5, cursorposx
LDR     R6, cursorposy
ADD     R5, R5, #1
CMP     R5, #40
SUBGE   R5, R5, #40
ADDGE   R6, R6, #1
ADRL    R7, cursorposx
STR     R5, [R7]
ADRL    R7, cursorposy
STR     R6, [R7]
B printnextc

c_LF
LDR     R6, cursorposy
CMP     R6, #29
ADDNE   R6, R6, #1
ADRL    R7, cursorposy
STR     R6, [R7]
B printnextc

c_VT
LDR     R6, cursorposy
CMP     R6, #0
SUBGT   R6, R6, #1
ADRL    R7, cursorposy
STR     R6, [R7]
B printnextc

c_FF
LDR     R5, addr_LCD
LDRB    R6, BLACK
LDR     R7, addr_LCD_end
screenblankloop
STRB    R6, [R5], #1
CMP     R5, R7
BNE screenblankloop
MOV     R5, #0
ADRL    R6, cursorposx
STR     R5, [R6]
ADRL    R6, cursorposy
STR     R5, [R6]
B printnextc

c_CR
MOV     R6, #0
ADRL    R7, cursorposx
STR     R6, [R7]
B printnextc

; cleanup and exit
exitstring
POP {LR}
POP {R1 - R8}
MOV PC, LR



;---------------------------------------
;  DEFINITIONS
;---------------------------------------








align
