//encoder.c

#include "encoder.h"
#include "types.h"
#include <stdbool.h>
#include <stdint.h>


//Zustand des Drehgebers
//Static, nur in dieser Datei, Wert muss erhalten bleiben!

static PhaseId altePhase = PHASE_A;
static int32_t count = 0;
static Direction richtung = DIR_UNKOWN;
static bool error = false ;


//Startzustand , auch reset mit S6
void encoderInit(PhaseId startPhase){
    altePhase = startPhase;
    count = 0;
    richtung = DIR_UNKOWN;
    error = false;
};

//pro Superloop mit eingelesener Phase aufrufen
void encoderUpdate(PhaseId phase){

    //fehler oder keine änderung
    if (error || (phase==altePhase)){
        return;
    }

    //+4 damit sol nicht negativ, erzeugt return 0 -> [1,2,3] == [vor,fehler,back]
    int diff = ((int)phase - (int)altePhase + 4) % 4;

    if(diff == 1){
        //vor
        count++;
        richtung = DIR_FORWARD;
    } else if(diff == 3){
        //back
        count--;
        richtung = DIR_BACKWARD;
    } else{
        error = true;
    }

    altePhase = phase;
}


//Anzahl der Phasenwechsel (vorwärts +1, rückwärts -1), int32_t weil 1. kann negativ sein 2. kann groß sein
int32_t encoderGetCount(void){
    return count;
}

//aktuelle drehrichtung
Direction encoderGetDirection(void){
    return richtung;
}

//true, falls Phase übersprungen
bool encoderHasError(void){
    return error;
}
