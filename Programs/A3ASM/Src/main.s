;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Silke Behn	
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main.
;					  :
;					  : Replace this main with yours.
;
;*******************************************************************************
    EXTERN initITSboard
    EXTERN lcdPrintS            ;Display ausgabe
    EXTERN GUI_init
;	EXTERN TP_Init
;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2
Base
VariableA          DCW 0x1234
VariableB          DCW 0x4711

VariableC          DCD  0

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45

MeinWortFeld       DCD 0x12345678 , 0x9dca5986
                   DCD -872415232 , 1308622848
                   DCD 0x27000000
                   DCD 0x45000000

MeinTextFeld       DCB "ABab0123",0

                   EXPORT VariableA
                   EXPORT VariableB
                   EXPORT VariableC
                   EXPORT MeinHalbwortFeld
                   EXPORT MeinWortFeld
                   EXPORT MeinTextFeld

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; Laden von Konstanten in Register
				; lädt eine kleine Konstante direkt ins register R0
                mov   r0,#0x12                      ; Anw-01
                ; lädt kleine konstante in R1
				mov   r1,#-128                      ; Anw-02
                ; Wert zu groß für mov, legt ab in Literal Pool
				ldr   r2,=0x12345678                ; Anw-03

; Zugriff auf Variable
                ; lädt die Adresse von variableA in R0
				ldr   r0,=VariableA                 ; Anw-04
                ; lädt Halbwort von Adresse in R1
				ldrh  r1,[r0]                       ; Anw-05
                ; lädt Wort von Adresse in R2
				ldr   r2,[r0]                       ; Anw-06
                ; speicher den Inhalt von R2 an Addresse R0 plus Offset
				str   r2,[r0,#VariableC-VariableA]  ; Anw-07

; Zugriff auf Felder (Speicherzellen)
                ; lädt die Adresse von MeinHalbwortFeld in R0
				ldr   r0,=MeinHalbwortFeld          ; Anw-08
                ; lädt Halbwort von Adresse in R1
				ldrh  r1,[r0]                       ; Anw-09
                ; lädt Halbwort von Adresse plus Offset in R2
				ldrh  r2,[r0,#2]                    ; Anw-10
                ; lädt Halbwort von Adresse plus Offset in R3
				mov   r3,#10                        ; Anw-11
                ; lädt Halbwort von Adresse r0 + r3 in R4
				ldrh  r4,[r0,r3]                    ; Anw-12

                ; R0 wird erst um 2 erhöht, dann wird gelesen
				ldrh  r5,[r0,#2]!                   ; Anw-13
                ; R0 wieder um 2 erhöht
				ldrh  r6,[r0,#2]!                   ; Anw-14
                ; R0 wieder um 2 erhöht, dann wird r6 dorthin geschrieben
				strh  r6,[r0,#2]!                   ; Anw-15

; Addition und Subtraktion von unsigned / signed Integer-Werten
                ; lädt anfangsadresse von MeinWortFeld in R0
				ldr  r0,=MeinWortFeld               ; Anw-16
                ; lädt Wort von Adresse in R1
				ldr  r1,[r0]                        ; Anw-17
                ; lade wort von r0 plus 4 offset
				ldr  r2,[r0,#4]                     ; Anw-18
                ; addiert die Werte in R1 und R2, speichert Ergebnis in R3
				adds r3,r1,r2                       ; Anw-19

                ; lade ein wort von r0 plus 8 offset in r4
				ldr  r4,[r0,#8]                     ; Anw-20
                ; lade ein wort von r0 plus 12 offset in r5
				ldr  r5,[r0,#12]                    ; Anw-21
                ; subtrahiert die Werte in R4 und R5, speichert Ergebnis in R6
				subs r6,r4,r5                       ; Anw-22

                ; lade ein wort von r0 plus 16 offset in r7
				ldr  r7,[r0,#16]                    ; Anw-23
                ; lade ein wort von r0 plus 20 offset in r8
				ldr  r8,[r0,#20]                    ; Anw-24
                ; subtrahiert die Werte in R7 und R8, speichert Ergebnis in R9
				subs r9,r7,r8                       ; Anw-25

				; Endloschleife, Programm bleibt stehen
forever         b   forever                         ; Anw-26
                ENDP
                END
;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	
	AREA MyData, DATA, align = 2
	
	    GLOBAL text
DEFAULT_BRIGHTNESS DCW  800
	
text	DCB	"Hallo liebes TI-Labor (asm-project)",0

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************

	AREA |.text|, CODE, READONLY, ALIGN = 3

;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]
	
main	PROC
        BL initITSboard
		ldr r1, =DEFAULT_BRIGHTNESS
		ldrh r0, [r1]
		bl GUI_init
		mov r0, #0x00
;		bl TP_Init
		
		LDR	r0,=text
        BL  lcdPrintS

forever	b	forever		; nowhere to retun if main ends		
		ENDP
	
		ALIGN
       
		END