/**
 * @file display.c
 * @author Franz Korf, HAW Hamburg
 * @date Mar 2016
 * @brief This modules implements a simple output module.
 *        It places two terminals in the terminal area of keypad.
 *        One terminal will be used for standard output. The other one
 *        echos pressed digit keys.
 */

#include "display.h"
#include "LCD_GUI.h"
#include "LCD_Touch.h"
#include "keypad.h"
#include "terminal.h"
#include <stdlib.h>

static Terminal stdout_term = INVALID_TERM;
static Terminal echo_term = INVALID_TERM;

void clear_stdout(void) { clearTerm(&stdout_term); }

void clear_echo_term(void) { clearTerm(&echo_term); }

void print_stdout(char *msg) { printTerm(msg, &stdout_term); }

void init_display(void) {
   GUI_init(DEFAULT_BRIGHTNESS); // Initialisierung des LCD Boards mit Touch
   TP_Init(false);               // Initialisierung des LCD Boards mit Touch
   Terminal term = makeKeyPad();
   // Replace terminal by two terminals. One for standard output and
   // one to echo entered digits.
   Coordinate cor = term.bottomRight;
   cor.y = cor.y - term.font->Height - 1;
   stdout_term =
       genTerm(term.topLeft, cor, term.bgColor, term.fgColor, term.font);
   cor = term.topLeft;
   cor.y = term.bottomRight.y - term.font->Height;
   echo_term = genTerm(cor, term.bottomRight, BLUE, YELLOW, term.font);
   clear_echo_term();
   clear_stdout();
}

void print_to_echo_line(char chr) {
   char buf[2] = {'\0', '\0'};
   buf[0] = chr;
   printTerm(buf, &echo_term);
}

void set_err_mode(void) {
   clearTerm(&stdout_term);
   setTextColorTerm(RED, &stdout_term);
}

void set_normal_mode(void) {
   clearTerm(&stdout_term);
   setTextColorTerm(BLACK, &stdout_term);
}

bool is_bottom_line(void) {
   return getCurRow(&stdout_term) + 1 == getNoOfRows(&stdout_term);
}

// EOF
