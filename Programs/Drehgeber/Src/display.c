//display.c
#include "display.h"
#include "lcd.h"
#include <stdio.h>

#define SPALTE_WERT 9 //ab da Zahlen
#define ZEILE_WINKEL 2
#define ZEILE_SPEED 3
#define BREITE 10 //%10.1f
#define ANZAHL_ZEICHEN (2*BREITE) //Winkel + Velo

//Buffer: 0-9 Winkel, 10-19 Geschwindigkeit
// +1 da \0
static char pufferWinkel[BREITE + 1];
static char pufferSpeed[BREITE + 1];

//welches Zeichen als nächstes, 20 = alles ausgeben
static int naechstesZeichen = ANZAHL_ZEICHEN;

//Hilfsfunc Zahl formatieren und #BREITE in den Buffer kopieren
static void zahlInPuffer(char *puffer, double wert){
    char text[32];
    snprintf(text, sizeof(text), "10.1f", wert);
    for (int i=0;i< BREITE; i++){
        puffer[i] = text[i];
    }
    puffer[BREITE] = '\0';
}

//Text einmal ausgeben, Puffer leeren
void displayInit(void){
    lcdGotoXY(0,0);
    lcdPrintS("Drehgeber");
    lcdGotoXY(0, ZEILE_WINKEL);
    lcdPrintS("Winkel:             Grad");
    lcdGotoXY(0, ZEILE_SPEED);
    lcdPrintS("Geschw.:            Grad/s");

    naechstesZeichen = ANZAHL_ZEICHEN;//nichts auszugeben
}

//Neue Werte in Puffer Schreiben
void displaySetValues(double winkel, double speed){
    //Nur in Puffer, noch nicht printen
    zahlInPuffer(pufferWinkel, winkel);
    zahlInPuffer(pufferSpeed, speed);

    naechstesZeichen = 0; //von vorn
}

//In jedem loop durchlauf ausführen.
//gibt aus Puffer ein Zeichen auf Display
//return true wenn Ausgabe
bool displayProcess(void){
    //puffer leer, zurück
    if(naechstesZeichen >= ANZAHL_ZEICHEN){
        return false;
    }

    #if DISPLAY_ZEICHENWEISE
        //Ein Zeichen Ausgeben!
        char zeichen[2];
        int zeile;
        int spalte;

        if(naechstesZeichen < BREITE){
            //gehört zu Winkel
            zeichen[0] = pufferWinkel[naechstesZeichen];
            zeile = ZEILE_WINKEL;
            spalte = SPALTE_WERT + naechstesZeichen;
        } else{
            //gehört zu Geschwindigkeit
            zeichen[0] = pufferSpeed[naechstesZeichen - BREITE];
            zeile = ZEILE_SPEED;
            spalte = SPALTE_WERT + (naechstesZeichen - BREITE);
        }
        zeichen[1] = '\0';

        lcdGotoXY(spalte, zeile);
        lcdPrintS(zeichen);
        naechstesZeichen++;

        #else
        //Vorher; beide zeichen auf einmalausgeben

        lcdGotoXY(SPALTE_WERT, ZEILE_WINKEL);
        lcdPrintS(pufferWinkel);
        lcdGotoXY(SPALTE_WERT, ZEILE_SPEED);
        lcdPrintS(pufferSpeed);
        naechstesZeichen=ANZAHL_ZEICHEN;
        #endif

        return 0;
}