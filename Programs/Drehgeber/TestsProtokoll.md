Test 1:
    Folgende Module in V1 Fertig: types.h, input.c, ledoutput.c, main.c; Leds zeigen input A B
    -Test mit angle: -30.0 und velo = 1 liefert a b c d korrekt. 
        eigentlich sollte angle positiv sein. kp wo das Problem ist

Test 2: Phasenwechsel
    -Encoder geschrieben: Phasenwechsel, richtung, Zähler
    -types.h angepasst: neu direction
    -main.c angepasst: D8-15 nun Zähler, Display zeigt Zähler und Richtung, Fehler wenn Phase übersprungen

    
    