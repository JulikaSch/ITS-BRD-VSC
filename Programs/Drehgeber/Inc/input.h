//input.h
//einlesen der Kanäle A und B

#ifndef INPUT_H
#define INPUT_H

#include "types.h"


//Liest Port F A,B,S6 Einmal ein und gibt Phase und Zustand von S6 und Zeitstempel zurück
//Muss häufig (min 47 s) aufegrufen werden, damit Zeit stimmt
InputData inputRead(void);

//Zeit auf 0
void inputInit(void);
#endif
