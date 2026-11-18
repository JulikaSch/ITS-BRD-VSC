#include "input.h"
#include "stm32f4xx_hal.h"
#include "types.h"


PhaseId inputReadPhase(){
    //Port F nur einmal lesen
    uint32_t eingang = GPIOF->IDR;

    int a = eingang & 0x01; //nur das 0 Bit, Kanal A
    int b = (eingang >> 1) & 0x01; //Bit 1, Kanal B

    //gibt nach Tabelle Phase zurück
    if (a == 0 && b == 0){
        return PHASE_A;
    } else if (a == 1 && b == 0) {
        return PHASE_B;
    } else if (a == 1 && b == 1) {
        return PHASE_C;
    } else{             //a=0, b=1
        return PHASE_D;
    }
}