
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
   init_display();

   GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
   TP_Init(false); // Initialisierung des LCD Boards mit Touch
; 

  
   
   //int stack[STACK_SIZE];  //Stack als Array,
   //int top = -1;           
   int error = ERR_OK;

   
   while(1){            //Dauerschleife, Token auslesen-> auswerten -> nächster
      T_token token = next_token();

      if (error != ERR_OK) {  //Fehler! <-? noch Aktuell?
         if (token.tok == CLEAR) { //checken ob c gedrückt wurde
            clear();
            set_normal_mode(); 
            error = ERR_OK;
         }
         continue;
      }

      switch (token.tok){
      case NUMBER:
         error = push(token.val); //richtig?
         break;
      case PLUS:
         error = stack_add();
         break;
      case MINUS:
         error = stack_sub();
         break;
      case MULT:
         error = stack_mul();
         break;
      case DIV:
         error = stack_div();
         break;
      case PRT:
         error = print_head();
         break;
      case PRT_ALL:
         error = print_3head();
         break;
      case DOUBLE:
         error = dub_head();
         break;
      case SWAP:
         error = swap_2head();
         break;
      case CLEAR:
         clear();
         break;
      case OVERFLOW:
         error = ERR_INPUT_RANGE;
         break;
      default:
         break;
      }
      
      show_error(error);
   }

}

// EOF
