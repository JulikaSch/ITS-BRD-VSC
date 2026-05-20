;************************************************
;* Beginn der globalen Daten *
; 
;************************************************
    AREA MyData, DATA, ALIGN = 2
Var_n		DCW		1000
Var_ndiv2	DCW		500			
SiebFeld			FILL 1000, 0
PrimzahlenFeld		FILL 500

    EXPORT SiebFeld
	EXPORT PrimzahlenFeld
	EXPORT Var_n
	EXPORT Var_ndiv2
                  

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA MYCODE, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
    EXPORT main
    EXTERN initITSboard

main	PROC 
	bl    	initITSboard                 	; HW Initialisieren

;--------------------------------------------
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;START SIEB-ALGORHITMUS
;--------------------------------------------

;--------------------------------------------
;START ÄUSSERE WHILE-SCHLEIFE
;--------------------------------------------

	mov r0, #2							; i=2, weil 0 und 1 keine Prim

;---while (i * i <= n)---

while_01
	mul r1,r0,r0						; r1 = i * i
    ldr r5, =Var_n
	ldrh r5, [r5]						; r5 = 1000
	cmp r1, r5
   	bls do_01              				; Sprung wenn ls -> less or equal für unsigned. branch Laufbedingung
   	b   endwhile_01

	

;---do {if-Abfrage mit innerer while-Schleife und Inkrementierung}

do_01

;--------------------------------------------
;START IF-BEDINGUNG
;--------------------------------------------
;---if (sieb[i] == 0)---

if_02
	ldr r2,=SiebFeld					; Startadresse von Sieb laden
    ldrb r3,[r2,r0]						; r2 = Basisadresse, r0 = i = Offset, r3 = Sieb[i] = Sieb[r0]
	cmp r3, #0
    beq then_02							; Springe, wenn Sieb[i] = 0
    b   endif_02

;---then: j = j * i und innere while-Schleife---

then_02
    
	mul r4,r0,r0						; r4 = j

;--------------------------------------------
;START INNERE WHILE-SCHLEIFE
;--------------------------------------------

;---while (j <= n)---

while_03
 	cmp r4, r5							; r5 = n = 1000
    bls do_03							; springen, wenn r4 <= n
    b   endwhile_03

;---do: Vielfaches markieren (Sieb[j]=1) und Inkrement Laufvar:j = j + i---

do_03
	mov r3, #1							; temp: r3 = 1 = keine Prim. TODO Optimierung: #1 nicht in jeder Iteration neu ins Register schreiben
	strb r3, [r2, r4]					; r2 = Basisadresse Sieb, r4 = j. Also Sieb[j] = 1
    add r4, r4, r0						; Inkrementierung der Laufvar.:  j = j + i
    b   while_03
endwhile_03


;--------------------------------------------
;ENDE INNERE WHILE-SCHLEIFE
;--------------------------------------------


	b   endif_02    					; weglassen oder für Übersicht drin lassen?
endif_02

;--------------------------------------------
;ENDE IF-BEDINGUNG
;--------------------------------------------

	add r0, r0, #1						; Inkrement Laufvariable: i = i + 1
	b   while_01
endwhile_01

;--------------------------------------------
;ENDE ÄUSSERE WHILE-SCHLEIFE
;--------------------------------------------


forever         b   forever             ; Programm fertig, loop forever
    ENDP
    END