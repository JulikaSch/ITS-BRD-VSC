#ifndef FEHLER_H
#define FEHLER_H

#define ERR_OK 0              
#define ERR_STACK_OVERFLOW 1  
#define ERR_STACK_UNDERFLOW 2 
#define ERR_DIV_ZERO 3        
#define ERR_RANGE 4           
#define ERR_INPUT_RANGE 5     


void show_error(int error);

#endif /* FEHLER_H */
