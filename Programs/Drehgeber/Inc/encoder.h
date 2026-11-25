//encoder.h
//Auswertung Drehgebers:
//Phasenwechsel, Richtung, Zählen, Fehler erkennen

#ifndef ENCODER_H
#define ENCODER_H

#include "types.h"

//Startzustand , auch reset mit S6
void encoderInit(PhaseId startPhase);

//pro Superloop mit eingelesener Phase aufrufen
void encoderUpdate(PhaseId phase);

//Anzahl der Phasenwechsel (vorwärts +1, rückwärts -1), int32_t weil 1. kann negativ sein 2. kann groß sein
int32_t encoderGetCount(void);

//aktuelle drehrichtung
Direction encoderGetDirection(void);

//true, falls Phase übersprungen
bool encoderHasError(void);







#endif