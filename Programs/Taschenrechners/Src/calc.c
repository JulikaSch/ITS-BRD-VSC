#include "calc.h"
#include "fehler.h"
#include "stack.h"
#include <limits.h>

//liest die obersten beiden Values auf Stack aus
int get_operands(const int stack[], int top, int *a, int *b) {
    int error = peek(stack, top, 0, a);
    if (error != ERR_OK) {
        return error;
    }
    return peek(stack, top, 1, b);
}

//nimmt die oberste 2 Stack Werte und pusht ein neues, hier für operationen zb a+b
int replace_operands(int stack[], int *top, int result) {
    int temp;
   int error = pop(stack, top, &temp);
   if (error == ERR_OK) {
      error = pop(stack, top, &temp);
   }
   if (error == ERR_OK) {
      error = push(stack, top, result);
   }
   return error;
}

//nimmt zwei Werte vom Stack und legt deren Summe wieder auf dem Stack ab
int stack_add(int stack[], int *top){
    int a, b;
    int error = get_operands(stack, *top, &a, &b);
    if (error != ERR_OK) {
        return error;
    }
    if ((a > 0 && b > INT_MAX - a) || (a < 0 && b < INT_MIN - a)){  //overflow error
        return ERR_RANGE;
    }else{
        error = replace_operands(stack, top, a+b);
        return error;
    }
}

//nimmt zwei Werte vom Stack, subtrahiert vom zweiten Wert den ersten
// (oberen) Wert und legt das Ergebnis wieder auf dem Stack ab.
int stack_sub(int stack[], int *top){
    int a, b;
    int error = get_operands(stack, *top, &a, &b);
    if (error != ERR_OK) {
      return error;
    }
    if ((a < 0 && b > INT_MAX + a) || (a > 0 && b < INT_MIN + a)){  
        return ERR_RANGE;
    }else{
        error= replace_operands(stack, top, b-a);
        return error;
    }
}

//nimmt zwei Werte vom Stack und legt deren Produkt wieder auf dem Stack ab.
int stack_mul(int stack[], int *top){
    int a, b;
    //fehlereinfügen!
    int error = get_operands(stack, *top, &a, &b);
    if (error != ERR_OK) {
        return error;
    }else{
        error=replace_operands(stack, top, a*b);
        return error;
    }
}

//nimmt zwei Werte vom Stack, teilt den zweiten Wert durch den ersten
// (ganz-zahlige Division) und legt das Ergebnis wieder auf dem Stack ab.
int stack_div(int stack[], int *top){
    int a, b;
     //fehlereinfügen!
    int error = get_operands(stack, *top, &a, &b);
    if (error != ERR_OK) {
        return error;
    }else if(a==0){
        return ERR_DIV_ZERO;
    }else{
        error = replace_operands(stack, top, b/a);
        return error;
    }
}