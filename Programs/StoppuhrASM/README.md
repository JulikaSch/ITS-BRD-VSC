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

### allg. LEDs Ansteuern
#### allg. AUSLESEN:
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

#### allg. ANSCHALTEN:
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

#### allg AUSSCHALTEN:
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

### allg: TFT-Display ansteuern
bereits implementierte Methoden: 
lcdGotoXY (r0 = X, r1 = Y) -> positioniert Cursor auf Stelle (X, Y)
lcdPrintS (r0 = Adresse vom String) -> gibt String an aktueller Cursor-Stelle auf Bildschirm aus
lcdPrintC (r0 = ASCII-Zeichen) -> gibt Zeichen an aktueller Cursor-Stelle auf Bildschirm aus

## Subroutinen:

### Hardware initialisieren

### LEDsSet
input r0 
			= #0 -> schaltet alle aus
			= #1 -> schaltet nur D8 an (Rest bleibt unverändert)
			= #2 -> schaltet nur D9 an (Rest bleibt unverändert)
 			= #3 -> schaltet D8, D9 an

1. clr LEDs: 0000 00xx Bitmaske an GPIO_D_CLR schreiben
2. 0000 00xx Bitmaske auf r0
3. auf GPIO_D_SET schr. 


### askButton - Taster abfragen 
16-Bit-Muster an Adresse GPIO_F_PIN.
Bit entspricht jeweils Bit entspricht jeweils einem Taster.
Bits: 1 = Taster nicht gedrückt. 0 = Taster gedrückt. 

and #0xff -> setzt irrelevante Bits auf 1.

#0xff = 1111 1111 = nichts gedrückt
#0x7f = 0111 1111 = nur S7 gedrückt
#0xbf = 1011 1111 = nur S6 gedrückt
#0xdf = 1101 1111 = nur S5 gedrückt

Unterprogramm überprüft, ob eine bestimmte Taste gedrückt wurde. Bekommt Zahl zwischen 0 und 7 übergeben (Taster) und gibt 1= true oder 0 = false über r0 zurück.

1. ließ Taster-Bitmuster aus
2. Bitmaske #1 LSL um input-parameter r0
3. betrachte nur das Bit, was dem gefragten Taster entspricht -> AND r_Taster, r_Bitmaske
4. invertiere das gelesene Bit (eor)
5. schiebe das gelesene Bit nach ganz rechts

### convertTime 
ohne Input / Output, sondern über Speicherzugriffe
vergangene Zeit ist in Variablen/ Register timeStoppedRAW gespeichert in 10us.


timeMM (in min) = timeStoppedRAW div 6.000.000 (ohne runden!)
timeSEK (in sek) = (timeStoppedRAW mod 6.000.000) div 100.000
timeNN (in 10ms) = (timeStoppedRAW mod 600.000) div 1.000

speichern in String: 
timeStringNew = "00:00.00"0

1. Basis-Adresse timeStringNew holen
2. timeStoppedRaw laden in R5
3. r10m =   tsr div 60.000.000                     -> String +#0
4. r1m =    (tsr mod 60.000.000) div 6.000.000     -> String +#1
5. r10s =   (tsr mod 6.000.000) div 1.000.000      -> String +#3
6. r1s =    (tsr mod 1.000.000) div 100.000        -> String +#4
7. r100ms = (tsr mod 100.000) div 10.000           -> String +#6
8. r10ms =  (tsr mod 10.000) div 1.000             -> String +#7

### displaytime
aktualisiert die Zeitanzeige auf dem TFT-Display

timeStringDisplayed vgl. mit timeStringNew: 
mit for-Schleife String Zeichen für Zeichen vergleichen und mit printC die eine Stelle ändern, die sich verändert hat. 

for (int i = 0; i < 8 ; i++)
    if (timeStringNew[i] != timeStringDisplayed[i])
        setcursor(x=5+i, y=10)
        printC
        timeStringDisplayed [i] = timeStringNew [i]

### resetTimer
setzt den Timer zurück. Wird aufgerufen, beim Übergang von Init in Run.


         
### FSM-Methoden:
rufen wiederum Rubroutinen auf, um die LEDs zu schalten, Knöpfe zu überprüfen oder die Zeit auszugeben. 
In den FSM-Methoden sind auch die Übergänge in die anderen Zustände modelliert: 


#### INIT
1. updateLEDs (Parameter: state (hinter dem ein Bitmustersteht))
2. übergänge in andere States checken: 
- askButton: Taster 7 gedrückt? -> state = running 
    -> TimerReset (einzige Stelle, wo der Timer intern tatsächlich resettet wird)

#### RUNNING
1. converttime
2. displaytime
3. updateLEDs (state)
4. Übergänge in andere States checken: 
- askButton: Taster 5 gedrückt -> State = init
    -> preINIT: initialen String mit 0en ausgeben, der unverändert bleibt. Vorgelagert vor init-Funktion, damit der Bildschirm nicht flackert
- askButton: Taster 6 gedrückt -> State = Hold
    (der zuletzt ausgegebene String mit dem aktuellen Zeitstempel bleibt unverändert auf dem Bildschirm)

#### HOLD
1. updateLEDs (state)
2. übergänge in andere States checken: 
- askButton: Taster 5 gedrückt? -> State = init
    -> preINIT: initialen String mit 0en ausgeben, der unverändert bleibt. Vorgelagert vor init-Funktion, damit der Bildschirm nicht flackert
- askButton: Taster 7 gedrückt? -> state = running

### main
1. preINIT (1x 00:00.00 ausgeben)
2. Superloop: state-Variable auslesen, und dann per if-else die passende FSM-Methode aufrufen.

### Superloop
superloop PROC

    {Rumpf}

    bal superloop
    endp



