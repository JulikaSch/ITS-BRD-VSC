//measure.h
//Messpin AUX0 = PG0
//Messen dauer Display Ausgabe und Superloopdurchlauf

#ifndef MEASURE_H
#define MEASURE_H

//PG0 als Ausgang, auf low setzen
void measureInit(void);

//PG0 auf High 1
void measureHigh(void);

//auf low 0
void measureLow(void);

//umschalten (high -> low, low -> high)
void measuretoggle(void);

#endif