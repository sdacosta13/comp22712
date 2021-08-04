;############################################
;# Written By: Sam da Costa                 #
;# Uni ID: p11469sd                         #
;# Exercise:  5                             #
;# Purpose: This file demos a timer         #
;# Known faults:                            #
;# Buttons arent tested during writing to   #
;# the LCD. There isnt much I can do about  #
;# this until I can use interrupts. I have  #
;# tried to minimise some of the overhead   #
;# for printing characters to help with this#
;############################################
; the general strategy of this timer is to increment memory every time the timer passes another hundred
; this means i can avoid dividing by incrementing the 'constant' 100 by 100 everytime and checking if the timer is over this value

;os.s starts
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
font_32 defb 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_33 defb 0x5f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_34 defb 0x03, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00
font_35 defb 0x14, 0x7f, 0x14, 0x7f, 0x14, 0x00, 0x00
font_36 defb 0x6f, 0x49, 0xc9, 0x7b, 0x00, 0x00, 0x00
font_37 defb 0x63, 0x13, 0x08, 0x64, 0x63, 0x00, 0x00
font_38 defb 0x7f, 0xc9, 0x49, 0x63, 0x00, 0x00, 0x00
font_39 defb 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_40 defb 0x3e, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00
font_41 defb 0x41, 0x3e, 0x00, 0x00, 0x00, 0x00, 0x00
font_42 defb 0x0a, 0x04, 0x1f, 0x04, 0x0a, 0x00, 0x00
font_43 defb 0x08, 0x08, 0x3e, 0x08, 0x08, 0x00, 0x00
font_44 defb 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_45 defb 0x08, 0x08, 0x08, 0x08, 0x00, 0x00, 0x00
font_46 defb 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_47 defb 0x60, 0x10, 0x08, 0x04, 0x03, 0x00, 0x00
font_48 defb 0x7f, 0x41, 0x41, 0x7f, 0x00, 0x00, 0x00
font_49 defb 0x01, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00
font_50 defb 0x7b, 0x49, 0x49, 0x6f, 0x00, 0x00, 0x00
font_51 defb 0x63, 0x49, 0x49, 0x7f, 0x00, 0x00, 0x00
font_52 defb 0x0f, 0x08, 0x08, 0x7f, 0x00, 0x00, 0x00
font_53 defb 0x6f, 0x49, 0x49, 0x7b, 0x00, 0x00, 0x00
font_54 defb 0x7f, 0x49, 0x49, 0x7b, 0x00, 0x00, 0x00
font_55 defb 0x03, 0x01, 0x01, 0x7f, 0x00, 0x00, 0x00
font_56 defb 0x7f, 0x49, 0x49, 0x7f, 0x00, 0x00, 0x00
font_57 defb 0x0f, 0x09, 0x09, 0x7f, 0x00, 0x00, 0x00
font_58 defb 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_59 defb 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_60 defb 0x08, 0x14, 0x22, 0x00, 0x00, 0x00, 0x00
font_61 defb 0x14, 0x14, 0x14, 0x14, 0x00, 0x00, 0x00
font_62 defb 0x22, 0x14, 0x08, 0x00, 0x00, 0x00, 0x00
font_63 defb 0x03, 0x59, 0x09, 0x0f, 0x00, 0x00, 0x00
font_64 defb 0x7f, 0x41, 0x5d, 0x55, 0x5f, 0x00, 0x00
font_65 defb 0x7f, 0x09, 0x09, 0x7f, 0x00, 0x00, 0x00
font_66 defb 0x7f, 0x49, 0x49, 0x77, 0x00, 0x00, 0x00
font_67 defb 0x7f, 0x41, 0x41, 0x63, 0x00, 0x00, 0x00
font_68 defb 0x7f, 0x41, 0x41, 0x3e, 0x00, 0x00, 0x00
font_69 defb 0x7f, 0x49, 0x49, 0x63, 0x00, 0x00, 0x00
font_70 defb 0x7f, 0x09, 0x09, 0x03, 0x00, 0x00, 0x00
font_71 defb 0x7f, 0x41, 0x49, 0x7b, 0x00, 0x00, 0x00
font_72 defb 0x7f, 0x08, 0x08, 0x7f, 0x00, 0x00, 0x00
font_73 defb 0x41, 0x7f, 0x41, 0x00, 0x00, 0x00, 0x00
font_74 defb 0x60, 0x40, 0x40, 0x7f, 0x00, 0x00, 0x00
font_75 defb 0x7f, 0x08, 0x08, 0x77, 0x00, 0x00, 0x00
font_76 defb 0x7f, 0x40, 0x40, 0x60, 0x00, 0x00, 0x00
font_77 defb 0x7f, 0x01, 0x01, 0x7f, 0x01, 0x01, 0x7f
font_78 defb 0x7f, 0x01, 0x01, 0x7f, 0x00, 0x00, 0x00
font_79 defb 0x7f, 0x41, 0x41, 0x7f, 0x00, 0x00, 0x00
font_80 defb 0x7f, 0x09, 0x09, 0x0f, 0x00, 0x00, 0x00
font_81 defb 0x7f, 0x41, 0xc1, 0x7f, 0x00, 0x00, 0x00
font_82 defb 0x7f, 0x09, 0x09, 0x77, 0x00, 0x00, 0x00
font_83 defb 0x6f, 0x49, 0x49, 0x7b, 0x00, 0x00, 0x00
font_84 defb 0x01, 0x01, 0x7f, 0x01, 0x01, 0x00, 0x00
font_85 defb 0x7f, 0x40, 0x40, 0x7f, 0x00, 0x00, 0x00
font_86 defb 0x7f, 0x20, 0x10, 0x0f, 0x00, 0x00, 0x00
font_87 defb 0x7f, 0x40, 0x40, 0x7f, 0x40, 0x40, 0x7f
font_88 defb 0x77, 0x08, 0x08, 0x77, 0x00, 0x00, 0x00
font_89 defb 0x6f, 0x48, 0x48, 0x7f, 0x00, 0x00, 0x00
font_90 defb 0x71, 0x49, 0x49, 0x47, 0x00, 0x00, 0x00
font_91 defb 0x7f, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00
font_92 defb 0x03, 0x04, 0x08, 0x10, 0x60, 0x00, 0x00
font_93 defb 0x41, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00
font_94 defb 0x04, 0x02, 0x01, 0x02, 0x04, 0x00, 0x00
font_95 defb 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00
font_96 defb 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_97 defb 0x74, 0x54, 0x54, 0x7c, 0x00, 0x00, 0x00
font_98 defb 0x7f, 0x44, 0x44, 0x7c, 0x00, 0x00, 0x00
font_99 defb 0x7c, 0x44, 0x44, 0x6c, 0x00, 0x00, 0x00
font_100 defb 0x7c, 0x44, 0x44, 0x7f, 0x00, 0x00, 0x00
font_101 defb 0x7c, 0x54, 0x54, 0x5c, 0x00, 0x00, 0x00
font_102 defb 0x7f, 0x05, 0x05, 0x01, 0x00, 0x00, 0x00
font_103 defb 0xbc, 0xa4, 0xa4, 0xfc, 0x00, 0x00, 0x00
font_104 defb 0x7f, 0x04, 0x04, 0x7c, 0x00, 0x00, 0x00
font_105 defb 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_106 defb 0x80, 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00
font_107 defb 0x7f, 0x04, 0x04, 0x7a, 0x00, 0x00, 0x00
font_108 defb 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_109 defb 0x7c, 0x04, 0x04, 0x7c, 0x04, 0x04, 0x7c
font_110 defb 0x7c, 0x04, 0x04, 0x7c, 0x00, 0x00, 0x00
font_111 defb 0x7c, 0x44, 0x44, 0x7c, 0x00, 0x00, 0x00
font_112 defb 0xfc, 0x44, 0x44, 0x7c, 0x00, 0x00, 0x00
font_113 defb 0x7c, 0x44, 0x44, 0xfc, 0x00, 0x00, 0x00
font_114 defb 0x7c, 0x04, 0x04, 0x0c, 0x00, 0x00, 0x00
font_115 defb 0x5c, 0x54, 0x54, 0x74, 0x00, 0x00, 0x00
font_116 defb 0x7f, 0x44, 0x44, 0x60, 0x00, 0x00, 0x00
font_117 defb 0x7c, 0x40, 0x40, 0x7c, 0x00, 0x00, 0x00
font_118 defb 0x7c, 0x20, 0x10, 0x0c, 0x00, 0x00, 0x00
font_119 defb 0x7c, 0x40, 0x40, 0x7c, 0x40, 0x40, 0x7c
font_120 defb 0x6c, 0x10, 0x10, 0x6c, 0x00, 0x00, 0x00
font_121 defb 0xbc, 0xa0, 0xa0, 0xfc, 0x00, 0x00, 0x00
font_122 defb 0x64, 0x54, 0x54, 0x4c, 0x00, 0x00, 0x00
font_123 defb 0x08, 0x3e, 0x41, 0x00, 0x00, 0x00, 0x00
font_124 defb 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
font_125 defb 0x41, 0x3e, 0x08, 0x00, 0x00, 0x00, 0x00
font_126 defb 0x1c, 0x04, 0x1c, 0x10, 0x1c, 0x00, 0x00
ALIGN
bmask0      DEFB &01
bmask1      DEFB &02
bmask2      DEFB &04
bmask3      DEFB &08
bmask4      DEFB &10
bmask5      DEFB &20
bmask6      DEFB &40
bmask7      DEFB &80

addr_LCD        DEFW 0xAC00_0000
addr_LCD_end    DEFW 0xAC03_83FF
LCD_width       DEFW 960
charwidth       DEFW 24
LCD_linediff    DEFW 7680
WHITE           DEFW     &00
BLACK           DEFW     &FF
FONT_WIDTH      DEFW     7
FONT_HEIGHT     DEFW     8
nullstring      DEFB &00
backspace       DEFB &08,0
HT              DEFB &09,0
LF              DEFB &0A,0
VT              DEFB &0B,0
FF              DEFB &0C,0
CR              DEFB &0D,0
BLANK           DEFB &20,0
ALIGN
svc_0           EQU &100 ;halt
svc_1           EQU &101 ;printstr
svc_2           EQU &102 ;get timer
svc_3           EQU &103

ALIGN

usercode


MOV R0, #0
BL bcd_convert
BL hexprint
SVC svc_2
MOV R7, #0   ;pos A pushed at
MOV R6, #256 ; const
MOV R1, R0   ; R1 is my base to work from
MOV R2, #0   ; R2 is my count of overflows
MOV R3, #100 ; R3 holds the value my count should be higher than to increment the mem address
             ; everytime I write to Mem_Inc i should increment R3 by 100
MOV R4, #0   ; R4 is the current step = (R2 * 256) - R1
BL wait
SVC svc_2
loop
MOV R5, R0   ; R5 is my last timer var
;check for IO while R0 is free
SVC svc_3
AND R0, R0, #00000002
CMP R0, #00000002
BLEQ wait ;this probably wont detect every push of the button, but it is the best I can do using Polling
          ;with and interrupts, this would be much more accurate

; check if A still pushed if (R7 + 1000 > current time) and (R7 != 0)
; if not pushed R7 <= 0
; else set mem to 0
; if a pushed R7 <= R4
; (NOTE: I think this works, but I am unsure as the simulation runs too fast for me)
PUSH {R0}
CMP R7, #0
BEQ continue
ADD R7, R7, #1000
CMP R7, R4
SUB R7, R7, #1000
BLT continue

SVC svc_3
AND R0, R0, #00000001
CMP R0, #1
BNE endcountcheck
MOV R6, #0
STR R6, Mem_Inc

B continue
endcountcheck
MOV R7, #0

continue

SVC svc_3
AND R0, R0, #00000001
CMP R0, #1
MOVEQ R7, R4
POP {R0}
; End of psuedo code described in comment above


SVC svc_2
CMP R5, R0
BGE tests

overflow
ADD R2, R2, #1
tests
MOV R6, #256
MUL R4, R2, R6
SUB R4, R4, R1
ADD R4, R4, R0 ;current step in R4
CMP R2, R3     ;if R2 > R3 add to mem else keep checking
BLT loop
;increment mem
LDR R6, Mem_Inc
ADD R6, R6, #1
STR R6, Mem_Inc
ADD R3, R3, #100
;print memory location
PUSH {R0}
ADR R0, wipeline
SVC svc_1
MOV R0, R6
BL bcd_convert
BL hexprint
POP {R0}
B loop

wait ;you progress through this section once the button has been unpushed, pushed and then unpushed
PUSH {R0}
unpush
SVC svc_3
AND R0, R0, #00000002
CMP R0, #00000000
BNE unpush

waitloop
SVC svc_3
AND R0, R0, #00000002
CMP R0, #00000002
BNE waitloop
unpush2
SVC svc_3
AND R0, R0, #00000002
CMP R0, #00000000
BNE unpush2



POP {R0}
MOV PC, LR












ALIGN
APushed DEFB &00
ALIGN
APushedAt DEFW 0
Mem_Inc DEFW 0
wipeline DEFW &0D, 0 ; Move cursor to start

;Edited by Sam da Costa to avoid corruption of R1 - R6
;Edits are made in caps
;-------------------------------------------------------------------------------

; Convert unsigned binary value in R0 into BCD representation, returned in R0
; Any overflowing digits are generated, but not retained or returned in this
;  version.
; Corrupts registers R1-R6, inclusive; also R14
; Does not require a stack

bcd_convert
    PUSH {R1-R6}
    mov	r6, lr			; Keep return address
						;  in case there is no stack
		adr	r4, dec_table		; Point at conversion table
		mov	r5, #0			; Zero accumulator

bcd_loop	ldr	r1, [r4], #4		; Get next divisor, step pointer
		cmp	r1, #1			; Termination condition?
		beq	bcd_out			;  yes

		bl	divide			; R0 := R0/R1 (rem. R2)

		add	r5, r0, r5, lsl #4	; Accumulate result
		mov	r0, r2			; Recycle remainder
		b	bcd_loop		;

bcd_out		add	r0, r0, r5, lsl #4	; Accumulate result to output
    MOV LR, R6
    POP {R1-R6}
		mov	pc, LR			; Return
    ; was mov pc, r6
dec_table	DCD	1000000000, 100000000, 10000000, 1000000
		DCD	100000, 10000, 1000, 100, 10, 1

;-------------------------------------------------------------------------------

; 32-bit unsigned integer division R0/R1
; Returns quotient in R0 and remainder in R2
; R3 is corrupted (will be zero)
; Returns quotient FFFFFFFF in case of division by zero
; Does not require a stack

divide		mov	r2, #0			; AccH
		mov	r3, #32			; Number of bits in division
		adds	r0, r0, r0		; Shift dividend

divide1		adc	r2, r2, r2		; Shift AccH, carry into LSB
		cmp	r2, r1			; Will it go?
		subhs	r2, r2, r1		; If so, subtract
		adcs	r0, r0, r0		; Shift dividend & Acc. result
		sub	r3, r3, #1		; Loop count
		tst	r3, r3			; Leaves carry alone
		bne	divide1			; Repeat as required

		mov	pc, lr			; Return

;-------------------------------------------------------------------------------

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
