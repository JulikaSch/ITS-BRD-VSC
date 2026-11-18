
#include "../Inc/ledOutput.h"
#include "stm32f4xx_hal.h" //Muss eingebunden sein. Auch in P1 verwendet
#include <stdint.h>         //DOPPELTER INCLUDE SPÄTER ENTFERNEN


//Initialisierung auf 0000 0000
void ledInit(void){
    ledShowPattern(0x00U);
}

void ledShowPattern(uint8_t pattern){
    /*set = welche Leds gehen an
    reset = welche LEDs gehen aus
    */
    uint32_t set = (uint32_t) pattern;
    uint32_t reset = (uint32_t)((uint8_t) ~pattern) << 16U; //~bitweises not, <<16U verschieben nach links, an der Stelle für BSRR benötigt
    GPIOD->BSRR = set | reset;  //|bitweises oder, GPIOD Hardware D LEDs, BSSR Register
}
