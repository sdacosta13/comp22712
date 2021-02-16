BL lcd_blank
svc 2


lcd_blank
PUSH{R0 - R2}
LDR R0, addr_LCD
LDR R1, addr_LCD_end
LDRB R2, BLACK

fill
STRB R2, [R0], #1
CMP R0, R1
BNE fill
STRB R2, [R0]

POP{R0 - R12}
MOV PC, LR

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
LCD_length      DEFW 240
WHITE           EQU     &00
BLACK           EQU     &FF
FONT_WIDTH      EQU     7
FONT_HEIGHT     EQU     8
