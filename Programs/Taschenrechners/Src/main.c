/**
 ******************************************************************************
 * @file    main.c
 * @author  Franz Korf
 * @brief   Kleines Testprogramm fuer neu erstelle Fonts.
 ******************************************************************************
 */
/* Includes ------------------------------------------------------------------*/

#include "LCD_GUI.h"
#include "LCD_Touch.h"
#include "init.h"
#include "lcd.h"
#include "stm32f4xx_hal.h"

#include "calc.h"
#include "display.h"
#include "operate.h"
#include "scanner.h"
#include "stack.h"
#include "token.h"
#include "fehler.h"


int main(void) {
   initITSboard(); // Initialisierung des ITS Boards

   GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
   TP_Init(false); // Initialisierung des LCD Boards mit Touch

   // Begruessungstext
   lcdPrintlnS("Hallo liebes TI-Labor (c-project)");

   // Test in Endlosschleife
  /* const int POLL_DELAY = 10000;
   while (1) {
      HAL_Delay(POLL_DELAY);
   }
   */
   int stack[STACK_SIZE];
   int top = -1;
   int error = ERR_OK;

   
   while(1){ //unsicher!, unfertig!
      T_token token = next_token();

      if (error != ERR_OK) {  //Fehler!
         if (token.tok == CLEAR) { //checken ob c gedrückt wurde
            clear(&top);
            set_normal_mode(); 
            error = ERR_OK;
         }
         continue;
      }

      switch (token.tok){
      case NUMBER:
         error = push(stack, &top, token.val); //richtig?
         break;
      case PLUS:
         error = stack_add(stack, &top);
         break;
      case MINUS:
         error = stack_sub(stack, &top);
         break;
      case MULT:
         error = stack_mul(stack, &top);
         break;
      case DIV:
         error = stack_div(stack, &top);
         break;
      case PRT:
         error = print_head(stack, top);
         break;
      case PRT_ALL:
         error = print_3head(stack, top);
         break;
      case DOUBLE:
         error = dub_head(stack, &top);
         break;
      case SWAP:
         error = swap_2head(stack, top);
         break;
      case CLEAR:
         clear(&top);
         break;
      case OVERFLOW:
         error = ERR_INPUT_RANGE;
         break;
      }

      show_error(error);
   }

}

// EOF
