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

    ->alles wie gewollt

Test 5: Winkel / Winkelgeschwindigkeit
    -types.h: Inputdata hat Feld zeit, ticks pro Sekunde
    -input: Liest Zeitstemptel nach Port F. 32 bit Timer umgerechnet in 64 bit gegen overflow
    -endcoder: countZeit und getZeit()
    -NEU calc: calcAngle(), calcUpdate(), Zählerstempel
    -main: Winkel + velo wird angezeigt, update nur bei calcUpdate. LEDs laufen weiter

    ->falsche Winkel, fehler im code behoben
    ->-360, 20s nur 126 grad. Textausgabe lcdPrintS dauert zu lange. später fixen!!!

Test 5: Zeitmessung (vorerst ohne Oszilloskop)
        measure.c: Steuert Messpin PG0 = AUX0
        main: Modi zur Messung mit und ohne Oszilloskop
    
        ->ZUHAUSE:
        -> Test zuhause: Mess LED scheint zu funktionieren
        -> Test -360, 20s
            -> Display Ausgabe:  108.145 qs
            ->Loop max ohne Display: 3 qs
            ->Loop max mit Display: 218.512 qs //etwas größer da Print von mess auch Zeit kostet
        -> Test -360, 1s
            -> Display Ausgabe:  108.169 qs
            ->Loop max ohne Display: 3 qs
            ->Loop max mit Display: 313.253 qs
        -> Test -360, 100s
            -> Display Ausgabe:  108.169 qs
            ->Loop max ohne Display: 3 qs 
            ->Loop max mit Display: 218.258 qs
        //Display Ausgabe relativ gleichbleibend, klar da unabhängig von Geschwindigkeit

        ->Verhältniss ca 36.000 : 1
        ->Maximale Geschwindigkeit ohne Phasenverlust:
            mit Display: 0,3° / 108ms = 2,8 °/s
            ohne Display: 0,3° / 3 qs = 100.000 °/s


Muss noch! Zeit messen mit Oszilloskop!