#include "calc.h"
#include "fehler.h"
#include "stack.h"
#include <limits.h>

int stack_add(int stack[], int *top){
    int a, b;
    if (a > 0 && b > INT_MAX - a) || (a < 0 && b < INT_MIN - a){  //overflow error
        return ERR_RANGE
    } else{
        a = peek(stack, *top);
        pop(top);
        b = peek(stack, *top);
        pop(top);
        push(stack, top, a+b);
        return 0;
    }
}

int stack_sub(int stack[], int *top){
    int a, b;
    if (a < 0 && b > INT_MAX + a) || (a > 0 && b < INT_MIN + a){  
        return ERR_RANGE;
    }else{

    a = peek(stack, *top);
    pop(top);
    b = peek(stack, *top);
    pop(top);
    push(stack, top, b-a);
    return 0;
    }
}

int stack_mul(int stack[], int *top){
    int a, b;
    //fehlereinfügen!
    a = peek(stack, *top);
    pop(top);
    b = peek(stack, *top);
    pop(top);
    push(stack, top, a*b);
    return 0;
}

int stack_div(int stack[], int *top){
    int a, b;
     //fehlereinfügen!
    a = peek(stack, *top);
    pop(top);
    if (a == 0){
        return -1; //div durch 0
    }

    b = peek(stack, *top);
    pop(top);
    push(stack, top, b/a);
    return 0;
}