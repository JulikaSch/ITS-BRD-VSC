
#include "calc.h"
#include "types.h"
#include <stdbool.h>
#include <stdint.h>

#define PHASENWECHSEL_PRO_UMDREHUNG 1200.0 //300 Schlitze * 4 Phasen
#define GRAD_PRO_UMDREHUNG 360.0

#define FENSTER_TICKS (TICKS_PRO_SEKUNDE *3ULL / 10ULL) //300ms, ULL = long long 64bit
#define MAX_WARTEN_TICKS (TICKS_PRO_SEKUNDE * 3ULL) //3s


//Letzte Berechnung
static uint64_t letzteBerechnung = 0;   //wann letzte berechnung
static int32_t letzterCount = 0;
static uint64_t letzteCountZeit = 0;   //Zeitstempel
static double speed = 0.0;

//Startzustand + S6 , Geschwindigkeit = 0
void calcInit(uint64_t jetzt, int32_t count, uint64_t countZeit){
    letzteBerechnung = jetzt;
    letzterCount = count;
    letzteCountZeit = countZeit;
    speed = 0.0;
}

//Winkel in Grad (1200 Phasenwächsel = 360 grad)
double calcAngle(int32_t count){
    //erst mul dann div
    return (double)count * GRAD_PRO_UMDREHUNG / PHASENWECHSEL_PRO_UMDREHUNG;
}

//prüft ob neue geschwindigkeit berechnet werden muss. frühestens alle 300ms.
bool calcUpdate(uint64_t jetzt, int32_t count, uint64_t countZeit){
    uint64_t seitLetzterBerechnung = jetzt - letzteBerechnung;

    //noch keine 300ms rum, nix machen
    if(seitLetzterBerechnung < FENSTER_TICKS){
        return false;
    }

    if(count != letzterCount){
        //wenn count update -> speed berechnen
        double winkelDiff = calcAngle(count) - calcAngle(letzterCount);
        double zeitDiff = (double) (countZeit - letzteCountZeit) /(double) TICKS_PRO_SEKUNDE;
        speed = winkelDiff / zeitDiff;
    } else if(seitLetzterBerechnung >= MAX_WARTEN_TICKS){
        //3s kein Phasenwechsel -> Still
        speed = 0.0;
    } else{
        // weiter warten
        return false;
    }

    letzteBerechnung = jetzt;
    letzterCount = count;
    letzteCountZeit = countZeit;
    return true;
}

//Winkelgeschwindigkeit in Grad pro Sekunde
double calcGetSpeed(void){
    return speed;
}
