;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf, Julika Schanzenbacher
;* Version            : V1.0
;* Date               : 11.05.2022
;* Description        : Rahmen zur Loesung von GTP Woche 7-9 (Stoppuhr).
;
;*******************************************************************************

; Define address of selected GPIO and Timer registers
PERIPH_BASE     	equ	0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE 	equ	(PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE			equ	(AHB1PERIPH_BASE + 0x0C00)
GPIOF_BASE			equ	(AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)
	
GPIO_F_PIN        	equ	(GPIOF_BASE + 0x10)

GPIO_D_PIN			equ	(GPIOD_BASE + 0x10)
GPIO_D_SET			equ (GPIOD_BASE + 0x18)
GPIO_D_CLR			equ	(GPIOD_BASE + 0x1A)
	
TIMER				equ (TIM2_BASE + 0x24)   ; CNT : current time stamp (32 bit),  resolution
TIM2_PSC			equ (TIM2_BASE + 0x28)   ; Prescaler  resolution
TIM2_ERG			equ (TIM2_BASE + 0x14)   ; 16 Bit register, Bit 0 : 1 Restart Timer

; define state constants
INIT				equ 0x00
RUNNING				equ 0x01
HOLD				equ 0x11

    EXTERN initITSboard
    EXTERN GUI_init
	EXTERN TP_Init
	EXTERN initTimer
	EXTERN lcdSetFont
	EXTERN lcdGotoXY      		; TFT goto x y function
	EXTERN lcdPrintS			; TFT output function	
    EXTERN lcdPrintC            ; TFT output one character		
	EXTERN Delay				; Delay (ms) function

	EXPORT INIT
	EXPORT RUNNING
	EXPORT HOLD


;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	AREA MyData, DATA, align = 2

DEFAULT_BRIGHTNESS	DCW     800
timeStopped			DCB		"11:12.13", 0
state				DCB		0

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; OLDUpdateLEDS subroutine
; input r0: neues Bitmuster für LEDS. 1 = aus, 0 = an
; input r2: altes/ aktuelles Bitmuster
; output r2: updated Bitmuster
;--------------------------------------------
OLDUpdateLEDS	PROC
	push {r4-r8,lr}

	mov		r3,#0xff 				; reset LEDs
	LDR		R1,=GPIO_D_CLR
	str		R3,[R1]

	eor		r2, r0					; not xor = toggle die Bits über 0, die jetzt neu gedrückt werden
	mvn		r2, r2


	and 	r2,#0xff				; Bitmaske
	LDR		r1,=GPIO_D_SET
	str		R2,[R1]	

	pop {r4-r8, pc}
	ENDP


;--------------------------------------------
; LEDs ANSCHALTEN
; input r0 
;			= 0 -> ändert nichts
; 			= #1 -> schaltet nur D8 an (Rest bleibt unverändert)
;			= #2 -> schaltet nur D9 an (Rest bleibt unverändert)
; 			= #3 -> schaltet D8, D9 an
;			
;--------------------------------------------
LEDsOn	PROC
	push {r4-r8,lr}

	mov	r4, r0
	and r4, #3								; Bitmaske: 0000 00xx
	ldr r5, =GPIO_D_SET
	strh r4, [r5]

	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; LEDs AUSSCHALTEN
; input r0 
;			= 0 -> ändert nichts
; 			= #1 -> schaltet nur D8 aus (Rest bleibt unverändert)
;			= #2 -> schaltet nur D9 aus (Rest bleibt unverändert)
; 			= #3 -> schaltet D8, D9 aus (...) 
;			= #0xff -> schaltet alle aus (aktuell durch Bitmaske ausgestellt)
;			
;--------------------------------------------
LEDsOff	PROC
	push {r4-r8,lr}

	mov	r4, r0
	and r4, #3								; Bitmaske: 0000 00xx

	ldr r5, =GPIO_D_CLR
	strh r4, [r5]
	
	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; LEDs AUSLESEN
; return r0 
;			= 0 -> alle aus
; 			= #1 -> nur D8 an 
;			= #2 -> nur D9 an 
; 			= #3 -> D8, D9 an
;			...
; 			= #ff -> alle an (aktuell durch Bitmaske ausgestellt)
;--------------------------------------------
LEDsRead	PROC
	push {r4-r8,lr}

	
	ldr r5, =GPIO_D_PIN
	ldrh r0, [r5]

	and r0, #3								; Bitmaske: 0000 00xx
	
	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; updateLEDS
;			
; 	passt LEDs an aktuellen Zustand entsprechen der Variablen state an
;--------------------------------------------
updateLEDS	PROC
	push {r4-r8,lr}

	; vielleicht löschen gar nicht nötig?
	mov r0, #0xff
	bl LEDsOff								; alle LEDs aus

	ldr r4, =state
	ldrb r0, [r4]
	bl LEDsOn								; schaltet LEDs entsprechend dem state an
	
	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; Taster AUSLESEN
; return r1 
;			= 0 -> alle aus
; 			= #5 -> nur S5 an 
;			= #6 -> nur S6 an 
; 			= #7 -> nur S7 an
;
; return r0 
;			= #0x80 = 1000 0000 -> nur S7 an
; 			= #0x40 = 0100 0000 -> nur S6 an
; 			= #0x20 = 0010 0000 -> nur S5 an
; 				...
; 
; für alle Buttons: 
; 	r4 = #1 = 0000 0001
; 	for(int i=0; i<8; i++) ...
;
; alternativ nur für S5 bis S7: 
; 	r4 = #0x20 = 0010 0000
; 	for (int i=5, i<8; i++)
; 	{
;		if (r0 == r4)
; 			{return i, endfor}
; 		else
; 			{lsl r4, #1}
;	}
;--------------------------------------------
buttonsRead	PROC
	push {r4-r8,lr}

	ldr r4, =GPIO_F_PIN
	ldrh r0, [r4]
	mov r4, #0xff							; Bitmaske: 0000 0000 xxxx xxxx
	eor r0, r4								; 16 Bits invertieren -> 0 = Taster nicht gedrückt 1 = gedrückt
	and r0, r4								; Bitmaske: schneidet die oberen 16 Bit weg (=0)

for_button
	mov r5, #5								; HIER START AB 0, WENN ALLE TASTER. SONST ERST AB S5. Startvar. i = 0 (wenn alle Taster)
	mov r4, #1								; Bitmuster zum vgl ... 0000 0001
	lsl r4, #5								; WEGKOMMENTIEREN, WENN ALLE TASTER. SONST ERST AB S5
until_button
	cmp r5, #8								; for (i<8), Abbruch bei 
	bge enddo_button
do_button

; innere if-Bedingung: if( Taster r0 == r4 ): return i = r5, endfor. else: lsl r4, #1
if_button
	cmp	r0, r4
	beq then_button
	b 	else_button
then_button
	mov r1, r5								; return r1 = r5 = i 
	b enddo_button							; direkt äußere Schleife beenden
	;b endif_button
else_button
	lsl r4, #1								; Vgl.-Bitmuster um 1 Stelle nach links schieben
endif_button

step_button
	add r5, #1
	b until_button
enddo_button

	

	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; TEST-TFT-Display ansteuern
;--------------------------------------------
displayAnsteuern	PROC
	push {r4-r8,lr}

	;mov r0,#100								; r0 = X
	;mov r1,#50								; r1 = Y
	;bl lcdGotoXY

	ldr r0, =timeStopped
	bl lcdPrintS

	mov r0, #'#'
	bl lcdPrintC


	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]
	
main	PROC

		; Initialisierung der HW
		BL		initITSboard
		ldr   	r1, =DEFAULT_BRIGHTNESS
		ldrh 	r0, [r1]
		bl   	GUI_init
		bl  	initTimer
		ldr 	R1,=TIM2_PSC   			; Set pre scaler such that 1 timer tick represents 10 us
		mov 	R0,#(90*10-1) 
		strh	R0,[R1]
		ldr 	R1,=TIM2_ERG   			; Restart timer	
		mov		R0,#0x01
		strh	R0,[R1]					; Set UG Bit
		MOV 	R0, #24
		bl  	lcdSetFont

	; Demo Taster
		bl displayAnsteuern

	; Demo LEDs 
		mov r0, #3
		bl LEDsOn 
		bl LEDsRead

		mov r0, #0x1
		bl LEDsOff

	; Demo Buttons
		bl buttonsRead

	; Demo state und LEDs

		ldr r4, =state
		mov r5, #0x3					; state = HOLD
		strb r5, [r4]  				
		bl updateLEDS

		ALIGN
		END
