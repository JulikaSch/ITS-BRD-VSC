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
0x00 entspricht primzahl
0x01 entspricht keine primzahl

Es muss nur ein wahrheitsweert gepeichert werden 0 oder 1 wahr oder falsch, weswegen 1 byte am sinnvolsten ist, es ist speicher effizienter

für primzahlen:
2 bytes aso ein halfword 
Die größte primzahl der menge ist 997 (=0x03E5), ein byte würde hierfür nicht mehr reichen,
ein halfword ist schon zu groß, aber genügend für die menge der zahlen

## notwendige Schleifen und Kontrollstrukturen

eine innere und eine äußere while-Schleife und if-Bedingung. Nutze cmp-Befehl zum Vergleich und un-/bedingte Sprünge. In beiden Fällen unsigned. 
Nummiere die Label durch. Alle Label, die zu einer Kontrollstruktur oder Schleife gehören, erhalten dieselbe Nummer. Also while-01, do-01 usw...
if-02, then-02 usw...  
while-03, then-03 usw...

# Äußere While-Schleife:
//while (i * i <= n) -> solange i * i kleiner als 1000, führe do-Abschnitt aus.

lade die i*i in ein Register, n in ein anderes Register. Vergleiche die Register mit cmp-Befehl. 
springe zu do-01, wenn Laufbedingung, also i*i <= n erfüllt. sonst, unbedingter Srpung zu endwhile-01

Also: 
while-01
    cmp r_i*i, r_n
    bls do-01               // ls -> less or equal für unsigned. branch Laufbedingung
    b   endwhile-01

do-01
    Anweisungsblock (mit if-Abfrage und innerer While-Schleife)
    Inkrementierung der Laufvariablen: i = i + 1 (for-Schleife vllt übersichtlicher?)
    b   while-01
endwhile-01

# if-Abfrage
// if (sieb[i] == 0)


if-02
    cmp r_sieb[i], #0
    beq then-02
    b   endif-02
then-02
    Anweisungsblock (mit Initialisierung und j = i * i und innerer while-Schleife)
    b   endif-02    //weglassen oder für Übersicht drin lassen?
    endif-02


# innere While-Schleife:
//while (j <= n):
//	sieb [j] = 1;  // sieb an der stelle 4 = 1 also keine primzahl
//	j = j + i;	   // inkrementieren


while-03
    cmp r_j, r_n
    bls do-03
    b   endwhile-03

do-03
    Anweisungsblock
    Inkrementierung der Laufvar.:  j = j + i
    b   while-03
endwhile-03


## Abspeichern-Methode:

lese nach und nach alle Einträge aus Feld "Sieb". Wenn Eintrag = 0, dann schreibe den Indize p dieses Eintrags in Feld "Primzahlen"
// k = 0;
// for (p = 2; p <= n; p++):
//  innere if-Bedingung: Probe auf Primzahl und ggf. Eintrag in Feld Primzahlen

# äußere for-Schleife
for_04 
    mov r_p, #2

until_04
    cmp r_p, r_n
    bhi enddo_04

do_04
    Anweisungsblock mit innerer if-Bedingung

step_04
    add r_p, #1         //Laufvariable inkrementieren
    b   until_04

enddo_04


# innere if-Bedingung
//if (sieb[p] == 0):
//      prim[k] = p;
//      k++;

if_05
    cmp sieb[p], #0
    beq     then_05
    b       endif_05

then_05
    Anweisungsblock
    Inkrementierung des Primzahlen-Eintrags-"Zeigers"

endif_05

