#include "stack.h"
#include "fehler.h"

//Element Hinzufügen
int push(int stack[], int *top, int value) {
   if (*top >= STACK_SIZE - 1) {
      return ERR_STACK_OVERFLOW;
   }
   (*top)++;
   stack[*top] = value;
   return ERR_OK;
}

//Element Entfernen
int pop(const int stack[], int *top, int *value) {
   if (*top < 0) {
      return ERR_STACK_UNDERFLOW;
   }
   *value = stack[*top];
   (*top)--;
   return ERR_OK;
}

//gibt obertes Element zurück, ändert NICHT länge
int peek(const int stack[], int top, int depth, int *value) {
   if (depth < 0 || top - depth < 0) {
      return ERR_STACK_UNDERFLOW;
   }
   *value = stack[top - depth];
   return ERR_OK;
}

void clear(int *top) {
    *top = -1;
}
