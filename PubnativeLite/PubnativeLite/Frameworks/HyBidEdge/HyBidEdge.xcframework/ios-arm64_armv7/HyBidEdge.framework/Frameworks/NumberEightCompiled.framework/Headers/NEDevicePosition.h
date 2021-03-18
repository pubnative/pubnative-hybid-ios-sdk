/**
 * @file NEDevicePosition.h
 * NEDevicePosition type.
 */

#ifndef NEDevicePosition_H
#define NEDevicePosition_H

#include "NETypeUtils.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible states for NEDevicePosition.
 */
typedef NE_ENUM(uint32_t, NEDevicePositionState) {
    NEDevicePositionStateUnknown = 0,
    NEDevicePositionStateOnSurface,
    NEDevicePositionStateInHand,
    NEDevicePositionStateInPocket,
    NEDevicePositionStateAgainstEar,
    NEDevicePositionStateInBag,
    NEDevicePositionStateOnArm
};

/**
 * Possible orientations for NEDevicePosition
 */
typedef NE_ENUM(uint32_t, NEDevicePositionOrientation) {
    NEDevicePositionOrientationUnknown = 0,
    NEDevicePositionOrientationFaceDown,
    NEDevicePositionOrientationFaceUp,
    NEDevicePositionOrientationPointDown,
    NEDevicePositionOrientationPointUp,
    NEDevicePositionOrientationSideways
};

/**
 * Possible state transitions for NEDevicePosition.
 */
typedef NE_ENUM(uint32_t, NEDevicePositionTransition) {
    NEDevicePositionTransitionNoPosition = 0,
    NEDevicePositionTransitionPositionLost,
    NEDevicePositionTransitionPickUp,
    NEDevicePositionTransitionPutDown,
    NEDevicePositionTransitionPocketRetrieve,
    NEDevicePositionTransitionPocketPut,
    NEDevicePositionTransitionHoldToEar,
    NEDevicePositionTransitionHangUp,
    NEDevicePositionTransitionBagRetrieve,
    NEDevicePositionTransitionBagPut,
    NEDevicePositionTransitionArmRetrieve,
    NEDevicePositionTransitionArmPut
};


/**
 * Represents a device's position relative to the user, and its orientation.
 *
 * The state represents the position relative to the user.
 * The orientation represents the device's physical orientation.
 */
typedef struct NEDevicePosition {
    /**
     * The device's position relative to the user.
     */
    NEDevicePositionState state;
    /**
     * The device's physical orientation.
     */
    NEDevicePositionOrientation orientation;
} NEDevicePosition;

/**
 * Default NEDevicePosition instance.
 */
static const NEDevicePosition NEDevicePosition_default = {
    .state = NEDevicePositionStateUnknown,
    .orientation = NEDevicePositionOrientationUnknown,
};
/**
 * Null NEDevicePosition instance.
 */
static const NEDevicePosition NEDevicePosition_null = {
    .state = NEDevicePositionStateUnknown,
    .orientation = NEDevicePositionOrientationUnknown,
};


/**
* C String array mapping for NEDevicePositionState
*/
static const char * const NEDevicePositionStateStrings[] = {
        [NEDevicePositionStateUnknown] = "Unknown",
        [NEDevicePositionStateOnSurface] = "On Surface",
        [NEDevicePositionStateInHand] = "In Hand",
        [NEDevicePositionStateInPocket] = "In Pocket",
        [NEDevicePositionStateAgainstEar] = "Against Ear",
        [NEDevicePositionStateInBag] = "In Bag",
        [NEDevicePositionStateOnArm] = "On Arm",
};

static const char * const NEDevicePositionStateReprs[] = {
        [NEDevicePositionStateUnknown] = "unknown",
        [NEDevicePositionStateOnSurface] = "on-surface",
        [NEDevicePositionStateInHand] = "in-hand",
        [NEDevicePositionStateInPocket] = "in-pocket",
        [NEDevicePositionStateAgainstEar] = "against-ear",
        [NEDevicePositionStateInBag] = "in-bag",
        [NEDevicePositionStateOnArm] = "on-arm",
};

const char * NEDevicePosition_stringFromState(NEDevicePositionState state);

const char * NEDevicePosition_reprFromState(NEDevicePositionState state);

NEDevicePositionState NEDevicePosition_stateFromRepr(const char * repr);

/**
 * C String array mapping for NEDevicePositionOrientation
 */
static const char * const NEDevicePositionOrientationStrings[] = {
        [NEDevicePositionOrientationUnknown] = "Unknown",
        [NEDevicePositionOrientationFaceDown] = "Face Down",
        [NEDevicePositionOrientationFaceUp] = "Face Up",
        [NEDevicePositionOrientationPointDown] = "Pointing Down",
        [NEDevicePositionOrientationPointUp] = "Pointing Up",
        [NEDevicePositionOrientationSideways] = "Sideways",
};

static const char * const NEDevicePositionOrientationReprs[] = {
        [NEDevicePositionOrientationUnknown] = "unknown",
        [NEDevicePositionOrientationFaceDown] = "face-down",
        [NEDevicePositionOrientationFaceUp] = "face-up",
        [NEDevicePositionOrientationPointDown] = "point-down",
        [NEDevicePositionOrientationPointUp] = "point-up",
        [NEDevicePositionOrientationSideways] = "sideways",
};

const char * NEDevicePosition_stringFromOrientation(NEDevicePositionOrientation orientation);

const char * NEDevicePosition_reprFromOrientation(NEDevicePositionOrientation orientation);

NEDevicePositionOrientation NEDevicePosition_orientationFromRepr(const char * repr);

/**
 * Returns true if all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEDevicePosition struct to compare context in it.
 * @param rhsPtr A pointer to an NEDevicePosition struct to compare against.
 */
bool NEDevicePosition_isEqual(const NEDevicePosition * const lhsPtr,
                              const NEDevicePosition * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEDevicePosition_H */

