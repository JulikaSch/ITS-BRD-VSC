;************************************************
;* Beginn der globalen Daten *
; 
;************************************************
    AREA MyData, DATA, ALIGN = 2
Var_n				DCW		1000
Var_prim_grob		DCB		200
			
SiebFeld			DCB	 1
					DCB  1
					FILL 998, 0
PrimzahlenFeld		FILL 400, 0, 2

    EXPORT SiebFeld
	EXPORT PrimzahlenFeld
	EXPORT Var_n
                  

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
	ldr r2,=SiebFeld					; Startadresse von Sieb laden
	ldr r5, =Var_n
	ldrh r5, [r5]						; r5 = 1000
	
    
;--------------------------------------------
;START ÄUSSERE WHILE-SCHLEIFE
;--------------------------------------------

	mov r0, #2							; i=2, weil 0 und 1 keine Prim

;---while (i * i <= n)---

while_01
	mul r1,r0,r0						; r1 = i * i
    cmp r1, r5							; r5 = n = 1000
   	bls do_01              				; Sprung wenn ls -> less or equal für unsigned. branch Laufbedingung
   	b   endwhile_01

	

;---do {if-Abfrage mit innerer while-Schleife und Inkrementierung}

do_01

;--------------------------------------------
;START IF-BEDINGUNG
;--------------------------------------------
;---if (sieb[i] == 0)---

if_02
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
	mov r3, #1							; temp: r3 = 1 = keine Prim

;---while (j <= n)---

while_03
 	cmp r4, r5							; r5 = n = 1000
    blo do_03							; springen, wenn r4 <= n
    b   endwhile_03

;---do: Vielfaches markieren (Sieb[j]=1) und Inkrement Laufvar:j = j + i---

do_03
	strb r3, [r2, r4]					; r2 = Basisadresse Sieb, r4 = j. Also Sieb[j] = 1
    add r4, r4, r0						; Inkrementierung der Laufvar.:  j = j + i
    b   while_03
endwhile_03


;--------------------------------------------
;ENDE INNERE WHILE-SCHLEIFE
;--------------------------------------------


	
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

;--------------------------------------------
;ENDE SIEB-ALGORHITMUS
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;--------------------------------------------

;--------------------------------------------
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;START ABSPEICHERN-ALGORHITMUS
;--------------------------------------------
	ldr r3, =PrimzahlenFeld				; r3 = Basisadresse von PrimzahlenFeld
	mov r1, #0							; r1 = k = Primzahlen-Eintrags-"Zeiger"

;--------------------------------------------
;START FOR-SCHLEIFE
;--------------------------------------------

;---for (p = 2; p <= n; p++):
for_04
	mov r0, #2							; r0 = p = 2, setze Laufvariable = Startwert

until_04
	cmp r0, r5							; Abbruchbedingung: p > n, r5 = n = 1000
	bhi enddo_04

do_04									; Anweisungsblock mit innerer if-Bed.

;--------------------------------------------
;START IF-BEDINGUNG
;--------------------------------------------

;---if (sieb[p] == 0):
if_05
	ldrb r4, [r2, r0]					; r4 = Sieb[p]; r2 = Basisadresse-Sieb; r0 = p = Offset
	cmp r4, #0							; Springe, wenn Sieb[p] = Sieb[r0] == 0	
	beq then_05
	b	endif_05


;---then: prim[k] = p; k++ 
then_05									
	strh r0, [r3, r1]					; Prim[k] = p also Prim[r1] = r0,
										; also r3 = Basisadresse Prim, r1 = k = Offset; r0 = p = Primzahl
	add r1, #2							; k++, Inkrementierung des Feldzeigers für PrimFeld um 2 Byte



endif_05

;--------------------------------------------
;ENDE IF-BEDINGUNG
;--------------------------------------------

step_04
	add r0, #1							; Laufvar.  inkrementieren: p = p + 1
	b 	until_04

enddo_04



;--------------------------------------------
;ENDE FOR-SCHLEIFE
;--------------------------------------------


;--------------------------------------------
;ENDE ABSPEICHERN-ALGORHITMUS
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;--------------------------------------------


forever         b   forever             ; Programm fertig, loop forever
    ENDP
    END