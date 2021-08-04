;###############################################
;# Written By: Sam da Costa                    #
;# Uni ID: p11469sd                            #
;# Exercise:  7                                #
;# Purpose: This file contains a test script to#
;# print characters to the screen when they are#
;# pressed on the keypad. It should be noted   #
;# most of the functionality required is in the#
;# IRQ_handler                                 #
;# This program just reads my keymap and checks#
;# for pressed keys                            #
;###############################################
INCLUDE ../general/os.s
usercode
ADRL R1, keypresses
MOV  R2, #-1
ADRL R4, asciikeycodes
startScanning
CMP R2, #12
BEQ usercode
ADD  R2, R2, #1
LDRB R3, [R1, R2]
CMP R3, #4 ;threshold for keypress
BLE startScanning
ADD R0, R4, R2, LSL #2
BL printstr
CMP R2, #12
BEQ usercode
B startScanning
asciikeycodes
DEFB &0D,"3 ",0 ;space included so i can LSL 2 instead of MUL by 3
DEFB &0D,"6 ",0 ;a bit hacky but easier to implement for a basic test rig
DEFB &0D,"9 ",0
DEFB &0D,"# ",0
DEFB &0D,"2 ",0
DEFB &0D,"5 ",0
DEFB &0D,"8 ",0
DEFB &0D,"0 ",0
DEFB &0D,"1 ",0
DEFB &0D,"4 ",0
DEFB &0D,"7 ",0
DEFB &0D,"* ",0
ALIGN
INCLUDE ../general/bcdconvert.s
INCLUDE ../general/hexprint.s
INCLUDE ../general/lcd.s
