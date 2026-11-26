#include "calc.h"
#include "fehler.h"
#include "stack.h"
#include <limits.h>

//liest die obersten beiden Values auf Stack aus
//NOLINT(readability-identifier-length)
int get_operands(int *a, int *b) {
    int error = peek(0, a);
    if (error != ERR_OK) {
        return error;
    }
    return peek(1, b);
}

//nimmt die oberste 2 Stack Werte und pusht ein neues, hier für operationen zb a+b
int replace_operands(int result) {
    int temp = 0;
   int error = pop(&temp);
   if (error == ERR_OK) {
      error = pop(&temp);
   }
   if (error == ERR_OK) {
      error = push(result);
   }
   return error;
}

//nimmt zwei Werte vom Stack und legt deren Summe wieder auf dem Stack ab
int stack_add(void){
    int a = 0;
    int b = 0;
    int error = get_operands(&a, &b);
    if (error != ERR_OK) {
        return error;
    }
    if ((a > 0 && b > INT_MAX - a) || (a < 0 && b < INT_MIN - a)){  //overflow error
        return ERR_RANGE;
    }
    error = replace_operands(b + a);
    return error;
    
}

//nimmt zwei Werte vom Stack, subtrahiert vom zweiten Wert den ersten
// (oberen) Wert und legt das Ergebnis wieder auf dem Stack ab.
int stack_sub(void){
    int a = 0;
    int b = 0;
    int error = get_operands( &a, &b);
    if (error != ERR_OK) {
      return error;
    }
    //
    if ((a < 0 && b > INT_MAX + a) || (a > 0 && b < INT_MIN + a)){  
        return ERR_RANGE;
    }
    error= replace_operands(b-a);
    return error;
}

//nimmt zwei Werte vom Stack und legt deren Produkt wieder auf dem Stack ab.
int stack_mul(void){
    int a=0;
    int b=0;
    int error = get_operands( &a, &b);
    if (error != ERR_OK) {
        return error;
    }

    //error handling
    if(a > 0){
        if(b > 0){  //+*+=+
            if(a> INT_MAX/b){
                return ERR_RANGE;
            }
        } else {    //+*-=-     b<=0
            if(b< INT_MIN /a){
                return ERR_RANGE;
            }
        }
    } else{
        if(b>0){    //-*+=-     a<=0
            if(a < INT_MIN / b){
                return ERR_RANGE;
            }
        } else{ // -*-=+        a<=0, b<=0
            if(a != 0 && b < INT_MAX / a){
                return ERR_RANGE;
            }
        }
    }
    return replace_operands(b*a);
}

//nimmt zwei Werte vom Stack, teilt den zweiten Wert durch den ersten
// (ganz-zahlige Division) und legt das Ergebnis wieder auf dem Stack ab.
int stack_div(){
    int a=0;
    int b=0;
    int error = get_operands(&a, &b);
    
    if (error != ERR_OK) {
        return error;
    }
    if(a==0){
        return ERR_DIV_ZERO;
    }
    //INT_MIN/-1 = INTMAX +1 
    if(b == INT_MIN && a == -1){
        return ERR_RANGE;
    }
    return replace_operands(b / a);
}