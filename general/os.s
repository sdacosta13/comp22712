ORIGIN &00000000
B reset_handler                       ; +0   (00)
B undefined_instruction_handler       ; +4   (04)
B svc_handler                         ; +8   (08)
B prefetch_abort_handler              ; +12  (0C)
B data_abort                          ; +16  (10)
NOP                                   ; +20  (14)
B IRQ_handler                         ; +24  (18)
B FIQ_handler                         ; +28  (1C)
SVC_MAX DEFW &00000104
reset_handler ; code to reset the proccesor to known state
MOV R0, #0
MOV R1, #0
MOV R2, #0
MOV R3, #0
MOV R4, #0
MOV R5, #0
MOV R6, #0
MOV R7, #0
MOV R8, #0
MOV R9, #0
MOV R10, #0
MOV R11, #0
MOV R12, #0
LDR  R1, addr_timer_compare
STR  R0, [R1]
LDR  R1, addr_timer_enable
LDR  R0, [R1]
BIC  R0, R0, #&01
ORR  R0, R0, #&01
STR  R0, [R1]

ADRL SP, stackend_svc
ADRL R0, FF
BL printstr   ;blanks screen and resets cursorposx and cursorposy
LDR  R1, addr_interrupts_mask
LDRB R0, [R1]
BIC  R0, R0, #&C1
ORR  R0, R0, #&C1
STRB R0, [R1]
MOV  R1, #0
MOV  R0, #0
MRS  R0, CPSR
BIC  R0, R0, #&0F
ORR  R0, R0, #&02
MSR  CPSR_c, R0
ADRL SP, stackend_IRQ
BIC  R0, R0, #&0F
BIC  R0, R0, #&C0 ; enable IRQ
MSR  CPSR_c, R0
MOV  R0, #0
ADRL SP, stackend_user

B usercode

; Jump to user code
undefined_instruction_handler
ADRL R0, UndefinedError
BL printstr
B halt

svc_handler
;svcs start at hex 100
PUSH {LR}
PUSH {R12}
LDR R14, [LR, #-4]
BIC R14, R14, #&FF000000
svc_entry
LDR R12, SVC_MAX
CMP R14, R12
BHI SVC_unknown
SUB R14, R14, #&100 ;normalising base to avoid predefined svcs
ADD R14, PC, R14, LSL #2
LDR PC, [R14, #0]

jump_t
DEFW SVC_0 ;halt
DEFW SVC_1 ;printstr
DEFW SVC_2 ;timer
DEFW SVC_3 ;buttons
DEFW SVC_4
; Move back to usercode
; MOVS PC, LR ; special case
SVC_0
SVC_unknown
B halt
SVC_1
BL printstr
POP{R12}
POP{LR}
MOVS PC, LR
B halt

addr_timer          DEFW 0xF1001010
addr_ABCDButtons    DEFW 0xF1003000
SVC_2 ;move timer into R0
PUSH {R1 - R5}
LDR R1, addr_timer
LDR R0, [R1] ; I know that this should be LDRB, however for some reason this causes a data abort
POP{R1 - R5}
POP {R12}
POP {LR}
MOVS PC, LR

SVC_3 ; move the ABCD buttons into R0
LDR R0, addr_ABCDButtons
LDR R0, [R0]
POP {R12}
POP {LR}
MOVS PC, LR
SVC_4
B halt

prefetch_abort_handler
B halt

data_abort
B halt


IRQ_handler
PUSH {R0 - R12}
LDR R0,  addr_interrupts
LDRB R1, [R0]
AND R2, R1, #&01
CMP R2, #01
BNE nextIRQ
;if timercompare do:
;   Poll keyboard

;poll keyboard pseduo code
; y = 0x20
; for(a = 0; a < 3; a++ ){
;   x = 0x01
;   for(b = 0; b < 4; b++ ){
;     write y to F1002004
;     temp = retrieve from F1002004
;     temp = temp and x
;     doinc()
;     x LSL 1
;   y LSL 1


; this should be able to account for multiple key keypresses
; i have no idea if it does as i cant test it, i only have 1 cursor
LDR R0, addr_keyboard_matrix
MOV R1, #&1F
STRB R1, [R0] ;set direction to out
;test line 7
ADD  R5, R0, #4     ;get address 0xF1002004
ADRL R0, keypresses ;address table to increment
MOV  R1, #&20       ;y starts at bit 5 active
MOV  R2, #0         ;counter a
MOV  R9, #0
aloop
MOV  R3, #&01       ;reset x
MOV  R4, #0         ;counter b
bloop
;main body
STRB R1, [R5]
LDRB R6, [R5] ; need to check this for keypresses
AND  R7, R6, R3
CMP  R7, R3 ;if the same then bit is high and increment needed
; the section that follows implements doinc()
; function doinc()
; if(increment needed):
;   read val stored
;   if( val != 255 ) store val + 1
; else:
;   read val stored
;   if( val != 0 ) store val -1

BEQ doinc
;dodec
LDRB  R8, [R0]
CMP   R8, #0
SUBNE R8, R8, #1
STRB  R8, [R0]
B skipinc
doinc
LDRB R8, [R0]
CMP R8, #32 ;max val
ADDNE R8, R8, #1
STRB R8, [R0]

skipinc ;doinc ends
ADD R0, R0, #1 ;lazily increment address, the table should be in the right order
ADD R3, R9, R3, LSL #1  ; x = x * 2

ADD R4, R4, #1 ;end bloop conditions
CMP R4, #4
BNE bloop
ADD R1, R9, R1, LSL #1  ; y = y * 2
ADD R2, R2, #1 ;end aloop conditions
CMP R2, #3
BNE aloop


;STRB R1, [R0]
nextIRQ
POP {R0 - R12}
SUBS PC, LR, #4 ;return to usercode

B halt


halt
MOV R0, R0
B halt
checkTable
DEFB 1
DEFB 2
DEFB 4
DEFB 8


addr_interrupts      DEFW 0xF2000000
addr_interrupts_mask DEFW 0xF2000001
addr_timer_compare   DEFW 0xF1001014
addr_timer_enable    DEFW 0xF100100C ;bit 0 = 1 means timer enabled
addr_keyboard_matrix DEFW 0xF1002000

keypresses
k_3    DEFB 0
k_6    DEFB 0
k_9    DEFB 0
k_hash DEFB 0
k_2    DEFB 0
k_5    DEFB 0
k_8    DEFB 0
k_0    DEFB 0
k_1    DEFB 0
k_4    DEFB 0
k_7    DEFB 0
k_star DEFB 0

data1 DEFW 0
wipeline DEFW &0D, 0
char0 DEFW &30, 0
char1 DEFW &31, 0


FIQ_handler
MOV R0, R0
B FIQ_handler ; not implemented


ALIGN
stack_user DEFS &2000
stackend_user
stack_svc DEFS &1000
stackend_svc
stack_IRQ
stackend_IRQ DEFS &1000
ALIGN
data
cursorposx      DEFW 0
cursorposy      DEFW 0
ALIGN
ALIGN
MemoryError_pre     DEFB "Memory Error has occured (Prefetch)",0
MemoryError_dat     DEFB "Memory Error has occured (Data)",0
ALIGN
UndefinedError  DEFB "Undefined Instruction encountered",0
ALIGN
INCLUDE characterDefinitions.s
INCLUDE generalDefinitions.s
ALIGN
