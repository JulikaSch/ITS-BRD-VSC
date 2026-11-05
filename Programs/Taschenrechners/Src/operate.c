#include "operate.h"
#include "display.h"
#include "fehler.h"
#include "stack.h"
#include <stdio.h>

int print_head(int stack[], int top){ //=p
    int val;
    char str[10];
    int error = peek(stack, top, 0, &val);
    sprintf(str, "%d\n", val);
    print_stdout(str);
    return 0;
}

int print_3head(int stack[], int top){ //P vllt falsch
    int val[3];
    char str[10];
    for(int i=0; i<3; i++){
        //a=peek(stack, (top-i));
        int error = peek(stack, top, i, &val[i]);
        if (error != ERR_OK) {
         return error; 
        }
    for (int i = 2; i >= 0; i--) {
        sprintf(str, "%d\n", val[i]);
        print_stdout(str);
   }
   return ERR_OK;


int dub_head(int stack[], int *top){ //d
    int val;
    int error = peek(stack, *top, 0, &val);
    if (error != ERR_OK) {
        return error;
    }

    push(stack, top, val);
    return ERR_OK;
}



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
