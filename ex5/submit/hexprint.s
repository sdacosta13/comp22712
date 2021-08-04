
; Num to print in R0
hexprint ; prints half a word
PUSH {R1 - R2}
MOV R2, #0 ;used for rotating
ADD R0, R2, R0, ROR #12
PUSH {LR}
BL hexprint_sub
ADD R0, R2, R0, ROR #28 ;not space efficient, but using a loop would increase processing time and waste a register
BL hexprint_sub
ADD R0, R2, R0, ROR #28
BL hexprint_sub
ADD R0, R2, R0, ROR #28
BL hexprint_sub
POP {LR}
POP{R1 - R2}
MOV PC, LR


hexprint_sub ; only corrupts then restores R1
PUSH {R1}
MOV R1, R0 ; save R0
AND R0, R0, #&0000000F ;clear unused bits
CMP R0, #9
ADDGT R0, R0, #55 ;offset to get character
ADDLE R0, R0, #48 ;offset to get character
;I realise now that my printc function doesnt work exactly as I thought it would
;For it to work correctly it needs to be run within printstr i think
;The following code is a work around so that I can use printstr instead as printstr works correctly
;It stores it to a location with a null 0 in the next byte so it can be read as a null terminated string
;I would fix my printc function, but I am running out of time
STRB R0, tempCharPos
ADRL R0, tempCharPos
PUSH {LR}
SVC svc_1
POP {LR}

MOV R0, R1
POP {R1}
MOV PC, LR

tempCharPos DEFB 0
nullchar DEFB 0
