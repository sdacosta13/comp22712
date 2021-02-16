def_start
addr_LED    DEFW 0xAC03_8400 ; address of LEDS
addr_CTRL   DEFW 0xAC03_8401

; masks used to flip the nth bit of a byte
bmask0      DEFW &01
bmask1      DEFW &02
bmask2      DEFW &04
bmask3      DEFW &08
bmask4      DEFW &10
bmask5      DEFW &20
bmask6      DEFW &40
bmask7      DEFW &80
B start
