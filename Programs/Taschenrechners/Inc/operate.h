#ifndef OPERATE_H
#define OPERATE_H

//p, druckt den obersten Wert des Stacks aus
int print_head(int stack[], int top);

//P, druckt die drei obersten Werte des Stacks aus
int print_3head(int stack[], int top);

//C, löscht alle Einträge des Stacks
int clear(int *top);

//d, dupliziert den obersten Eintrag des Stacks.
int dub_head(int stack[], int *top);

//r, vertauscht die Reihenfolge der beiden obersten Einträge des Stacks.
int swap_2head(int stack[], int top);



#endif 