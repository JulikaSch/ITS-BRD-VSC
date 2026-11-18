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

#include "input.h"
#include "ledOutput.h"
#include "types.h"

int main(void) {
   initITSboard(); // Initialisierung des ITS Boards

   GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
   ledInit();

   // Begruessungstext
   lcdGotoXY(0, 0);
   lcdPrintS("Hardware-Test");
   lcdGotoXY(0, 2);
   lcdPrintS("Phase:");
   
   PhaseId altePhase = PHASE_A;
   int ersterDurchlauf = 1;
   
   
   while (1) {
     //1) Einlesen
     PhaseId phase = inptutReadPhase();

     //Ausgabe Phase auf LEDs
     ledShowPattern(phase);

     if(phase != altePhase || ersterDurchlauf == 1){
      char text[2] = "a";
      text[0] = 'a' + phase; // phase int -> char
      
      lcdGotoXY(7, 2);
      lcdPrintS(text);
      altePhase = phase;
      ersterDurchlauf = 0;
     }

   }
}

// EOF
