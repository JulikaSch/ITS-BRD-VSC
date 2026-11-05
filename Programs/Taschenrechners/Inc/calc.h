#ifndef CALC_H
#define CALC_H

//liest die obersten beiden Values auf Stack aus
int get_operands(const int stack[], int top, int *a, int *b);

//nimmt die oberste 2 Stack Werte und pusht ein neues, hier für operationen zb a+b
int get_operands(const int stack[], int top, int *a, int *b);

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