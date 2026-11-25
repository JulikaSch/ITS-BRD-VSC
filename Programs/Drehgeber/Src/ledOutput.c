
#include "ledOutput.h"
#include "stm32f4xx_hal.h" //Muss eingebunden sein. Auch in P1 verwendet
#include "types.h"


#define LED_D21 5U  //PE5 ERROR
#define LED_D22 6U  //PE6 rückwärts
#define LED_D23 7U  //PE7 Vorwärts



//Initialisierung: Alle LEDs aus
//Initialisierung auf 0000 0000
void ledInit(void){
    ledShowPattern(0x00U);
    ledShowDirection(DIR_UNKNOWN);
    ledShowError(false);
}

//Gibt 8 Bit Muster aus. Auf LED D8-D15
void ledShowPattern(uint8_t pattern){
    /*set = welche Leds gehen an
    reset = welche LEDs gehen aus
    */
    uint32_t set = (uint32_t) pattern;
    uint32_t reset = (uint32_t)((uint8_t) ~pattern) << 16U; //~bitweises not, <<16U verschieben nach links, an der Stelle für BSRR benötigt
    GPIOD->BSRR = set | reset;  //|bitweises oder, GPIOD Hardware D LEDs, BSSR Register
}
//D23 Vorwärts, D22 Rückwärts, beide aus wenn unbekann
void ledShowDirection(Direction richtung){
    if(richtung == DIR_FORWARD){
        //D23 an, D22 aus
        GPIOE->BSRR = (1U << (LED_D23)) | (1U << (LED_D22 + 16U));  //16U bits zum ausschalten, siehe BSSR Register
    } else if(richtung == DIR_BACKWARD){
        //D23 aus, D22 an 
        GPIOE->BSRR = (1U << (LED_D22)) | (1U << (LED_D23 + 16U));
    } else{
        //beide aus
        GPIOE->BSRR = (1U << (LED_D22 + 16U)) | (1U << (LED_D23 + 16U));
    }
}

//D21 an ERROR
void ledShowError(bool fehler){
    if(fehler){
        GPIOE->BSRR = (1U << LED_D21); //D21 an
    } else{
         GPIOE->BSRR = (1U << (LED_D21 + 16U)); //D21 aus
    }
}