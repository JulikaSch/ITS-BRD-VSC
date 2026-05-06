;************************************************
;* Beginn der globalen Daten *
; bitweises or ist wie addition ohne überlauf??
;************************************************
                   AREA MyData, DATA, ALIGN = 2
Base
VariableA          DCW 0x1234
VariableB          DCW 0x4711

VariableC          DCD  0

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45

MeinWortFeld       DCD 0x12345678 , 0x9dca5986
                   DCD -872415232 , 1308622848
                   DCD 0x27000000
                   DCD 0xe2000000

MeinTextFeld       DCB "ABab0123", 0

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

;_______________Anw-01: r0 = 0x12 = 0d18____________________
; lädt Hex 12 als Immediate in Register 1
;___________________________________________________________
                mov   r0,#0x12                      ; Anw-01

;_______________Anw-02: r1 = 0d-128 bzw. r1 = 0xffffff80____
; lädt Dezimale -128 als Immediate in Register 2
;___________________________________________________________
                mov   r1,#-128                      ; Anw-02

;_______________Anw-03: r2 = 0x123456789____________________
; (Pseudoinstruktion). Konstante, die größer als 16 Bit ist,
;  wird im Speicher (Literal Pool) abgelegt und von dort 
; geladen)
;___________________________________________________________
                ldr   r2,=0x12345678                ; Anw-03


; Zugriff auf Variable

;_______________Anw-04: r0 = 2000000c_______________________
; lädt die Adresse von VariableA in Register 0
;___________________________________________________________
                ldr   r0,=VariableA                 ; Anw-04

; ______________Anw-05: r1 = 1234 = VariableA_______________
; gehe an die Adresse, die in Register 0 steht, und lade aus 
; dem Speicher ein MeinHalbwort in Register 1
;___________________________________________________________
                ldrh  r1,[r0]                       ; Anw-05

;_______________Anw-06: r2 = 47111234 = VariableBVariableA__
; gehe an die Adresse, die in Register 0 steht, und lade aus
; dem Speicher ein Wort in Register 2. Lädt automatisch VarA 
; und VarB zusammengefügt und verdreht (little endian)
;___________________________________________________________
                ldr   r2,[r0]                       ; Anw-06

;_______________Anw-07: Variable C = r2 = 47111234__________
; Nimm r0 als Basisadresse und addiere als Offset den Abstand
; von VariableA und Variable C im Speicher. 
; Lege den 4 Byte Inhalt aus Register 2 in Variable C ab.
;___________________________________________________________
                str   r2,[r0,#VariableC-VariableA]  ; Anw-07


; Zugriff auf Felder (Speicherzellen)

;_______________Anw-08: r0 = Adresse von MeinHalbwortFeld___
                ldr   r0,=MeinHalbwortFeld          ; Anw-08

;_______________Anw-09: r1 = 0x22___________________________
; lädt das 0. Element des MeinHalbwortFelds in Register 1
;___________________________________________________________
                ldrh  r1,[r0]                       ; Anw-09

;_______________Anw-10: r2 = 0x3e___________________________
; lädt das 1. Element des HalbwortFeldes in Register2
;___________________________________________________________
                ldrh  r2,[r0,#2]                    ; Anw-10

;_______________Anw-11: r3 = 0x1a = 0d10____________________
; lädt den Immediate 0x1a in Register 3
;___________________________________________________________
                mov   r3,#10                        ; Anw-11

;_______________Anw-12: r4 = 0x45___________________________
; lädt das (10 / 2 = ) 5. Element des HalbwortFeldes in Reg4
;___________________________________________________________
                ldrh  r4,[r0,r3]                    ; Anw-12

;_______________Anw-13: r5 = 0x3e___________________________
;                   und r0 = Adresse vom 1.Element
;lädt das 1. Element aus MeinHalbwortFeld und passt die 
;Basisadresse in r0 an die aktuelle Adresse an. Quasi ein 
;Pointer, der nun 2 Byte, also 1 Element weiter zeigt.
___________________________________________________________
                ldrh  r5,[r0,#2]!                   ; Anw-13

;_______________Anw-14: r6 = 0xffffffcc = 0d-52_____________
;                   und r0 = Adresse vom 2. Element
;___________________________________________________________
                ldrh  r6,[r0,#2]!                   ; Anw-14

;_______________Anw-15: 3. El. von MeinHalbwortFeld =r6= -52
                 und r0 = Adresse vom 3. Element
;___________________________________________________________
                strh  r6,[r0,#2]!                   ; Anw-15


; Addition und Subtraktion von unsigned / signed Integer-Werten

; Anw-16: lädt Basisadresse MeinWortFeld in R0
                ldr  r0,=MeinWortFeld               ; Anw-16

; Anw-17: lädt 0. Element von MeinWortFeld in r1 = 0x12345678
                ldr  r1,[r0]                        ; Anw-17

; Anw-18: lädt 1. Element von MeinWortFeld in r2 = 0x9dca5986
                ldr  r2,[r0,#4]                     ; Anw-18

; Anw-19: addiert 0. und 1. Element und schreibt Ergebnis in r3
;         und updatet Flags
                adds r3,r1,r2                       ; Anw-19

; Anw-20: lädt 2. Element aus MeinWortFeld in r4 = 0d-872415232
                ldr  r4,[r0,#8]                     ; Anw-20

; Anw-21: lädt 3. Element aus MeinWortFeld in r5 = 0d1308622848
                ldr  r5,[r0,#12]                    ; Anw-21

; Anw-22: subtrahiert binär r5 von r4 und schreibt Ergebnis 
;         in r6 und setzt Flags
                subs r6,r4,r5                       ; Anw-22

; Anw-23: lädt 4. El  aus MeinWortFeld in r7 = 0x27000000
                ldr  r7,[r0,#16]                    ; Anw-23

; Anw-24: lädt 5. El  aus MeinWortFeld in r8 = 0xe2000000
                ldr  r8,[r0,#20]                    ; Anw-24

; Anw-25: subtrahiert binär r8 von r7 und schreibt Ergebnis 
;         in r9 und setzt Flags 
                subs r9,r7,r8                       ; Anw-25

; Programm ist fertig, loop forever
forever         b   forever                         ; Anw-26
                ENDP
                END