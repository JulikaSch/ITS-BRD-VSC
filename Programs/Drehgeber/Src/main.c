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
#include <stdio.h>

#include "input.h"
#include "ledOutput.h"
#include "types.h"
#include "encoder.h"
#include "calc.h"

int main(void) {
  initITSboard(); // Initialisierung des ITS Boards

  GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
  ledInit();
  inputInit(); //Timer Starten

  // Begruessungstext
  lcdGotoXY(0, 0);
  lcdPrintS("Drehgeber");
  lcdGotoXY(0, 2);
  lcdPrintS("Winkel:             Grad");
  lcdGotoXY( 0, 3);
  lcdPrintS("Geschw.:            Grad/s");

  //Startzustand mit aktueller Phase + Zeit
  InputData start = inputRead();
  encoderInit(start.phase, start.zeit);
  calcInit(start.zeit, 0, start.zeit);

  int displayNeu = 1; //Display einmalig aufjedenfall beschreiben
  int fehlerAngezeigt = 0;
   
   
  while (1) {
    //1) Einlesen
    InputData eingabe = inputRead();

    //2)Update
    //reset
    if(eingabe.resetGedrueckt){
      encoderInit(eingabe.phase, eingabe.zeit);
      calcInit(eingabe.zeit, 0, eingabe.zeit);
      ledShowError(false);
    
      //falls nötig fehlermeldung löschen
      if(fehlerAngezeigt == 1){
        lcdGotoXY(0,5);
        lcdPrintS("                                ");
        fehlerAngezeigt =0;
      }
      displayNeu = 1;
    } else{
      encoderUpdate(eingabe.phase, eingabe.zeit);
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

      bool neuerWert = calcUpdate(eingabe.zeit, count, encoderGetCountTime());

      //Display updaten WENN count geändert
      if(neuerWert || displayNeu){
        char text[16];
        //wandelt angle in text um
        snprintf(text, sizeof(text), "%10.1f", calcAngle(count));
        lcdGotoXY(9, 2);
        lcdPrintS(text);
        //speed
        snprintf(text, sizeof(text), "%10.1f", calcGetSpeed());
        lcdGotoXY(9, 3);
        lcdPrintS(text);

        displayNeu = 0;
      }
    }
 
  }
}

// EOF
