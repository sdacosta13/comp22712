INCLUDE ../general/os.s
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
INCLUDE calculator_arith.s
INCLUDE calculator_supporting.s
INCLUDE ../general/bcdconvert.s
INCLUDE ../general/hexprint.s
INCLUDE ../general/lcd.s
