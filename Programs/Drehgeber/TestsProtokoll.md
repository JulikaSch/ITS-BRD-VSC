Test 1:
    Folgende Module in V1 Fertig: types.h, input.c, ledoutput.c, main.c; Leds zeigen input A B
    -Test mit angle: -30.0 und velo = 1 liefert a b c d korrekt. 
        eigentlich sollte angle positiv sein. kp wo das Problem ist

Test 2: Phasenwechsel
    -Encoder geschrieben: Phasenwechsel, richtung, Zähler
    -types.h angepasst: neu direction
    -main.c angepasst: D8-15 nun Zähler, Display zeigt Zähler und Richtung, Fehler wenn Phase übersprungen

    ->nur langsam laufen lassen, sonst kommt das Programm nicht hinterher. Fixen???
    ->Count wird gespeichert auch wenn richtung sich ändert
    ->immer noch "invertierter Winkel"

Test 4: Richtungs LEDs, Error LED, Reset mit S6
    -ledOutput: hinzugefügt: leds fehler und Richtung anzeigen
    -input: hinzugefügt: S6 als reset
    -main: update: Error->Stopp, S6->encoderinit()
    -types.h: update struct Inputdata{Phase, S6}
    -input update: readphase->read, S6
    