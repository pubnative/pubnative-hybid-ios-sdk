/**
 * @file NEMovement.h
 * NEMovement type.
 */

#ifndef NEMovement_H
#define NEMovement_H

#include "NETypeUtils.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible states for NEMovement.
 */
typedef NE_ENUM(uint32_t, NEMovementState) {
    NEMovementStateUnknown = 0,
    NEMovementStateMoving,
    NEMovementStateNotMoving
};

/**
 * Represents whether the device is moving or not moving.
 */
typedef struct NEMovement {
    /**
     * Whether the device is moving or not moving.
     */
    NEMovementState state;
} NEMovement;

/**
 * Default NEMovement instance.
 */
static const NEMovement NEMovement_default = {
    .state = NEMovementStateUnknown
};

/**
 * C String array mapping for NEMovementState
 */
static const char * const NEMovementStateStrings[] = {
    [NEMovementStateUnknown] = "Unknown",
    [NEMovementStateMoving] = "Moving",
    [NEMovementStateNotMoving] = "Stationary",
};

static const char * const NEMovementStateReprs[] = {
    [NEMovementStateUnknown] = "unknown",
    [NEMovementStateMoving] = "moving",
    [NEMovementStateNotMoving] = "stationary",
};

const char * NEMovement_stringFromState(NEMovementState state);
const char * NEMovement_reprFromState(NEMovementState state);
NEMovementState NEMovement_stateFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEMovement struct to compare context in it.
 * @param rhsPtr A pointer to an NEMovement struct to compare against.
 */
bool NEMovement_isEqual(const NEMovement * const lhsPtr,
                        const NEMovement * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEMovement_H */
