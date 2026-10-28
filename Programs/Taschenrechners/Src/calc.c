#include "calc.h"

int stack_add(int stack[], int *top){
    int a, b;
    a = peek(stack, *top);
    pop(top);
    b = peek(stack, *top);
    pop(top);
    push(stack, top, a+b);
    return 0;
}

int stack_sub(int stack[], int *top){
    int a, b;
    a = peek(stack, *top);
    pop(top);
    b = peek(stack, *top);
    pop(top);
    push(stack, top, b-a);
    return 0;
}

int stack_mul(int stack[], int *top){
    int a, b;
    a = peek(stack, *top);
    pop(top);
    b = peek(stack, *top);
    pop(top);
    push(stack, top, a*b);
    return 0;
}

int stack_div(int stack[], int *top){
    int a, b;
    a = peek(stack, *top);
    pop(top);
    if (a = 0){
        return -1; //div durch 0
    }

    b = peek(stack, *top);
    pop(top);
    push(stack, top, b/a);
    return 0;
}