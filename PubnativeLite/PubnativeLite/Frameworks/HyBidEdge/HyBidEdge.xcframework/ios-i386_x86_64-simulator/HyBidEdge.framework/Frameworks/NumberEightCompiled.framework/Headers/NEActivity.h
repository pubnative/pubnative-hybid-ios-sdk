/**
 * @file NEActivity.h
 * NEActivity type.
 */

#ifndef NEActivity_H
#define NEActivity_H

#include "NETypeUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/**
 * Possible states for NEActivity.
 */
typedef NE_ENUM(uint32_t, NEActivityState) {
    NEActivityStateUnknown = 0,
    NEActivityStateStationary,
    NEActivityStateWalking,
    NEActivityStateRunning,
    NEActivityStateCycling,
    NEActivityStateInVehicle
};

typedef NE_ENUM(uint32_t, NEActivityMode) {
    NEActivityModeUnknown = 0,
    NEActivityModeBicycle,
    NEActivityModeBus,
    NEActivityModeCar,
    NEActivityModeMotorbike,
    NEActivityModeSubway,
    NEActivityModeTrain,
    NEActivityModeTram,
    NEActivityModeBoat,
    NEActivityModeAircraft
};

/**
 * Possible state transitions for NEActivity.
 */
typedef NE_ENUM(uint32_t, NEActivityTransition) {
    NEActivityTransitionNoActivity = 0,
    NEActivityTransitionActivityLost,
    NEActivityTransitionStartWalking,
    NEActivityTransitionKeepWalking,
    NEActivityTransitionStartRunning,
    NEActivityTransitionKeepRunning,
    NEActivityTransitionStartCycling,
    NEActivityTransitionKeepCycling,
    NEActivityTransitionEnterVehicle,
    NEActivityTransitionStayInVehicle,
    NEActivityTransitionIdle,
    NEActivityTransitionStopMoving
};


/**
 * Represents a user's physical activity, comprising a state and a mode.
 *
 * The state represents the main category of the activity, e.g. walking, running, and in vehicle.
 * The mode represents what type of vehicle is in use, if any.
 */
typedef struct NEActivity {
    /**
     * The main category of activity.
     */
    NEActivityState state;
    /**
     * The type of vehicle in use.
     */
    NEActivityMode modeOfTransport;
} NEActivity;

/**
 * Default NEActivity instance.
 */

static const NEActivity NEActivity_default = {
    .state = NEActivityStateUnknown,
    .modeOfTransport = NEActivityModeUnknown
};

/**
 * C String array mapping for NEActivityState
 */
static const char * const NEActivityStateStrings[] = {
     [NEActivityStateUnknown] = "Unknown",
     [NEActivityStateStationary] = "Stationary",
     [NEActivityStateWalking] = "Walking",
     [NEActivityStateRunning] = "Running",
     [NEActivityStateCycling] = "Cycling",
     [NEActivityStateInVehicle] = "In Vehicle",
 };

static const char * const NEActivityStateReprs[] = {
    [NEActivityStateUnknown] = "unknown",
    [NEActivityStateStationary] = "stationary",
    [NEActivityStateWalking] = "walking",
    [NEActivityStateRunning] = "running",
    [NEActivityStateCycling] = "cycling",
    [NEActivityStateInVehicle] = "in-vehicle",
};

const char * NEActivity_stringFromState(NEActivityState state);

const char * NEActivity_reprFromState(NEActivityState state);

NEActivityState NEActivity_stateFromRepr(const char * repr);

/**
 * C String array mapping for NEActivityMode
 */
static const char * const NEActivityModeStrings[] = {
    [NEActivityModeUnknown] = "Unknown",
    [NEActivityModeBicycle] = "On a Bicycle",
    [NEActivityModeBus] = "On a Bus",
    [NEActivityModeCar] = "In a Car",
    [NEActivityModeMotorbike] = "On a Motorbike",
    [NEActivityModeSubway] = "On a Subway Train",
    [NEActivityModeTrain] = "On a Train",
    [NEActivityModeTram] = "On a Tram",
    [NEActivityModeBoat] = "On a Boat",
    [NEActivityModeAircraft] = "In an Aircraft",
};

static const char * const NEActivityModeReprs[] = {
    [NEActivityModeUnknown] = "unknown",
    [NEActivityModeBicycle] = "bicycle",
    [NEActivityModeBus] = "bus",
    [NEActivityModeCar] = "car",
    [NEActivityModeMotorbike] = "motorbike",
    [NEActivityModeSubway] = "subway",
    [NEActivityModeTrain] = "train",
    [NEActivityModeTram] = "tram",
    [NEActivityModeBoat] = "boat",
    [NEActivityModeAircraft] = "aircraft",
};

const char * NEActivity_stringFromMode(NEActivityMode mode);
const char * NEActivity_reprFromMode(NEActivityMode mode);
NEActivityMode NEActivity_modeFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEActivity struct to compare context in it.
 * @param rhsPtr A pointer to an NEActivity struct to compare against.
 */
bool NEActivity_isEqual(const NEActivity * const lhsPtr,
                        const NEActivity * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEActivity_H */
