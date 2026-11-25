//measure.c

#include "measure.h"
#include "stm32f4xx_hal.h"

#define PIN_MESS 0U //PG0 = AUX0


//PG0 als Ausgang, auf low setzen
void measureInit(void){
    measureLow();
}

//PG0 auf High 1
void measureHigh(void){
    GPIOE->BSRR = (1U << PIN_MESS);
}

//auf low 0
void measureLow(void){
    GPIOE->BSRR = (1U << (PIN_MESS + 16U)); //Pin Aus
}

//umschalten (high -> low, low -> high)
void measuretoggle(void){
    //ODR = AKtueller Zusatand
    if ((GPIOE->ODR & (1U << PIN_MESS)) != 0U){
        measureLow();
    } else{
        measureHigh();
    }
}