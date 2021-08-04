
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
