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
#include "calc.h"
#include "measure.h"
#include "display.h"

//Was Messpin PE0 anzeigt
//1 high wärend Display ausgabe. Impulsbreite = Displayausgabe
//2 wechselt in jedem Durchlauf. Abstand der Flanken = dauer Superloop
#define MESSPIN_MODUS 1

//Messung mit timer zusätzlich zu Display anzeigen
//1 an, für ohne Oszilloskop
//0 aus, fürs Lab
#define ZEIT_ANZEIGEN 1

#define TICKS_PRO_US (TICKS_PRO_SEKUNDE / 1000000ULL) //Timerticks in ms = 90

int main(void) {
  initITSboard(); // Initialisierung des ITS Boards

  GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
  ledInit();
  inputInit(); //Timer Starten
  measureInit(); //Messpin PE0
  displayInit(); //display init

  // Begruessungstext
  #if ZEIT_ANZEIGEN
  lcdGotoXY(0, 7);
  lcdPrintS("Display-Ausg. max:      us");
  lcdGotoXY(0, 8);
  lcdPrintS("Loop max ohne Disp.:    us");
  lcdGotoXY( 0, 9);
  lcdPrintS("Loop max mit Disp.:     us");
  #endif

  //Startzustand mit aktueller Phase + Zeit
  InputData start = inputRead();
  encoderInit(start.phase, start.zeit);
  calcInit(start.zeit, 0, start.zeit);
  displaySetValues(0.0, 0.0); //Startwärte in Puffer

 
  int fehlerAngezeigt = 0;

  //Zeitmessung
  uint64_t letzteLoopZeit = start.zeit;
  int letzterLoopMitDisplay = 0;
  int letzterLoopNichtZaehlen = 0; //Durchlauf mit Messwert Anzeige, nicht mitzählen
  uint64_t maxLoopOhneDisplay = 0;
  uint64_t maxLoopMitDisplay = 0;
  uint64_t maxDisplayDauer = 0;
  int messwerteAngezeigt = 0;
   
   
  while (1) {
    //1) Einlesen
    InputData eingabe = inputRead();

#if MESSPIN_MODUS == 2
    measuretoggle(); //jede Flanke = Beginn Durchlauf
#endif

    //Dauer letzter Durchlafu = Zeit zum Einlesen
    uint64_t loopDauer = eingabe.zeit - letzteLoopZeit;
    letzteLoopZeit = eingabe.zeit;
    if(letzterLoopNichtZaehlen == 0){
      if(letzterLoopMitDisplay == 1){
        if(loopDauer > maxLoopMitDisplay){
          maxLoopMitDisplay = loopDauer;
        }
      }else{
        if(loopDauer > maxLoopOhneDisplay){
          maxLoopOhneDisplay = loopDauer;
        }
      }
    }
    letzterLoopMitDisplay = 0;
    letzterLoopNichtZaehlen = 0;
    
    //2)Update
    //reset
    if(eingabe.resetGedrueckt){
      encoderInit(eingabe.phase, eingabe.zeit);
      calcInit(eingabe.zeit, 0, eingabe.zeit);
      ledShowError(false);
      displaySetValues(0.0, 0.0);
    
      //falls nötig fehlermeldung löschen
      if(fehlerAngezeigt == 1){
        lcdGotoXY(0,5);
        lcdPrintS("                                ");
        fehlerAngezeigt =0;
      }

      //Messwertezurücksetzen
      maxLoopMitDisplay = 0;
      maxLoopOhneDisplay = 0;
      maxDisplayDauer = 0;
      letzterLoopNichtZaehlen = 1; //reset nicht mit
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

      //neuer Wert alle 300ms in Puffer schreiben
     if(calcUpdate(eingabe.zeit,count,encoderGetCountTime())){
      displaySetValues(calcAngle(count), calcGetSpeed());
     }
    }

      

        //Messen der Display Ausgabe
#if MESSPIN_MODUS == 1
          measureHigh();
#endif
        uint64_t displayStart = inputRead().zeit; //Messung vor beginn

        bool ausgegeben = displayProcess();
    uint64_t displayDauer = inputRead().zeit - displayStart;
#if MESSPIN_MODUS == 1
    measureLow();
#endif
 
    if (ausgegeben) {
      letzterLoopMitDisplay = 1;
      if (displayDauer > maxDisplayDauer) {
        maxDisplayDauer = displayDauer;
      }
    }
 
#if ZEIT_ANZEIGEN
    // Messwerte erst nach 3 s ohne Phasenwechsel anzeigen. 
    // Dann dreht sich nichts, und durch die langsame Anzeige geht nichts verloren.
    bool stillstand = (eingabe.zeit - encoderGetCountTime()) >= (3ULL * TICKS_PRO_SEKUNDE);
 
    if (stillstand && messwerteAngezeigt == 0) {
      char text[16];
      snprintf(text, sizeof(text), "%6lu", (unsigned long)(maxDisplayDauer / TICKS_PRO_US));
      lcdGotoXY(19, 7);
      lcdPrintS(text);
      snprintf(text, sizeof(text), "%6lu", (unsigned long)(maxLoopOhneDisplay / TICKS_PRO_US));
      lcdGotoXY(19, 8);
      lcdPrintS(text);
      snprintf(text, sizeof(text), "%6lu", (unsigned long)(maxLoopMitDisplay / TICKS_PRO_US));
      lcdGotoXY(19, 9);
      lcdPrintS(text);
 
      messwerteAngezeigt = 1;
      letzterLoopNichtZaehlen = 1; // dieser lange Durchlauf zaehlt nicht
    }
    if (!stillstand) {
      messwerteAngezeigt = 0; // nach der naechsten Drehung wieder anzeigen
    }
#else
    (void)messwerteAngezeigt;
#endif
  }
}
 
// EOF