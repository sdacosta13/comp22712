




init ;initalisation of registers
      LDR   R0, zero
      LDR   R1, addr_LED
      STRB  R0, [R1] ; clear LEDS
      MOV   R3, #0 ; value for leds
      LDR   R2, s_start ; inital setup
      EOR   R3, R3, R2
      STRB  R3, [R1]
      MOV   R4, #0 ; inital timer
      LDR   R5, timer
start ;progresing throught states by XOR with the change needed
      LDR   R2, s_1
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start

      LDR   R2, s_2
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start
      BL t_start
      BL t_start

      LDR   R2, s_3
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start


      LDR   R2, s_4
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start

      LDR   R2, s_5
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start

      LDR   R2, s_6
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start
      BL t_start
      BL t_start

      LDR   R2, s_7
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start


      LDR   R2, s_8
      EOR   R3, R3, R2
      STRB  R3, [R1]
      BL t_start
      B start

end
      SVC 2

t_start
      ADD R4, R4, #1
      CMP R4, R5 ; compare timer
      BNE t_start
      MOV R4, #0
      MOV PC, LR
t_end


addr_LED DEFW 0xAC03_8400
zero     DEFW 0
one      DEFW 1
timer    DEFW 800000
s_start  DEFB 0x44
s_1      DEFB 0x20
s_2      DEFB 0x70
s_3      DEFB 0x30
s_4      DEFB 0x60
s_5      DEFB 0x02
s_6      DEFB 0x07
s_7      DEFB 0x03
s_8      DEFB 0x06
