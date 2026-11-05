#ifndef STACK_H
#define STACK_H

#define STACK_SIZE 10


//gibt obertes Element zurück, ändert NICHT länge
int peek(const int stack[], int top, int depth, int *value);



//Element Hinzufügen
int push(int stack[], int *top, int value);


//Element Entfernen
int pop(const int stack[], int *top, int *value);

//C, löscht alle Einträge des Stacks
void clear(int *top);


#endif 