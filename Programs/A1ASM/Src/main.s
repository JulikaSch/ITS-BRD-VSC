;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to setup three LEDs
;                     :
;                     :
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board

    EXPORT main         ; we need this for the linker
                        ;- In this context it set the entry point,too

; setup the peripherie - Mapping the GPIO
PERIPH_BASE         equ 0x40000000
AHB1PERIPH_BASE     equ (PERIPH_BASE + 0x00020000)
GPIOD_BASE          equ (AHB1PERIPH_BASE + 0x0C00)
    
GPIO_D_SET          equ (GPIOD_BASE + 0x18)
GPIO_D_CLR          equ (GPIOD_BASE + 0x1A)
    

;* We need minimal memory setup of InRootSection placed in Code Section
    AREA  |.text|, CODE, READONLY, ALIGN = 3
    ALIGN
main
    BL initITSboard             ; needed by the board to setup
    nop                         ; no operation
    LDR     R6, =GPIO_D_SET     ; get address of the GPIO data set register
    LDR     R7, =GPIO_D_CLR     ; get address of the GPIO data clear register
    ;MOV     R0, #0x01           ; load mask 0b0001
    ;MOV     R1, #0x02           ; load mask 0b0010
    ;MOV     R2, #0x40           ; load mask 0b0100
    ;MOV     R3, #0x80           ; load mask 0b1000
    MOV     R4, #0x03

    ; Set LED
    STRB    R4, [R6] 
    ;STRB    R2, [R6]    ; switch on LED D14
    ;STRB    R3, [R6]    ; switch on LED D15 = 0x80
    ;STRB    R0, [R6]    ; switch on LED D08
    ;STRB    R0, [R7]    ; switch off LED D08
    ;STRB    R0, [R6]    ; switch on LED D08 = 0x01
    ;STRB    R1, [R6]    ; switch on LED D09
    ;STRB    R2, [R7]    ; switch off LED D14
    ;STRB    R3, [R7]    ; switch off LED D15
       
    b .
    
    ALIGN
    END
