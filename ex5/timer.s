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
INCLUDE ../general/os.s
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

INCLUDE ../general/bcdconvert.s
INCLUDE ../general/hexprint.s
INCLUDE ../general/lcd.s
