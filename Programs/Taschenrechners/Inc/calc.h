#ifndef CALC_H
#define CALC_H

//nimmt zwei Werte vom Stack und legt deren Summe wieder auf dem Stack ab
int stack_add(int stack[], int *top);

//nimmt zwei Werte vom Stack, subtrahiert vom zweiten Wert den ersten
// (oberen) Wert und legt das Ergebnis wieder auf dem Stack ab.
int stack_sub(int stack[], int *top);

//nimmt zwei Werte vom Stack und legt deren Produkt wieder auf dem Stack ab.
int stack_mul(int stack[], int *top);

//nimmt zwei Werte vom Stack, teilt den zweiten Wert durch den ersten
// (ganz-zahlige Division) und legt das Ergebnis wieder auf dem Stack ab.
int stack_div(int stack[], int *top);



#endif 