/**
 * @file NEIndoorOutdoor.h
 * NEIndoorOutdoor type.
 */

#ifndef NEIndoorOutdoor_H
#define NEIndoorOutdoor_H

#include "NETypeUtils.h"

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible states for NEIndoorOutdoor.
 */
typedef NE_ENUM(uint32_t, NEIndoorOutdoorState) {
    NEIndoorOutdoorStateUnknown = 0,
    NEIndoorOutdoorStateIndoor,
    NEIndoorOutdoorStateOutdoor,
    NEIndoorOutdoorStateEnclosed
};

/**
 * Represents whether a user is indoors, outdoors, or enclosed.
 *
 * Enclosed in this case means that the user is outside, but under some sort of canopy.
 * This could be a bus shelter or a train for example.
 */
typedef struct NEIndoorOutdoor {
    /**
     * Whether a user is indoors, outdoors, or enclosed.
     */
    NEIndoorOutdoorState state;
} NEIndoorOutdoor;

/**
 * Default NEIndoorOutdoor instance.
 */
static const NEIndoorOutdoor NEIndoorOutdoor_default = { 
    .state = NEIndoorOutdoorStateUnknown 
};

/**
 * C String array mapping for NEIndoorOutdoorState
 */
static const char * const NEIndoorOutdoorStateStrings[] = {
    [NEIndoorOutdoorStateUnknown] = "Unknown",
    [NEIndoorOutdoorStateIndoor] = "Indoor",
    [NEIndoorOutdoorStateOutdoor] = "Outdoor",
    [NEIndoorOutdoorStateEnclosed] = "Enclosed",
};

static const char * const NEIndoorOutdoorStateReprs[] = {
    [NEIndoorOutdoorStateUnknown] = "unknown",
    [NEIndoorOutdoorStateIndoor] = "indoor",
    [NEIndoorOutdoorStateOutdoor] = "outdoor",
    [NEIndoorOutdoorStateEnclosed] = "enclosed",
};

const char * NEIndoorOutdoor_stringFromState(NEIndoorOutdoorState state);
const char * NEIndoorOutdoor_reprFromState(NEIndoorOutdoorState state);
NEIndoorOutdoorState NEIndoorOutdoor_stateFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEIndoorOutdoor struct to compare context in it.
 * @param rhsPtr A pointer to an NEIndoorOutdoor struct to compare against.
 */
bool NEIndoorOutdoor_isEqual(const NEIndoorOutdoor * const lhsPtr,
                             const NEIndoorOutdoor * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEIndoorOutdoor_H */
