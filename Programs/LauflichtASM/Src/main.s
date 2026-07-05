;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf  
;* Version            : V1.0
;* Date               : 16.05.2022
;* Modified by        : Thomas Lehmann, 2024-07-12
;* Description        : This is the frame for the last assignment.
;                     : Einfaches Lauflicht.
;
;*******************************************************************************
    EXTERN initITSboard
    EXTERN lcdPrintS            ;Display ausgabe
    EXTERN GUI_init
    EXTERN TP_Init
    EXTERN delay
        
; Define address of selected GPIO and Timer registers
PERIPH_BASE         equ 0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE     equ (PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE          equ (AHB1PERIPH_BASE + 0x0C00)
GPIOE_BASE          equ (AHB1PERIPH_BASE + 0x1000)
GPIOF_BASE          equ (AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)

GPIO_F_PIN          equ (GPIOF_BASE + 0x10)

GPIO_D_PIN          equ (GPIOD_BASE + 0x10)
GPIO_D_SET          equ (GPIOD_BASE + 0x18)
GPIO_D_CLR          equ (GPIOD_BASE + 0x1A) 
    
GPIO_E_PIN          equ (GPIOE_BASE + 0x10)
GPIO_E_SET          equ (GPIOE_BASE + 0x18)
GPIO_E_CLR          equ (GPIOE_BASE + 0x1A)     



;********************************************
; Data section, aligned on 4-byte boundery
;********************************************   
    AREA MyData, DATA, align = 2
TestPattern DCW     0x8000, 0x7000, 0x5000

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; LEDS_ON
; 	schaltet die LEDs D23 bis D8 entsprechend 
; 	dem in r0 übergebenen 16 Bit-Muster an
;
; 	input	r0 	
;				= 16 Bit-Muster
;--------------------------------------------

LEDS_ON		PROC

	push {r4, r5, lr}

	ldr r4, =GPIO_D_CLR						; lösche alle LEDs
	mov r5, #0xffff
	str r5, [r4]

	ldr r4, =GPIO_E_CLR
	str r5, [r4]


	ldr r4, =GPIO_D_SET						; unteren 8 Bit anschalten
	strb r0, [r4]

	lsr r0, #8								; oberen 8 Bit anschalten
	ldr r4, =GPIO_E_SET
	strb r0, [r4]


	pop {r4, r5, pc}
			ENDP

;--------------------------------------------
; SHIFT_PATTERN
; 	rotiert ein Bitmuster auf den unteren 16 Bit
; 	
; input 	r0
; 				= 16-Bit langes Bitmuster
; 		
; ouput 	r0
;				= rotiertes Bitmuster
;--------------------------------------------

SHIFT_PATTERN		PROC

	push {r4, r5, lr}

	LSRS r0, #1								; schiebe rechts 1 Bit heraus auf das Carry-Bit

	MOV r4, #0								; ließ das Carry-Bit aus
	ADC r4, #0

	ORR r0, r4, LSL #15						; füge das Carry-Bit an der 15. Bitstelle wieder ein

	pop {r4, r5, pc}
			ENDP
			
;--------------------------------------------
; LAUFLICHT
;--------------------------------------------       
; Unterprogramm Lauftlicht
;
; Einfaches Lauflicht, das ein Bitmuster zyklisch ueber die 
; LEDs D23 bis D8 schiebt. Das LED Muster wird nach rechts 
; geschoben. Die Frequenz betraegt 2 Hz.
;
; IN R0  Die unteren 16 Bits von R0 speichern das Muster, mit
;        dem die LEDs initialisiert werden.
; IN R1  Anzahl Schritte, die das Lauflicht laufen soll.
;--------------------------------------------       


DelayTime   EQU     500
STARTWERT 	EQU		0

Lauflicht   PROC
	push {r4-r8, lr}

for_01
	mov r6, #STARTWERT

until_01
	cmp r6, r1								; r6 = Laufvariable, r1 = Anzahl Schritte, die gegangen werden soll = Abbruchbedingung
	bls		do_01
	b 		enddo_01

do_01

	mov r4, r0								; inputs saven
	mov r5, r1

	bl LEDS_ON

	mov r0, r4								; input setzen für SHIFT_PATTERN
	bl SHIFT_PATTERN
	mov r4, r0								; output saven

	mov r0, #DelayTime
	bl delay

	mov r0, r4								; Input für nächsten Schleifendurchlauf zurückholen
	mov r1, r5

step_01
	add r6, #1							
	b 	until_01							

enddo_01							

	pop {r4-r8, pc}          
            ENDP

;--------------------------------------------
; main subroutine
;--------------------------------------------
    EXPORT main [CODE]
        
InterTestDelay  EQU     4000
    
main    PROC
        BL initITSboard
        LDR     R7, =TestPattern
        MOV     R8, #0                  		; Laufindex Testpattern
forever 
        CMP     R8, #3
        MOVGE   R8, #0							; wenn alle 3 Testpattern durchlaufen wurden, fange wieder beim 1. an.
        
        ; Test Lauflicht
        LDRH    R0, [R7,R8,LSL #1]				; lade 16 Bit in R0, aus Adresse TestPattern plus offset: das was in r8 steht * 2. In
												; in r8 steht: 0, 1 oder 2. 
												; *2 (also LSL #1, weil: normalerweise ist ein Schritt in einer Adresse weiter = 1 Byte. 
												; Da die Einträge von TestPattern aber 16 Bit lang sind, genau so, wie die Muster für die 16 LEDS, entspricht das 2 Byte.
        MOV     R1, #20
        BL      Lauflicht
        
        LDR     R0, =InterTestDelay
        BL      delay

        ADD     R8, #1							; wenn das eine Testpattern durchlaufen wurde, laufe das nächste durch.
        BAL     forever     					; nowhere to return if main ends     
        ENDP
    
        ALIGN
        END
