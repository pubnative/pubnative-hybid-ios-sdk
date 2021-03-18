/**
 * @file NELockStatus.h
 * NELockStatus type.
 */

#ifndef NELockStatus_H
#define NELockStatus_H

#include "NETypeUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/**
 * Possible states for NELockStatus.
 */
typedef NE_ENUM(uint32_t, NELockStatusState) {
    NELockStatusStateUnlocked = 0,
    NELockStatusStateLocked
};

/**
 * Represents whether the device is locked or unlocked.
 */
typedef struct NELockStatus {
    /**
     * Whether the device is locked or unlocked.
     */
    NELockStatusState state;
} NELockStatus;

/**
 * Default NELockStatus instance.
 */
static const NELockStatus NELockStatus_default = {
    .state = NELockStatusStateUnlocked
};

/**
 * C String array mapping for NELockStatusState
 */
static const char * const NELockStatusStateStrings[] = {
    [NELockStatusStateUnlocked] = "Unlocked",
    [NELockStatusStateLocked] = "Locked",
};

static const char * const NELockStatusStateReprs[] = {
    [NELockStatusStateUnlocked] = "unlocked",
    [NELockStatusStateLocked] = "locked",
};

const char * NELockStatus_stringFromState(NELockStatusState state);
const char * NELockStatus_reprFromState(NELockStatusState state);
NELockStatusState NELockStatus_stateFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NELockStatus struct to compare context in it.
 * @param rhsPtr A pointer to an NELockStatus struct to compare against.
 */
bool NELockStatus_isEqual(const NELockStatus * const lhsPtr,
                          const NELockStatus * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NELockStatus_H */
