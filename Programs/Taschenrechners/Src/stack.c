#include "stack.h"

int peek(int stack[], int top){
    return stack[top];
}
   
int push(int stack[], int *top, int input){
    
    if(*top >= STACK_SIZE - 1){
        return -1 //overflow 
    }
    
    (*top)++;
    stack[*top] = input;
    return 0;
}


int pop(int *top){
    
    if(*top <= 0){
        return -1 //Underflow
    }

    (*top)--;
    return 0;
}
