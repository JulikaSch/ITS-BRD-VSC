//calc.h
//berechnungen Winkel und Geschwindigkeit

#ifndef CALC_H
#define CALC_H

#include "types.h"
#include <stdint.h>

//Startzustand + S6 , Geschwindigkeit = 0
void calcInit(uint64_t jetzt, int32_t count, uint64_t countZeit);

//Winkel in Grad (1200 Phasenwächsel = 360 grad)
double calcAngle(int32_t count);

//prüft ob neue geschwindigkeit berechnet werden muss. frühestens alle 300ms.
bool calcUpdate(uint64_t jetzt, int32_t count, uint64_t countZeit);

//Winkelgeschwindigkeit in Grad pro Sekunde
double calcGetSpeed(void);


#endif