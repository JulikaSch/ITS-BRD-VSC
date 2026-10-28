#include "operate.h"
#include "stack.h"
#include "display.h"
#include "stdio.h"


int print_head(int stack[], int top){ //=p
    int a;
    char str[10];
    a=peek(stack, top);
    sprintf(str, "%d\n", a);
    print_stdout(str);
    return 0;
}

int print_3head(int stack[], int top){ //P vllt falsch
    int i, a;
    char str[10];
    for(i=0; i<3; i++){
        a=peek(stack, (top-i));
        printf("%d\n",a);
        sprintf(str, "%d\n", a);
        print_stdout(str);
    }
    return 0;
}

int clear(int *top){ 
    *top = -1;
    return 0;
}

int dub_head(int stack[], int *top){ //d
    int a;
    a = stack[*top];
    push(stack, top, a);
    return 0;
}

int swap_2head(int stack[], int top){   //r
    int a;
    a = stack[top];
    stack[top] = stack[top-1];
    stack[top-1] = a; 
    return 0;
} 