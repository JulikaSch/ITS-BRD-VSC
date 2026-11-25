//Display.h

//Ausgabe von Winkel und Geschwindigkeit auf LCD
//Werte werden erst in Puffer geschrieben und dann ausgegeben!

#ifndef DISPLAY_H
#define DISPLAY_H

#include "types.h"

//0 = beide Werte aufeinmal ausgebem (vorher ca 108ms/Durchlauf)
//1 = pro displayProcess() nur ein Zeichen ausgeben
#define DISPLAY_ZEICHENWEISE 1

//Text einmal ausgeben, Puffer leeren
void displayInit(void);

//Neue Werte in Puffer Schreiben
void displaySetValues(double winkel, double speed);

//In jedem loop durchlauf ausführen.
//gibt aus Puffer ein Zeichen auf Display
//return true wenn Ausgabe
bool displayProcess(void);


#endif