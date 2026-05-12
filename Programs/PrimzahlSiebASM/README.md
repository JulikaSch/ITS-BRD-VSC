Wir legen 1001 "Markierungs-Boxen" an, anfangs alle als "Primzahl" markiert
Wir gehen die Zahlen durch: Wenn eine Zahl noch "Primzahl" ist, streichen wir all ihre Vielfachen ab (Quadrat). Wenn nicht, überspringen wir sie.
Wir kopieren die übrigen Primzahlen aus dem Sieb in eine kompakte Liste.

Eine zusammengesetzte Zahl x hat immer einen Primfaktor p mit p ≤ √x. Solange ich für jeden p bis √N seine Vielfachen streiche, sind alle zusammengesetzten Zahlen unter N erwischt."

## Anylyse der aufgabenstellung 
Ein Assemblerprogramm, das alle Primzahlen im Intervall [2, 1000] berechnet
und kompakt in einem separaten Speicherbereich ablegt. Dafür verwenden wir das sieb des erastosthenes

Es werden nacheinander die vielfachen der bisher gefundenen Primzahlen gestrichen beginnend bei 2 
Wir gehen zu nächsten nicht gestrichenen zahl, der 3, und streichen deren vielfache 
Was übrig bleiben sollte sind die primzahlen der menge von 2 bis 1000

Die Methode sieb markiert einen byte im speicher, welche zahlen primzahlen sind mit 0 oder 1 
Die mehtode abspeichern liest diese aus und speichert sie ab in ein zweites array ohne die anderen zahlen

## Welche Felder sollen verwendet werden? Von welchem Typ sollen die Elemente sein?

für sieb:
der type ist 1 byte, insgesamt 1001 bytes, weil Array von 0 bis 1000 sind 1001 Elemente
0x00 ist eine primzahl
0x01 ist keine primzahl

Es muss nur ein wahrheitsweert gepeichert werden 0 oder 1 wahr oder falsch, weswegen 1 byte am sinnvolsten ist, es ist speicher effizienter

für primzahlen:
2 bytes aso ein halfword 
Die größte primzahl der menge ist 997 (=0x03E5), ein byte würde hierfür nicht mehr reichen,
ein halfword ist schon zu groß, aber genügend für die menge der zahlen


