#include "stack.h"
#include "fehler.h"


//Stack
static int stack[STACK_SIZE];
static int top = -1;

//Element Hinzufügen
int push(int val) {
   if (top >= STACK_SIZE - 1) {
      return ERR_STACK_OVERFLOW;
   }
   top++;
   stack[top] = val;
   return ERR_OK;
}

//Element Entfernen
int pop(int *value) {
   if (top < 0) {
      return ERR_STACK_UNDERFLOW;
   }
   *value = stack[top];
   top--;
   return ERR_OK;
}

//gibt obertes Element zurück, ändert NICHT länge
int peek(int depth, int *value) {
   if (depth < 0 || top - depth < 0) {
      return ERR_STACK_UNDERFLOW;
   }
   *value = stack[top - depth];
   return ERR_OK;
}

void clear() {
    top = -1;
}
