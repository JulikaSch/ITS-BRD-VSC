#ifndef STACK_H
#define STACK_H

//gibt obertes Element zurück, ändert NICHT länge
int peek(int stack[], int top);


//Element Hinzufügen
int push(int stack[], int *top, int input);

//Element Entfernen
int pop(int *top);




#endif 