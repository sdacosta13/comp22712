

addr_LCD DEFW 0xAC03_8400
zero     DEFW 0
one      DEFW 1

start
      LDR R0, addr_LCD ;load lcd postion
      LDR R1, one      ;load starting bit mask
      LDR R4, zero
bitstart
      LDRB R2, [R0] ; get currnet LCD value into R2
      EOR R2, R2, R1 ; XOR LCD with current working value
      STRB R2, [R0] ; write LCD back to address
      ADD R1, R4, R1, LSL #1 ; rotate working value left
      B bitstart

      ;STRB R1, [R0]
      SVC   2
