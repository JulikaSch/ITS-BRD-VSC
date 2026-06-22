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
timeStampOLD		DCD		0				; Zeitstempelvariable für UpdateClk
timeStoppedRAW		DCD		0				; Variable, die die gestoppte Zeit speichert (noch nicht umgerechnet)
timeStringNew		DCB		"00:00.00", 0
timeStringDisplayed DCB		"00:00.00",0
initString 			DCB		"00:00.00",0
state				DCB		INIT

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

	
	ldr r5, =GPIO_D_CLR
	mov r6, #3
	strh r6, [r5]

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
;ALLE Taster AUSLESEN
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
ALLbuttonsRead	PROC
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
	b enddo_button							; direkt äußere Schleife beenden, weil gedrückten Knopf gefunden
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
; Taster abfragen
; 
; 	gibt true oder false zurück, je nachdem, ob die übergebene
; 	Taste gedrückt wurde
;
; Input r0 
;			= 5, 6 oder 7
; output r1 
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
	and r1, r4, r5							; mit Bitmakske ausschneiden
	eor r1, r5								; einzelnes Bit invertieren: 1 = Taster gedrückt, 0 = nicht gedrückt
	lsr r0, r1, r0							; ausgelesenes Bit nach ganz rechts schieben

	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; UPDATE STATES der FSM updaten entsprechend der gedrückten Buttons.
; 
;
; if (Button == 5)): state = INIT
; elseif (Button == 7)
; {
;    if (state == INIT): Timer resetten mit tim2_erg = 1
;    state = RUNNING
; }
; elseif (Button == 6))
; {
;    if (state == RUNNING): state = HOLD
; }
;--------------------------------------------
updateState	PROC
	push {r4-r8,lr}

	ldr r4, =state							
	ldr r5, [r4]							; r4 = Adresse von state
											; r5 = state
											; r6 = Bitmuster für Init, Running oder Hold

if_state01

	mov r0, #5								; Taste 5 gedrückt?
	bl askButton	

	cmp r1, #1								; 1 = true								
	beq then_state01
	b 	elseif_state02

then_state01

	mov r6, #INIT							; ... dann state = INIT
	strb r6, [r4]
	b 	endif_state01

elseif_state02

	mov r0, #6
	bl askButton							; Taste 6 gedrückt?

	cmp r1, #1								; 1 = true								
	beq then_state02
	b 	elseif_state03

then_state02

if_state02
									; ...dann innere Kontrollstruktur
	mov r6, #RUNNING
	cmp r5, r6								; if (state == RUNNING)...
	beq	then_state04
	b 	endif_state02

then_state04								; ...then state = HOLD
	
	mov r6, #HOLD
	strb r6, [r4]
	b 	endif_state02

endif_state02								; Ende innere Kontrollstruktur

	b 	endif_state01						; Fortsetzung äußere Kontrollstruktur

elseif_state03
	
	mov r0, #7
	bl askButton							; Taster 7 gedrückt?

	cmp r1, #1								; 1 = true								
	beq then_state03
	b 	endif_state01

then_state03
	
	mov r6, #RUNNING
	strb r6, [r4]							; ... dann state = RUNNING
	b	endif_state01

endif_state01

	pop {r4-r8,pc}
	ENDP



;--------------------------------------------
; TEST-TFT-Display ansteuern
;--------------------------------------------
displayAnsteuern	PROC
	push {r4-r8,lr}

	mov r0,#10								; r0 = X
	mov r1,#5								; r1 = Y
	bl lcdGotoXY

	;ldr r0, =timeStopped
	bl lcdPrintS

	mov r0, #'#'
	bl lcdPrintC


	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; UpdateClk
; 
; 	ließt Zeitstempel aus, vergleicht mit Zeitstempel vom vorigen Aufruf (timeStampOLD)
; 	und gibt Zeitdifferenz (timeDeltaRAW) zurück
; 
; return r0 
;			= timeDeltaRAW 
;--------------------------------------------
updateClk	PROC
	push {r4-r8,lr}

	ldr r4, =TIMER
	ldr r4, [r4]
	ldr r5, =timeStampOLD
	ldr r6, [r5]
	sub r0, r4, r6								; aktuellen - vorigen Zeitstempel = timeDeltaRAW
												; return r0 = Zeitdifferenz
	str r4, [r5]								; timeStampOLD überschreiben mit neuem Wert


	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; checkTime
;
; 	ließt den Zeitgeber und aktualisiert die gestoppte Zeit (noch nicht umgerechnet!)
;
;--------------------------------------------
checkTime	PROC
	push {r0-r8,lr}

	bl updateClk								; liefert in r0 die Zeitdifferenz seit letztem updateClk-Aufruf
	ldr r4, =timeStoppedRAW
	ldr r5, [r4]
	add r5, r0
	str r5, [r4]							; addiere zu timeStoppedRAW die abgefragte Zeitdifferenz

	pop {r0-r8,pc}
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
; INIT 
;--------------------------------------------
initState	PROC
	push {r4-r8,lr}

											; lösche die beiden Zeitvariablen
	mov r5, #0

	;ldr r4, =timeStampOLD
	;str r5, [r4]

	;ldr r4, =timeStoppedRAW
	;str r5, [r4]

	mov r0, #0									
	bl LEDsOn

	;bl displayTime								

if_init
	
	mov r0, #7
	bl askButton							; Taster 7 gedrückt?

	cmp r0, #1								; 1 = true								
	beq then_init
	b 	endif_init

then_init
	
	mov r6, #RUNNING
	ldr r4, =state
	strb r6, [r4]							; ... dann state = RUNNING
	
	ldr r0, =TIM2_ERG						; reset Timer GENAU HIER!
	mov r1, #1
	strb r1, [r0]

endif_init

	pop {r4-r8,pc}
	ENDP


;--------------------------------------------
; RUNNING
;--------------------------------------------
runningState	PROC
	push {r4-r8,lr}

	mov r0, #5								; Taste 5 gedrückt?
	bl askButton	

if_running
	cmp r0, #1								; 1 = true								
	beq then_running
	b 	endif_running

then_running

	mov r6, #INIT							; ... dann state = INIT
	strb r6, [r4]

	mov r0, #10
	mov r1, #5
	bl lcdGotoXY
	ldr r0, =initString
	bl lcdPrintS

endif_running

	ldr r0, =state							; LEDs updaten, Parameter: state
	ldrb r0, [r0]
	bl LEDsOn

	bl convertTime
	bl displayTime	
	
	pop {r4-r8,pc}
	ENDP

;--------------------------------------------
; HOLD
;--------------------------------------------
holdState	PROC
	push {r4-r8,lr}

	ldr r0, =state							; LEDs updaten, Parameter: state
	ldrb r0, [r0]
	bl LEDsOn

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

		bl updateClk

		mov r0, #X_START
		mov r1, #Y_START
		bl lcdGotoXY
		ldr r0, =initString
		bl lcdPrintS

superloop	PROC
		;b 	updateClk
		;bl ALLbuttonsRead

		;ldr r5, =state
		;mov r6, #RUNNING
		;str r6, [r5]

		;bl updateState		
		
	; bl checkTime
	;bl updateState

	ldr r0, =state					; r0 = state
	ldrb r0, [r0]


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