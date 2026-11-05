#include "fehler.h"
#include "display.h"

void show_error(int error) {
   if (error == ERR_OK) {
      return;
   }
   set_err_mode();
   switch (error) {
   case ERR_STACK_OVERFLOW:
      print_stdout("Stack Overflow");
      break;
   case ERR_STACK_UNDERFLOW:
      print_stdout("Stack Underflow");
      break;
   case ERR_DIV_ZERO:
      print_stdout("Division durch 0");
      break;
   case ERR_RANGE:
      print_stdout("Bereichsueberschreitung");
      break;
   case ERR_INPUT_RANGE:
      print_stdout("Eingabe zu gross");
      break;
   default:
      print_stdout("Unbekannter Fehler");
      break;
   }
}
