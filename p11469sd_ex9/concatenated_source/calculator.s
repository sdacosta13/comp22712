INCLUDE ../general/os.s ; not provided again ;see project folder if interested
usercode

; This is an attempt to follow the following FSM I designed
;
; STATE 1:
;  0,9,*:  STATE1         (0,9 will push a char onto the first table, star will clear the row)
;  +-/x:   STATE2          (this transition will allow writing of second operand)
;
;
; STATE 2:
;  0,9:  STATE2          (Will write to the second row)
;  +-/x:   STATE2          (Will overwrite operator)
;  *: STATE1             (will reset program to intial state) (if second row is empty it will reset the program)
;  #: STATE2            (will perform operation and copy it to opA)



;reset conditions
MOV R0, #0
STRB R0, curline
STRB R0, curstate
STRB R0, operator
STRB R0, table1sign
STRB R0, table2sign
ADRL R0, FF
BL printstr


;setup
MOV R0, #0
BL clearTable
MOV R0, #1
BL clearTable
ADRL R2, keypresses


;main
scanKeyStart
; called once every loop through the keypad
; need to check addr_ABCDButtons also
MOV R3, #1  ; R3: Itterator
MOV R5, #0
SVC svc_3     ;get buttons into R0
ABCDloop             ;for(int i=1; i < 16; i**2)
AND R6, R0, R3
CMP R6, R3
BEQ buttonFound

ADD R3, R5, R3, LSL #1
CMP R3, #16
BNE ABCDloop
BEQ checkKeypad

buttonFound ; change operator
CMP R6, #1
MOVEQ R7, #1
CMP R6, #2
MOVEQ R7, #2
CMP R6, #4
MOVEQ R7, #3
CMP R6, #8
MOVEQ R7, #4
STRB R7, operator
MOV R0, R7
BL setOperator

MOV  R0, #1
STRB R0, curstate ; move state
MOV  R0, #1
STRB R0, curline

waitForABCDreset         ;check ABCD keys
SVC svc_3
CMP R0, #0
BNE waitForABCDreset


checkKeypad
MOV R3, #0
scanKeyInner
LDRB R4, [R2, R3] ; load value of keypresses[itterator]
CMP R4, #threshold ; if less than threshold
BLT continueScan   ;    increment counter and keep scanning




MOV R0, R3          ;   (Body of key press)
BL convertIndexToValue  ; get value of key into R0
CMP R0, #254            ; special char (hash)
BEQ hash
CMP R0, #255            ; special char (star)
BEQ star
MOV R1, R0              ; if not special, prep input and push char
LDRB R0, curline
BL pushNewChar
B waitForReset
; key press detected, wait for it to unpress before checking more keys
hash          ;equals button
LDRB R8, curstate
CMP R8, #STATE2
BNE skipStateChange
LDRB R8, operator     ;switch statement to calculate result of operator

CMP R8, #C_plus
BNE checkForMinus           ; for each of these four blocks
BL getNums                  ; convert the operator to 32 bit binary
MOV R3, #0                  ; do the operation
STRB R3, table2sign         ; convert back
BL runAdd
B outputNums

checkForMinus
CMP R8, #C_minus
BNE checkForMult
BL getNums
BL runSub
B outputNums

checkForMult
CMP R8, #C_multiply
BNE checkForDiv
BL getNums
BL runMul
B outputNums

checkForDiv
CMP R8, #C_divide
BNE endOfOperatorChecks
BL getNums
BL runDiv
B outputNums


endOfOperatorChecks
skipStateChange
B waitForReset

star                        ;logic to clear the table
LDRB R0, curline
BL convertTableToNum
CMP R0, #0
BEQ usercode ;hard reset
LDRB R0, curline
BL clearTable
BL printline

waitForReset       ; this is used to ensure only one transition is taken at once
LDRB R4, [R2, R3]  ; keep reloading the value of keypresses[itterator]
CMP R4, #0         ; wait until it is 0
BNE waitForReset

                      ;(end of body of key press)
continueScan
ADD R3, R3, #1
CMP R3, #12
BEQ scanKeyStart
B scanKeyInner

getNums
;only used as a method to reuse code, should not be called outside of the check functions
PUSH {LR}
MOV R0, #1
BL convertTableToNum
MOV R1, R0
MOV R0, #0
BL convertTableToNum
;at this point opA in R0, opB in R1
POP {LR}
MOV PC, LR

outputNums
;only used as a method to reuse code, should not be called outside of the check functions
MOV R1, #0
BL convertNumToTable
MOV R0, #0
BL printline
MOV R0, #1
BL clearTable
BL printline
B waitForReset



ALIGN
keyvalues
DEFB 3
DEFB 6
DEFB 9
DEFB 254 ; hash
DEFB 2
DEFB 5
DEFB 8
DEFB 0
DEFB 1
DEFB 4
DEFB 7
DEFB 255 ; star

STATE1 EQU 0
STATE2 EQU 1

curstate DEFB 0
curline  DEFB 0
operator DEFB 0
return DEFB &0D, 0 ;CR CHAR
blank DEFB &09, 0 ;HT CHAR
hardblank DEFB 32,0
printbit DEFB 0
printbitend DEFB 0 ; printstr used so i can use cursor control also
; table to contain numbers of first row
; max num is 8 digits
threshold  EQU 4
table_nums EQU 1
table_size EQU 8
table_bases ;most significant digit first
ALIGN
DEFS 8
table_num2
DEFS 8
table1sign DEFB 0 ;positive by default
table2sign DEFB 0 ;positive by default
ALIGN
;start of calculator_arith.s

loadSigns
LDRB R2, table1sign
LDRB R3, table2sign
MOV PC, LR



;all runXXX functions here take opA in R0 opB in R1
; RULES FOR SIGN AND MAGNITUDE ARITHMETIC
; for C = A op B
;
; Addition
; if(signA == signB):
;   signC = signA
; else:
;   c = largest(A,B) - smallest(A,B)
;   signC = sign(largest(A,B))
;
; Subtraction
; signB = -signB
; then compute C = A + B
;
; Multiplication
; if signA == signB:
;   signC = +
; else
;   signC = -
; C = A x B
;
; Division
; same sign rules as multiplication
; C = A / B
;
;
;
;


multDivLogic
CMP R2, R3
MOVEQ R4, #0
MOVNE R4, #1
STRB R4, table1sign
MOV PC, LR


runAdd ;returns result to R0
PUSH {LR}
PUSH {R2 - R12}
BL loadSigns
CMP R2, R3
BNE resolveAdditionSign
;sign for table will remain the same
ADD R0, R0, R1
B endRunAdd

resolveAdditionSign
CMP R0, R1
SUBGE R0, R0, R1 ;opA is largest
SUBLT R0, R1, R0 ;opB is largest
;set signA to sign(largest(A,B))
MOVGE R4, R2
MOVLT R4, R3
STRB R4, table1sign ;move correct sign to R4, then write to table1

endRunAdd
POP  {R2 - R12}
POP  {LR}
MOV  PC, LR


runSub ;returns result to R0
PUSH {LR}
PUSH {R2 - R12}
BL loadSigns
MOV R3, #1 ;I forgot when designing the sign logic, the sign of opB cannot be negative unless sub is used
           ; thankfully this somewhat simplifes the logic, as I dont need to flip the sign, just set it6
STRB R3, table2sign
BL runAdd
POP  {R2 - R12}
POP  {LR}
MOV  PC, LR

runMul ;returns result to R0
PUSH {LR}
PUSH {R2 - R12}
BL loadSigns
MOV R3, #0
BL multDivLogic
MUL R0, R0, R1
POP  {R2 - R12}
POP  {LR}
MOV  PC, LR

runDiv ;returns result to R0
PUSH {LR}
PUSH {R2-R12}
BL loadSigns
MOV R3, #0
BL multDivLogic
BL unsignedIntegerDivision
POP  {R2 - R12}
POP  {LR}
MOV  PC, LR

unsignedIntegerDivision
;cannot corrupt R0-4
CMP R1, #0 ;check for divison by zero
MOVEQ R0, #0
BEQ skipDivision
MOV R5, #0 ;counter
MOV R6, R0
divLoop
SUB R6, R6, R1
ADD R5, R5, #1
CMP R6, #0
BGE divLoop
SUB R0, R5, #1
skipDivision
MOV PC, LR

;end of calculator_arith.s
;start of calculator_supporting.s
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

;end of calculator_supporting.s
INCLUDE ../general/bcdconvert.s ;not provided again, see project folder if intrested
INCLUDE ../general/hexprint.s ;not provided again, see project folder if intrested
INCLUDE ../general/lcd.s ;not provided again, see project folder if intrested
