#include "operate.h"
//hier als printf?

int print_head(int stack[], int top){ //=p
    int a;
    a=peek(stack, top);
    printf("%d\n", a);
    return 0;
}

int print_3head(int stack[], int top){ //P
    int i, a;
    for(i=0; i<3; i++){
        a=peek(stack, (top-i));
        printf("%d\n",a); //printf korrekt??
    }
    return 0;
}

int clear(int *top){ 
    *top = -1;
    return 0;
}

int dub_head(int stack[], int *top){ //d
    int a;
    a = stack[top];
    push(stack, top, a)
    return 0;
}

int swap_2head(int stack[], int top){   //r
    int a;
    a = stack[top];
    stack[top] = stack[top-1];
    stack[top-1] = a; 
    return 0;
} 