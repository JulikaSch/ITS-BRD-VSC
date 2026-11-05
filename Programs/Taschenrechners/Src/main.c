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

#define STACK_SIZE 5 //Willkührlich gewählt

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
   int a; //guter Name finden

   while(1){ //unsicher!, unfertig!
      T_token token = next_token();
      switch (token.tok){
      case NUMBER:
         a = push(stack, &top, token.val); //richtig?
         break;
      case PLUS:
         a = stack_add(stack, &top);
         break;
      case MINUS:
         a = stack_sub(stack, &top);
         break;
      case MULT:
         a = stack_mul(stack, &top);
         break;
      case DIV:
         a = stack_div(stack, &top);
      case PRT:
         a = print_head(stack, top);
         break;
      case PRT_ALL:
         a = print_3head(stack, top);
         break;
      case DOUBLE:
         a = dub_head(stack, &top);
         break;
      case SWAP:
         a = swap_2head(stack, top);
         break;
      case CLEAR:
         clear(&top);
         break;
      case OVERFLOW:
         print_stdout("Stack Overflow");
      break;
      }
   }

}

// EOF
