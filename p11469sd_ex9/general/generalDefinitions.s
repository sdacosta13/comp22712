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
