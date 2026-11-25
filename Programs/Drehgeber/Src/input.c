#include "input.h"
#include "stm32f4xx_hal.h"
#include "types.h"
#include <stdint.h>


//Pins
#define PIN_A 0U
#define PIN_B 1U
#define PIN_S6 6U

//Input A und B in Phase umwandeln, nach Tabelle
static PhaseId phaseAusAB(uint32_t a, uint32_t b){

    if (a == 0U && b == 0U){
        return PHASE_A;
    } else if (a == 1U && b == 0U) {
        return PHASE_B;
    } else if (a == 1U && b == 1U) {
        return PHASE_C;
    } else{             //a=0, b=1
        return PHASE_D;
    }
}
InputData inputRead(){
    //Port F nur einmal lesen
    uint32_t eingang = GPIOF->IDR;

    uint32_t a = (eingang >> PIN_A) & 0x01U; //nur das 0 Bit, Kanal A
    uint32_t b = (eingang >> PIN_B) & 0x01U; //Bit 1, Kanal B
    uint32_t s6 = (eingang >> PIN_S6) & 0x01U; //Bit 6, S6
    
    InputData daten;
    daten.phase = phaseAusAB(a, b);

    // 0 = S6 gedrückt, Taste low-aktive
    daten.resetGedrueckt = (s6 == 0U);
 
    return daten;
}