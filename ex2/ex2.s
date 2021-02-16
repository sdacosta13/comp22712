
          LDR R5, addr_CTRL
          LDR R6, addr_LED
          LDRB R2, bmask1
          LDRB R3, bmask5
          EOR  R2, R2, R3
          STRB R2, [R5]
          LDRB R0, H
          STRB R0, [R6]
          LDRB R1, [R6]
          LDRB R4, bmask0
          EOR  R4, R4, R1
          STRB R4, [R6]
          STRB R1, [R6]
          SVC 2


          ALIGN

          addr_LED    DEFW 0xAC03_8400 ; address of LEDS
          addr_CTRL   DEFW 0xAC03_8401
          addr_but    DEFW 0xF100_3000
          ALIGN
          ; masks used to flip the nth bit of a byte
          bmask0      DEFB &01
          bmask1      DEFB &02
          bmask2      DEFB &04
          bmask3      DEFB &08
          bmask4      DEFB &10
          bmask5      DEFB &20
          bmask6      DEFB &40
          bmask7      DEFB &80
          H           DEFB &48
          ALIGN
