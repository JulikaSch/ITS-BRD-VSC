#ifndef STACK_H
#define STACK_H

#define STACK_SIZE 10 //Stack Länge


//gibt obertes Element zurück, ändert NICHT länge
int peek(int depth, int *value);



//Element Hinzufügen
int push(int value);


//Element Entfernen
int pop(int *value);

//C, löscht alle Einträge des Stacks
void clear();


#endif 