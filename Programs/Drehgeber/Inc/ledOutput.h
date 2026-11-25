


#ifndef LEDOUTPUT_H
#define LEDOUTPUT_H

#include "types.h"

//Initialisierung: Alle LEDs aus
void ledInit();


//Gibt 8 Bit Muster aus. Auf LED D8-D15
void ledShowPattern(uint8_t pattern);

//D23 Vorwärts, D22 Rückwärts, beide aus wenn unbekannt
void ledShowDirection(Direction richtung);

//D21 an ERROR
void ledShowError(bool fehler);


#endif
