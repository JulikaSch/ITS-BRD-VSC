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
HOLD				equ 0x03

; define starting position for cursor
X_START 			equ 10
Y_START				equ 5

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
timeStringNew		DCB		"00:00.00", 0
puffer				DCB		0xff
timeStringDisplayed DCB		"00:00.00", 0
puffer2				DCB		0xff
initString 			DCB		"00:00.00", 0
state				DCB		INIT

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3



;--------------------------------------------
; LEDs ANSCHALTEN
; input r0 
;			= #0 -> schaltet alle aus
; 			= #1 -> schaltet nur D8 an (Rest bleibt unverändert)
;			= #2 -> schaltet nur D9 an (Rest bleibt unverändert)
; 			= #3 -> schaltet D8, D9 an
;			
;--------------------------------------------
LEDS_SET	PROC
	push {r4-r8,lr}

	
	ldr r5, =GPIO_D_CLR
	mov r6, #3
	strh r6, [r5]

	and r4, r0, #3								; Bitmaske: 0000 00xx

	ldr r5, =GPIO_D_SET
	strh r4, [r5]

	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; ASKBUTTON - Taster abfragen
; 
; 	gibt true oder false zurück, je nachdem, ob die übergebene
; 	Taste gedrückt wurde
;
; Input r0 
;			= 5, 6 oder 7
; output r0 
; 			= 1 = true
; 			= 0 = false
;--------------------------------------------
askButton	PROC
	push {r4-r8,lr}
									
	ldr r4, =GPIO_F_PIN
	ldr r4, [r4]
	
	;mov r5, #1, LSL r0						; warum geht dieser Befehl nicht?
	
	mov r5, #1
	lsl r5, r0								; r5 = Bitmaske 
	and r1, r4, r5							; mit Bitmakske nur das Bit des angefragten Tasters ausschneiden
	eor r1, r5								; einzelnes Bit invertieren: 1 = Taster gedrückt, 0 = nicht gedrückt
	lsr r0, r1, r0							; ausgelesenes Bit nach ganz rechts schieben

	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; CONVERT TIMER
; ohne Input / output
;--------------------------------------------
convertTime	PROC
	push {r4-r8,lr}

	ldr r4, =timeStringNew					; r4 = Basisadresse vom String
	ldr r5, =TIMER
	ldr r5, [r5]							; r5 = TIMER
											; r6 = wechselnd: Divisoren
											; r7 = wechselnd: zwischenergebnisse 
	; 10 Minuten:
	ldr r6, =60000000						
	udiv r7, r5, r6
	add r8, r7, #'0'
	strb r8, [r4]							; r10m =   tsr div 60.000.000                     	-> String +#0

	; 1 Minute:								;  r1m = (tsr mod 60.000.000) div 6.000.000		-> String +#1
	mls r7, r7, r6, r5						;	 		tsr mod 60.000.000
	ldr r6, =6000000
	udiv r7, r6								; 	 	 r7 / 6.000.000
	add r7, #'0'
	strb r7, [r4, #1]						; 		-> String +#1

	; 10 Sekunden:							; r10s = (tsr mod 6.000.000) div 1.000.000      -> String +#3
	udiv r7, r5, r6							; 			tsr mod 6.000.000
	mls r7, r7, r6, r5						
	ldr r6, =1000000
	udiv r7, r6								; 		r7 / 1.000.000
	add r7, #'0'
	strb r7, [r4, #3]						; 		-> String +#3

	; 1 Sekunde:							; r1s =    (tsr mod 1.000.000) div 100.000        -> String +#4
	udiv r7, r5, r6
	mls r7, r7, r6, r5
	ldr r6, =100000
	udiv r7, r6
	add r7, #'0'
	strb r7, [r4, #4]

	; 100 Millisekunden:					; r100ms = (tsr mod 100.000) div 10.000           -> String +#6
	udiv r7, r5, r6
	mls r7, r7, r6, r5
	ldr r6, =10000
	udiv r7, r6
	add r7, #'0'
	strb r7, [r4, #6]

	; 10 Millisekunden:						; r10ms =  (tsr mod 10.000) div 1.000             -> String +#7
	udiv r7, r5, r6
	mls r7, r7, r6, r5
	ldr r6, =1000
	udiv r7, r6
	add r7, #'0'
	strb r7, [r4, #7]

	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; DISPLAY TIME
; 
; 	
;	for (int i = 0; i < 8 ; i++)
;	    if (timeStringNew[i] != timeStringDisplayed[i])
;	        setcursor(x=5+i, y=10)
;	        printC
;	        timeStringDisplayed [i] = timeStringNew [i]
;
;--------------------------------------------
displayTime	PROC
	push {r4-r8,lr}

	

	ldr r6, =timeStringNew					; r6 = Adresse von timeStringNew
	ldr r7, =timeStringDisplayed			; r7 = Adresse von timeStringDisplayed
	mov r5, #8								; r5 = Endwert = 8
	
for_string01								; r4 = i = 0, Laufvar. auf Startwert setzen
	mov r4, #0								
until_string01
	cmp r4, r5								; Abbruch bei: i >= 8
	bhs enddo_string01
do_string01									; jede Interation: innere Kontrollstruktur aufrufen:

if_string02
	ldrb r2, [r6, r4]						; r2 = timeStringNew[i]
	ldrb r3, [r7, r4]						; r3 = timeStringDisplayed[i]
	cmp r2, r3
	bne then_string02
	b 	endif_string02
then_string02

	mov r0, #10								; setze X-Var auf Stelle von Laufvar. weiter für lcdGotoXY
	add r0, r4
	mov r1, #5								; setze Y-Var auf 5
	
	PUSH {r2-r8, lr}
	bl lcdGotoXY
	POP {r2-r8, lr}

	mov r0, r2								; print das neue Zeichen
	
	push {r2-r8, lr}
	bl lcdPrintC
	pop {r2-r8, lr}

	strb r2, [r7, r4]						; timeStringDisplayed [i] = timeStringNew [i] = r2

	b endif_string02
endif_string02								; Ende innere Kontrollstruktur
											; Fortsetzung äußere for-Schleife
step_string01
	add r4, #1								; Laufvar. inkr. um 1: i++
	b until_string01	
enddo_string01


	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; resetTimer
;--------------------------------------------
resetTimer PROC
	push{r4-r8,lr}

	ldr r4, =TIM2_ERG						
	mov r5, #1
	strb r5, [r4]

	pop {r4-r8, pc}
	ENDP

;--------------------------------------------
; preINIT
; 
;	wird immer genau dann aufgerufen, wenn aus einem
; 	anderen Zustand in Init gewechselt werden soll.
; 	Gibt einmalig 00:00.00 auf dem Bildschirm aus.
;--------------------------------------------
preINIT	PROC
	push {r4-r8,lr}

	mov r0, #10								; preINIT: auf Bildschirm 00:00.00 einmalig ausgeben
	mov r1, #5
	bl lcdGotoXY
	ldr r0, =initString
	bl lcdPrintS

	pop {r4-r8, pc}
	ENDP

;--------------------------------------------
; INIT
;--------------------------------------------
initState	PROC
	push {r4-r8,lr}

	ldr r0, =state							; LEDs updaten, Parameter: state = 0_00
	ldrb r0, [r0]							; updateLEDS: 0_00		
	bl LEDS_SET							

if_init
	
	mov r0, #7								; Taster 7 gedrückt?
	bl askButton							; -> return: r0
	
	cmp r0, #1								; 1 = true								
	beq then_init
	b 	endif_init

then_init
	
	mov r6, #RUNNING
	ldr r4, =state
	strb r6, [r4]							; ... dann state = RUNNING
	
	bl resetTimer

endif_init									; ... sonst: tue nichts

	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; RUNNING
;--------------------------------------------
runningState	PROC

	push {r4-r8,lr}

	bl convertTime
	bl displayTime	

	ldr r0, =state							; LEDs updaten, Parameter: state
	ldrb r0, [r0]
	bl LEDS_SET

	ldr r4, =state							; r4 = state

if_running

	mov r0, #5								; Taste 5 gedrückt?
	bl askButton							; -> return r0

	cmp r0, #1								; 1 = true								
	beq then_running
	b 	elseif_running

then_running

	mov r6, #INIT							; ... dann state = INIT
	ldr r4, =state							; r4 = state
	strb r6, [r4]

	bl preINIT								; ... und dann preINIT: auf Bildschirm 00:00.00 einmalig ausgeben

	b endif_running
	
elseif_running

	mov r0, #6								;  Taste 6 gedrückt?
	bl askButton							; -> return r0

	cmp r0, #1								; 1 = true
	beq thenelse_running
	b endif_running

thenelse_running

	ldr r4, =state							; ... dann state = HOLD	
	mov r6, #HOLD
	strb r6, [r4]

	b endif_running

endif_running

	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; HOLD
;--------------------------------------------
holdState	PROC
	push {r4-r8,lr}

	ldr r0, =state							; LEDs updaten, Parameter: state = 0_11 = 0d03
	ldrb r0, [r0]
	bl LEDS_SET

	ldr r4, =state							; r4 = Adresse von state

if_hold

	mov r0, #5								; Taste 5 gedrückt?
	bl askButton							; -> return r0

	cmp r0, #1								; 1 = true	
	beq then_hold
	b elseif_hold

then_hold 

	mov r6, #INIT							; ... dann state = INIT
	strb r6, [r4]

	bl preINIT								; preINIT: auf Bildschirm 00:00.00 einmalig ausgeben

	b endif_hold

elseif_hold

	mov r0, #7								; Taster 7 gedrückt?
	bl askButton							; -> return: r0
	
	cmp r0, #1								; 1 = true	
	beq thenelse_hold
	b endif_hold

thenelse_hold

	mov r6, #RUNNING
	ldr r4, =state
	strb r6, [r4]							; ... dann state = RUNNING
	
endif_hold

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

		; zur eigenen Initialisierung:

		bl preINIT						; preINIT: auf Bildschirm 00:00.00 einmalig ausgeben

superloop	PROC
		
	ldr r0, =state						; r0 = state
	ldrb r0, [r0]						; state auslesen


; ZUSTANDSAUTOMAT
if_01 
	
	cmp r0, #INIT
	beq then_01
	b elseif_02 

then_01 

	bl initState
	b endif_01 
	
elseif_02 

	cmp r0, #RUNNING
	beq then_02
	b elseif_03 

then_02 
	
	bl runningState
	b endif_01 

elseif_03 

	cmp r0, #HOLD
	beq then_03 

then_03

	bl holdState

endif_01

		bal superloop
		ENDP

		ALIGN
		END