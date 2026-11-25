

#ifndef TYPES_H
#define TYPES_H

#include <stdbool.h>
#include <stdint.h>

//Phasen
typedef enum {PHASE_A = 0, PHASE_B = 1, PHASE_C = 2, PHASE_D = 3} PhaseId;

//drehrichtung
typedef enum {DIR_UNKOWN = 0, DIR_FORWARD = 1, DIR_BACKWARD = 2} Direction;

#endif