/**
 ******************************************************************************
 * @file    main.c
 * @author  Jakob Giese
 * @brief  Praktikum 2
 ******************************************************************************
 */
/* Includes ------------------------------------------------------------------*/

#include "LCD_GUI.h"
#include "init.h"
#include "lcd.h"
#include "stm32f4xx_hal.h"
#include <stdint.h>
#include <stdio.h>

#include "input.h"
#include "ledOutput.h"
#include "types.h"
#include "encoder.h"

int main(void) {
  initITSboard(); // Initialisierung des ITS Boards

  GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
  ledInit();

  // Begruessungstext
  lcdGotoXY(0, 0);
  lcdPrintS("Zaehler Test");
  lcdGotoXY(0, 2);
  lcdPrintS("Zaehler:");
  lcdGotoXY( 0, 3);
  lcdPrintS("Richtung");

  encoderInit(inputRead().phase);

  int32_t oldCount = 0;
  int ersterDurchlauf = 1;
  int fehlerAngezeigt = 0;
   
   
  while (1) {
    //1) Einlesen
    InputData eingabe = inputRead();

    //2)Update
    //reset
    if(eingabe.resetGedrueckt){
      encoderInit(eingabe.phase);
      ledShowError(false);
    
      //falls nötig fehlermeldung löschen
      if(fehlerAngezeigt == 1){
        lcdGotoXY(0,5);
        lcdPrintS("                                ");
        fehlerAngezeigt =0;
      }
      ersterDurchlauf = 1;
    } else{
      encoderUpdate(eingabe.phase);
    }

    //3)ausgeben
    if(encoderHasError()){
      //fehlernur einmal anzeigen
      if(fehlerAngezeigt == 0){
        ledShowError(true);
        lcdGotoXY(0,5);
        lcdPrintS("ERROR: Phase wurde uebersprungen");
        fehlerAngezeigt = 1;
      }
    }else{
      int32_t count = encoderGetCount();
    
      //untere 8 count bits auf D8-D15
      ledShowPattern((uint8_t) (count & 0xFF) );

      //D22 oder D23
      ledShowDirection(encoderGetDirection());


      //Display updaten WENN count geändert
      if(count != oldCount || ersterDurchlauf == 1){
        char text[16];
        //wandelt count in text um
        snprintf(text, sizeof(text), "%6d", (int)count);
        lcdGotoXY(10, 2);
        lcdPrintS(text);

        lcdGotoXY(10, 3);
        if(encoderGetDirection() == DIR_FORWARD){
          lcdPrintS("vorwaerts  ");
        } else if(encoderGetDirection() == DIR_BACKWARD){
          lcdPrintS("rueckwaerts");
        } else{
          lcdPrintS("unbekannt  ");
        }

        oldCount=count;
        ersterDurchlauf=0;
      }
    }
 
  }
}

// EOF
