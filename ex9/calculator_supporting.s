; This file provides useful methods for use in calculator.s
; Methods provided here:
;  -setOperator
;  -copyTable
;  -convertNumToTable
;  -convertTableToNum
;  -convertIndexToValue
;  -clearTable
;  -pushNewChar
;  -shiftchars
;  -printline



setOperator ;takes operator num at R0
PUSH {LR}   ;this function will print the operator one line1
PUSH {R1}
STRB R0, operator
MOV R1, R0
ADRL R0, LF
BL printstr
CMP R1, #1
ADREQ R0, c_plus
CMP R1, #2
ADREQ R0, c_minus
CMP R1, #3
ADREQ R0, c_divide
CMP R1, #4
ADREQ R0, c_multiply
BL printstr

ADRL R0, VT
BL printstr
ADRL R0, backspace
BL printstr
MOV R0, R1
POP {R1}
POP {LR}
MOV PC, LR
ALIGN
c_plus DEFB "+",0
c_minus DEFB "-",0
c_divide DEFB "/",0
c_multiply DEFB "*",0
C_plus EQU 1
C_minus EQU 2
C_divide EQU 3
C_multiply EQU 4
ALIGN
copyTable
; R0 defines SRC table
; R1 defines DST table
; the difference in bytes between the tables are (DST - SRC) * table_size
PUSH {LR}
PUSH {R2 - R12}
CMP R0, #table_nums
BLGE halt
CMP R1, #table_nums
BLGE halt

MOV R2, #0 ;stores the difference
SUB R2, R1, R0 ; (DST - SRC)
MOV R3, #0 ; used in fast multiplier and also as an itterator
ADD R2, R3, R2, LSL #3 ;Fast multipiler of 8 (needs changing if table size changes)
ADRL R4, table_bases
ADD  R4, R4, R0
copyLoop
LDRB R5, [R4, R3]
ADD  R4, R4, R2   ;increase R4 by differnce in bytes between tables
STRB R5, [R4, R3]
SUB  R4, R4, R2   ;undo difference
ADD R3, R3, #1
CMP R3, #table_size
BNE copyLoop

POP {R2 - R12}
POP {LR}
MOV PC, LR


convertNumToTable
;takes num to convert at R0
;takes table to set at R1
PUSH {LR}
PUSH {R2 - R12}
PUSH {R0} ;to avoid corrupting user state
CMP R1, #table_nums
BLGT halt
BL bcd_convert
MOV R2, #0 ;itterator
MOV R5, #0 ;constant
MOV R6, #&0000_000F ; mask
ADRL R3, table_bases
ADD  R3, R3, R1, LSL #3
ADD  R3, R3, #8 ;start at table end
writeLoop
ADD R7, R5, R2, LSL #2 ;multiply itterator by 4
ADD R4, R5, R0, ASR R7
AND R8, R4, R6          ; mask BCD number out
SUB R9, R3, R2          ;find correct table place to write to
SUB R9, R9, #1
STRB R8, [R9]           ;perform write


ADD R2, R2, #1 ;loop closure conditions
CMP R2, #8
BNE writeLoop


POP {R0}
POP {R2 - R12}
POP {LR}
MOV PC, LR

convertIndexToValue
;takes index at R0
;returns to R0
; used to determine the value of a key press
PUSH {LR}
PUSH {R1 - R2}
CMP R0, #12
BLGE halt
ADRL R1, keyvalues
LDRB R0, [R1, R0]
POP  {R1 - R2}
POP  {LR}
MOV  PC, LR

clearTable ; R0 defines which table to target
PUSH {LR}
PUSH {R1 - R12}
CMP     R0, #table_nums ;check table is valid
BLGT     halt
MOV  R1, #0
ADRL R2, table_bases
ADD  R2, R2, R0, LSL #3 ;jump to correct table by adding R0*table_size
MOV  R3, #0
clearLoop
STRB R1, [R2],#1        ;zero out table
ADD R3, R3, #1
CMP R3, #table_size
BNE clearLoop
POP  {R1 - R12}
POP  {LR}
MOV  PC, LR

pushNewChar
; R0 defines which table to target
; R1 defines the number to add
PUSH {LR}
PUSH {R1 - R12}
BL shiftchars
BL printline
POP  {R1 - R12}
POP  {LR}
MOV  PC, LR

convertTableToNum

; R0 defines which table to target
; will corrupt R0 for output
PUSH    {LR}
PUSH    {R1 - R12}
CMP     R0, #table_nums
BLGT     halt
MOV     R1, #0 ; accumilator
MOV     R2, #10 ; constant
ADRL    R3, table_bases
ADD     R3, R3, R0, LSL #3 ;jump to correct table by adding R0*table_size
ADD     R3, R3, #table_size ;target end of table first
MOV     R4, #0 ; itterator
MOV     R5, #1 ; multipiler
addLoop
LDRB    R6, [R3,#-1]!
MUL     R7, R6, R5
ADD     R1, R1, R7
MUL     R5, R5, R2  ; increase multipiler

;loop restrictions
ADD     R4, R4, #1
CMP     R4, #table_size
BNE addLoop
MOV     R0, R1
POP     {R1 - R12}
POP     {LR}
MOV     PC, LR

shiftchars
;R0 defines which table to target
;R1 defines the value to be copied into the LSD
;MSD lost
PUSH {LR}
PUSH {R2 - R12}
CMP     R0, #table_nums
BLGT     halt
ADRL   R2, table_bases
ADD    R2, R2, R0, LSL #3 ;jump to correct table by adding R0*table_size
MOV    R3, #0 ;itterator
ADD    R2, R2, #1
startShiftLoop
LDRB   R4, [R2], #-1   ; These two commands shift the numbers in the table to the left on the screen
STRB   R4, [R2], #2
ADD    R3, R3, #1
CMP    R3, #7
BNE startShiftLoop
STRB   R1, [R2, #-1] ;write new value
POP {R2 - R12}
POP {LR}
MOV PC, LR

printline ;takes table num as R0
PUSH {LR}
PUSH {R1 - R12}

MOV R2, #0
moveCursor        ;this will print as many linefeeds as neccessary
CMP R0, #0        ;  to target the correct table
PUSH {R0}
BEQ skipSign
LDRB R1, table1sign
CMP R1, #0
BEQ blankSign
ADRL R0, c_minus
BL printstr
ADRL R0, backspace
BL printstr
B skipSign
blankSign
ADRL R0, hardblank
BL printstr
ADRL R0, backspace
BL printstr
skipSign
POP {R0}
PUSH {R0}
CMP R2, R0
ADRL R0, LF
BLNE printstr
ADDNE R2, R2, #1
BNE moveCursor


ADRL R0, blank
BL printstr
POP {R0}
CMP     R0, #table_nums
BLGT     halt
ADRL    R1, table_bases ;holds address of first number row
ADD     R1, R1, R0, LSL #3 ; Address += R0*8
MOV     R2, #-1 ; itterator
MOV     R5, #0
startprintingnum
ADD     R2, R2, #1
CMP     R2, #table_size  ; max num of digits
BEQ end
LDRB    R3, [R1], #1
CMP     R3, #0 ; if number is not between 0-9 assume blankspace
BLT blankSpace
BEQ zeroCheck
CMP     R3, #9
BGT blankSpace
MOV     R5, #1
ADD     R4, R3, #48 ; offset by 48 to convert to ascii
STRB    R4, printbit ; write to an address so i cant printstr it
PUSH    {R0}
ADRL    R0, printbit
BL printstr
POP     {R0}
B startprintingnum

blankSpace
PUSH {R0}
ADRL R0, blank
BL printstr
POP  {R0}
B startprintingnum

zeroCheck
CMP     R5, #0
ADD     R4, R3, #48
STRB    R4, printbit
PUSH    {R0}
ADRL    R0, printbit ;by default try to write 0
ADRLEQ  R0, hardblank    ;overwrite if need be
BL printstr
POP {R0}
B startprintingnum

end
MOV R2, R0
ADRL R0, return ;move to start
BL printstr

;need to move cursor up R0 places

MOV R3, #0
ADRL R0, VT
VTloop
CMP R3, R0
BLNE printstr
ADDNE R3, R3, #1
BNE VTloop


MOV R0, R2
POP {R1 - R12}
POP {LR}
MOV PC, LR
