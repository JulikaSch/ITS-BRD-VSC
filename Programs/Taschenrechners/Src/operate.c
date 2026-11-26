#include "operate.h"
#include "display.h"
#include "fehler.h"
#include "stack.h"
#include <stdio.h>

//p, druckt den obersten Wert des Stacks aus
int print_head(void){ //=p
    int val = 0;
    char str[16];
    int error = peek(0, &val);
    if (error != ERR_OK) {
        return error; 
        }
    snprintf(str, sizeof(str), "%d\n", val); //snprint to string, nur sizeof(str)
    print_stdout(str);
    return ERR_OK;
}

//P, druckt die drei obersten Werte des Stacks aus
int print_3head(void){ 
    int val[3];
    char str[16];
    int countval = 0;

    //erst 3 lesen falls in [2] = error
    for(int i=0; i<3; i++){
        
        int error = peek(i, &val[i]);
        if (error != ERR_OK) {
         return error; 
        }
        if (peek(i+1, &val[i]) != ERR_OK){
            break;
        }
        countval++;
    }
    for (int i = countval; i >= 0; i--) {
        snprintf(str, sizeof(str), "%d\n", val[i]);
        print_stdout(str);
    }
   return ERR_OK;

}

//d, dupliziert den obersten Eintrag des Stacks.
int dub_head(void){ //d
    int val = 0;
    int error = peek(0, &val);
    if (error != ERR_OK) {
        return error;
    }

    return push(val);
}

//r, vertauscht die Reihenfolge der beiden obersten Einträge des Stacks.
int swap_2head(void) {
    int a= 0;
    int b=0; 

    //prüfen ob 2 ele existieren
    int error = peek(1, &b);
    if (error != ERR_OK) {
        return error;
    }
    //pob a, b, dann swap
    pop(&a);
    pop(&b);
    push(a);
    return push(b);
}
