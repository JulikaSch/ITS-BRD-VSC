Drehgeber GSP Praktikum 2
Autor Jakob Giese

Module:
    main.c
        Super Loop DCC
        Einlesen -> Verarbeiten -> Ausgeben

    types.h
        Datentypen und Fehlercodes
        enum PhaseniD a-d
        struct Phase{PhasenID, zeitstempel}
        Fehlercodes
        Konstanten

    input.c/h
        Kanäle A/B, S6 lesen
        Zeitstempel
        inputInit(void)
        Phase inputReadPhase(void); A/B + Zeitstempel
        bool inputResetPhase(void); S6

    encoder.c/h Zustand des Drehgebers
        void encoderInit(Phase first); //Startphase merken
        ErrorCode encoderUpdate(Phase p); //einmal pro durchlauf
        int32_t encoderGetCount(void);
        uint64_t encoderGetCountTimestamp(void);
        Direction encoderGetDirection(void);
        bool encoderHasError(void);

    calc.c/h Rechnungen
        void calcInit(uint64_t now, int32_t count, uint64_t countTs)
        double calcAngle()
        bool calcSpeedUpdate(now, count, countTs, double *speedOut)
            liefert nur true wenn 300ms vergangen und sich count ändert

    ledOutput.c/.h LED Ausgabe
        void ledInit(void);
        void ledShowCount(count)
            //leds 8-15
        void ledShowDirection(Direction)
            //D23 Vorwärts, D22 rückwärts
        void ledShowError(bool on)
            //D21 falls Fehler
    
    display.c/h LCD gegeben?????
        ErrorCode displayInit(void)
            //Einmaliger Text
        void displaySetValues(double angle, double speed)
        void displayProcess(void)
            //bei jedem durchlauf

    measure.c/.h Zeitmessung
        void MeasureInit(void)
        void measureHigh(void)
        void measureLow(void)
        void measureToggle(void)
            //für Loop durchlaufzeit      
    
Konzept für einheitliche Fehlerbehandlung
    ErrorCodes in types.h, Einheitliche Codes werden zurückgegeben
    Phasenfehler werden nur in encoder.c erkannt
    main wertet Fehler aus
        D21 ein falls Error
        keine weiteren Ausgaben
    Error bleibt bis S6 gedrückt wird
        dann rücksetzung via encoderInit() und calcInit()
    
Auflistung Eingabezustände + Reaktion

    Zuordnung Signale - Phase

    Kanal A |Kanal B    |Phase
    0       |0          |a
    1       |0          |b
    1       |1          |c
    0       |1          |d


    PhaseAlt->neu       | Reaktion
    gleich              | nixx
    a->b,b->c,c->a,d->a | vorwärts: Zähler +1, D23 an, D22 aus
    a->d,d->c,c->b,b->a | rückwärts: Zähler -1 D23 aus, D22 an
    a->c,c->a,b->d,d->b | Fehler: D21 an, Ausgabe stoppen
    S6 gedrückt         | Reset: Zähler 0, Fehler löschen, Richtung unbekannt
    Fehler              | keine Aktualisierung
    


    