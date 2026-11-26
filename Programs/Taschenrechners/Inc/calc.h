#ifndef CALC_H
#define CALC_H


//nimmt zwei Werte vom Stack und legt deren Summe wieder auf dem Stack ab
int stack_add();

//nimmt zwei Werte vom Stack, subtrahiert vom zweiten Wert den ersten
// (oberen) Wert und legt das Ergebnis wieder auf dem Stack ab.
int stack_sub();

//nimmt zwei Werte vom Stack und legt deren Produkt wieder auf dem Stack ab.
int stack_mul();

//nimmt zwei Werte vom Stack, teilt den zweiten Wert durch den ersten
// (ganz-zahlige Division) und legt das Ergebnis wieder auf dem Stack ab.
int stack_div();



#endif 