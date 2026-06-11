# Praktikum GTP - Projekt: Stoppuhr - Analyse der Aufgabenstellung
## zentrale Funktionen und Anforderungen

Eine Stoppuhr zur Zeitmessung programmieren mit Zeitdarstellung (mm:ss.nn) auf dem TFT-Display (Auflösung 1/100 Sekunden).
Timer arbeitet mit 10us, Berechnungen alle mit 10us, Display-Genauigkeit: runden auf 10ms

Steuerung (input): Taster S5, S6, S7

Betriebszustand anzeigen über LEDs(output): 
### INIT -> D8, D9 aus, TFT zurückgesetzt auf 00:00.00
Timer stopp (wenn von HOLD kommend).
kann durch S7 -> RUNNING wechseln


### RUNNING -> D8 an, D9 aus
startet Timer, wenn von INIT kommend. 

Zeigt die seit Timerstart vergangene Zeit auf Display an (d.h. zeigt die WEITERlaufende Timer-Zeit an, wenn von HOLD kommend.)

kann durch S6 -> HOLD wechseln
kann durch S5 -> INIT wechseln

### HOLD -> D8, D9 an
Timer läuft im Hintergrund weiter, aber nimmt Momentaufnahme der Zeit zum Zeitpunkt, als in HOLD gewechselt wird.
Zeigt die gestoppte Zeit auf dem Display an.

kann durch S7 -> RUNNING wechseln
kann durch S5 -> INIT wechseln 



## Teilaufgaben:

### Hardware initialisieren

### updatedState
Variable state DCB:
#0x00 = INIT
#0x01 = RUNNING
#0x11 = HOLD

INIT, RUNNING und HOLD im Kopf als Konstanten definieren. 


### LEDs Ansteuern
#### AUSLESEN:
GPIO_D_PIN auslesen -> gibt aktuellen Zustand der LEDs an
16 Bit Muster: 
#0 = 0000 0000 = alle aus
#1 = 0000 0001 = nur D8 leuchtet
#2 = 0000 0010 = nur D9 leuchtet
#3 = 0000 0011 = D8 und D9 leuchten

1. Adresse laden
2. 16-Bit-Muster in Register laden
3. BIC Bitmaske #0xfc -> nur die letzten beiden Bits sind wichtig 
4. Registereintrag für entsprechenden Zustand in anderes Register laden
5. vergleichen mit cmp eq
5. return 0, 1, 2 oder 3

#### ANSCHALTEN:
GPIO_D_SET hier schreiben -> 1 = schaltet entsprechende LED an, 0 = bleibt unverändert
#0 = 0000 0000 = ändert nichts
#1 = 0000 0001 = schaltet nur D8 an
#2 = 0000 0010 = schaltet nur D9 an
#3 = 0000 0011 = schaltet D8 und D9 an
1111 1111 = schaltet alle an

INPUT: 0, 1, 2 oder 3 (entsprechend dafür, welche Lampen an sollen)
1. Adresse laden
2. 16-Bit-Muster = input in Register schreiben
3. Register-Eintrag an Adresse schreiben

#### AUSSCHALTEN:
GPIO_D_CLR hier schreiben -> 1 = schaltet entsprechende LED aus, 0 = bleibt unverändert
#0 = 0000 0000 = ändert nichts
#1 = 0000 0001 = schaltet nur D8 aus
#2 = 0000 0010 = schaltet nur D9 aus
#3 = 0000 0011 = schaltet D8 und D9 aus
#0xff = 1111 1111 = schaltet alle aus

INPUT: 0, 1, 2, 3 oder ff (entsprechend dafür, welche Lampen aus sollen)
1. Adresse laden
2. 16-Bit-Muster = input in Register schreiben
3. Register-Eintrag an Adresse schreiben

### updateLEDs
1. alle aus
2. if (state == INIT = #0x00): endif
3. elseif (state == RUNNING = #0x01): D8 an = #1 an
4. elseif (state == HOLD = #0x11): D8, D9 an = #3 an 

### Taster abfragen
16-Bit-Muster an Adresse GPIO_F_PIN. 
Bit entspricht jeweils einem Taster.
Bits: 1 = Taster nicht gedrückt. 0 = Taster gedrückt. 

and #0xff -> setzt irrelevante Bits auf 1.

#0xff = 1111 1111 = nichts gedrückt
#0x7f = 0111 1111 = nur S7 gedrückt
#0xbf = 1011 1111 = nur S6 gedrückt
#0xdf = 1101 1111 = nur S5 gedrückt

FRAGE: ignorieren, wenn mehrere relevante Taster gedrückt sind?

#### AUSLESEN = readButtons:
1. Adresse von GPIO_F_PIN laden
2. Inhalt von GPIO_F_PIN laden
für alle Buttons: 
; 	r4 = #1 = 0000 0001
; 	for(int r5 = i=0; i<8; i++) ...
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

3. return 0 ( = kein relevanter oder mehrere gedrückt), 5, 6 oder 7 über Register


### TFT-Display ansteuern
bereits implementierte Methoden: 
lcdGotoXY (r0 = X, r1 = Y) -> positioniert Cursor auf Stelle (X, Y)
lcdPrintS (r0 = Adresse vom String) -> gibt String an aktueller Cursor-Stelle auf Bildschirm aus
lcdPrintC (r0 = ASCII-Zeichen) -> gibt Zeichen an aktueller Cursor-Stelle auf Bildschirm aus


### UpdateClk
Zeitstempel auslesen: lesen der Adresse TIMER (= gibt aktuellen Wert des CNT-Registers).
ließt den Zeitstempel aus und gibt die Zeitdifferenz zwischen jetzt und seinem vorigen Aufruf, also die Zeit die während eines Iterationsdurchlaufs der Superloop vergangen ist.

1. Adresse von TIMER in Register laden
2. Inhalt in Register laden -> Zeitstempel
3. neuen Zeitstempel in Variable o. Register speichern
4. aktuellen - vorigen Zeitstempel = vergangene Zeit
5. timeStampOLD überschreiben mit neuem Wert bzw. als return über r0 / r1

timeStampOLD muss bei Timerstart = 0 sein. 
Aufruf von UpdateClk:
- zur Initialisierung 1x
- zum Beginn der Superloop 


### checkTime
ließt den Zeitgeber aus und aktualisiert die Variable, die die Zietspanne der Stoppuhr speichert.

1. UpdatesClk 
2. timeStopped = timeStopped + timeStampOLD


### Zeit umrechnen
vergangene Zeit ist in Variablen/ Register timeRAW gespeichert in 10us.

timeMM (in min) = timeRAW div 6.000.000 (ohne runden!)
timeSEK (in sek) = (timeRAW - timeMM) mul 60
timeNN (in 10ms) = (timeRAW - timeMM - timeSEK) mul 100


### displaytime
aktualisiert die Zeitanzeige auf dem TFT-Display


### Superloop
superloop PROC

    {Rumpf}

    bal superloop
    endp


Rumpf: 
1. checkTime
2. readButtons
3. updateState
4. if (State == INIT): timeStopped = 0 
5. updateLEDs
6. if (! State == HOLD): displayTime




