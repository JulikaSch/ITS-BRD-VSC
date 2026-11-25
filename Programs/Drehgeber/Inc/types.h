

#ifndef TYPES_H
#define TYPES_H

#include <stdbool.h>
#include <stdint.h>

//Timer 90 Ticks pro Mikrosekunde
#define TICKS_PRO_SEKUNDE 90000000ULL

//Phasen
typedef enum {PHASE_A = 0, PHASE_B = 1, PHASE_C = 2, PHASE_D = 3} PhaseId;

//drehrichtung
typedef enum {DIR_UNKNOWN = 0, DIR_FORWARD = 1, DIR_BACKWARD = 2} Direction;

typedef struct{
    PhaseId phase;
    bool resetGedrueckt;
    uint64_t zeit;
} InputData;

#endif