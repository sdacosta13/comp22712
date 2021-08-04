ORIGIN &00000000
B reset_handler                       ; +0   (00)
B undefined_instruction_handler       ; +4   (04)
B svc_handler                         ; +8   (08)
B prefetch_abort_handler              ; +12  (0C)
B data_abort                          ; +16  (10)
NOP                                   ; +20  (14)
B IRQ_handler                         ; +24  (18)
B FIQ_handler                         ; +28  (1C)
SVC_MAX DEFW &00000103
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
ADRL SP, stackend_svc
ADRL R0, FF
BL printstr   ;blanks screen and resets cursorposx and cursorposy
MRS  R0, CPSR
BIC  R0, R0, #&0F
MSR CPSR_c, R0
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
DEFW SVC_2
DEFW SVC_3
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
SVC_2 ;move timer into R0
PUSH {R1 - R5}
LDR R1, addr_timer
LDRB R0, [R1]
POP{R1 - R5}
MOVS PC, LR

SVC_3
prefetch_abort_handler
ADRL R0, CR
BL printstr
ADRL R0, LF
BL printstr
ADRL R0, MemoryError_pre
BL printstr
B halt

data_abort
ADRL R0, CR
BL printstr
ADRL R0, LF
BL printstr
ADRL R0, MemoryError_dat
BL printstr
B halt

IRQ_handler
B halt

FIQ_handler
B halt

halt
MOV R0, R0
B halt
ALIGN
stack_user DEFS &1000
stackend_user
stack_svc DEFS &1000
stackend_svc
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
