#include "operate.h"
#include "display.h"
#include "fehler.h"
#include "stack.h"
#include <stdio.h>

//p, druckt den obersten Wert des Stacks aus
int print_head(int stack[], int top){ //=p
    int val;
    char str[16];
    int error = peek(stack, top, 0, &val);
    if (error != ERR_OK) {
        return error; 
        }
    sprintf(str, "%d\n", val);
    print_stdout(str);
    return error;
}

//P, druckt die drei obersten Werte des Stacks aus
int print_3head(int stack[], int top){ //P vllt falsch
    int val[3];
    char str[16];
    for(int i=0; i<3; i++){
        //a=peek(stack, (top-i));
        int error = peek(stack, top, i, &val[i]);
        if (error != ERR_OK) {
         return error; 
        }
    }
    for (int i = 2; i >= 0; i--) {
        sprintf(str, "%d\n", val[i]);
        print_stdout(str);
    }
   return ERR_OK;

}

//d, dupliziert den obersten Eintrag des Stacks.
int dub_head(int stack[], int *top){ //d
    int val;
    int error = peek(stack, *top, 0, &val);
    if (error != ERR_OK) {
        return error;
    }

    error = push(stack, top, val);
    return error;
}

//r, vertauscht die Reihenfolge der beiden obersten Einträge des Stacks.
int swap_2head(int stack[], int top) {
   int a, b;
   int error = peek(stack, top, 0, &a);
   if (error != ERR_OK) {
      return error;
   }
   error = peek(stack, top, 1, &b);
   if (error != ERR_OK) {
      return error;
   }
   stack[top] = b;
   stack[top - 1] = a;
   return ERR_OK;
}
