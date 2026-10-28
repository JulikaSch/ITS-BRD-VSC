/**
 * @file scanner.c
 * @author Franz Korf, HAW Hamburg
 * @date Mar 2016
 *
 * @brief This module implements a simple scanner for keypad input.
 */

#include "scanner.h"
#include "display.h"
#include "keypad.h"
#include "token.h"

/*
 ****************************************************************************************
 * @brief : read next character from Touch Pad
 *
 *  @return Character read from touch pad.
 ****************************************************************************************/
inline static char next_char(void) { return getKeyPadInput(); }

T_token next_token(void) {
   // This scanner needs a lookahead of 1 to detect the end of a number token.
   // ' ' / ENTER will be handled as whitespace
   static char chr = ENTER; // next character according to lookahead of 1
   clear_echo_term();
   while (ENTER == chr) {
      chr = next_char();
   };

   T_token erg = {UNEXPECTED, 0};
   // analyse input character
   switch (chr) {
   case PLUS:
   case MINUS:
   case MULT:
   case DIV:
   case PRT:
   case SWAP:
   case PRT_ALL:
   case DOUBLE:
   case CLEAR:
      erg.tok = chr;
      chr = ENTER;
      break;
   case '0':
   case '1':
   case '2':
   case '3':
   case '4':
   case '5':
   case '6':
   case '7':
   case '8':
   case '9':
      erg.tok = NUMBER; // scan a number
      while (('0' <= chr) && (chr <= '9')) {
         print_to_echo_line(chr);
         const int BASE = 10;
         erg.val = (erg.val * BASE) + (chr - '0');
         if (erg.val < 0) { // Overflow
            erg.tok = OVERFLOW;
            erg.val = 0;
            return erg;
         }
         chr = next_char();
      }
      break;
   default: // unexpected input
      chr = ENTER;
   }
   return erg;
}
// EOF
