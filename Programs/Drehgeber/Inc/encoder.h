//encoder.h
//Auswertung Drehgebers:
//Phasenwechsel, Richtung, Zählen, Fehler erkennen

#ifndef ENCODER_H
#define ENCODER_H

#include "types.h"
#include <stdint.h>

//Startzustand , auch reset mit S6
void encoderInit(PhaseId startPhase, uint64_t startZeit);

//pro Superloop mit eingelesener Phase + Zeit aufrufen
void encoderUpdate(PhaseId phase, uint64_t zeit);

//Anzahl der Phasenwechsel (vorwärts +1, rückwärts -1), int32_t weil 1. kann negativ sein 2. kann groß sein
int32_t encoderGetCount(void);

//aktuelle drehrichtung
Direction encoderGetDirection(void);

//true, falls Phase übersprungen
bool encoderHasError(void);

//timestamp
uint64_t encoderGetCountTime(void);







#endif