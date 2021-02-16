
; program below is for changing bit {R0}, of the byte stored at the address in {R1}



  MOV R0, #0
  ADR R1, wordtochange
  BL changebit
  MOV R0, #1
  ADR R1, wordtochange
  BL changebit

SVC 2
changebit
  PUSH {R2, R3, R4} ;setup
  LDRB R2, [R1] ;load the parameter to R2
  ADR R4, m_bit
  LDRB R3, [R4, R0] ;select bitmask
  EOR  R3, R3, R2
  STRB R2, [R1]
  POP {R2, R3, R4}
  MOV PC, LR

m_bit   DEFB &01
        DEFB &02
        DEFB &04
        DEFB &08
        DEFB &10
        DEFB &20
        DEFB &40
        DEFB &80

wordtochange DEFW &00
