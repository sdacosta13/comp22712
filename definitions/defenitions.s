
addr_LED    EQU 0xAC03_8400 ; address of LEDS
addr_CTRL   EQU 0xAC03_8401

; masks used to flip the nth bit of a byte
bmask0      EQU #&01
bmask1      EQU #&02
bmask2      EQU #&04
bmask3      EQU #&08
bmask4      EQU #&10
bmask5      EQU #&20
bmask6      EQU #&40
bmask7      EQU #&80
