/**
 * @file NELocation.h
 * NELocation type.
 */

#ifndef NELocation_H
#define NELocation_H

#include "NELocationCoordinate2D.h"
#include "NETypeUtils.h"

#include <limits.h>
#include <math.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef double NESpeed;
static const NESpeed kNESpeedUnavailable = -1.0;

typedef double NEAltitude;
static const NEAltitude kNEAltitudeUnavailable = -HUGE_VAL;

typedef double NEDirection;
static const NEDirection kNEDirectionUnavailable = -HUGE_VAL;

typedef int32_t NEFloor;
static const NEFloor kNEFloorUnavailable = INT_MIN;
    
typedef double NELocationAccuracy;
static const NELocationAccuracy kNELocationAccuracyUnavailable = -HUGE_VAL;

/**
 * Represents a latitude and longitude in decimal degrees, and a speed in metres per second.
 */
typedef struct NELocation {
    /**
    * The coordinate encapsulating a latitude and longitude in decimal degrees.
    */
    NELocationCoordinate2D coordinate;
    /**
     * The speed in metres per second, if speed is unknown then this value defaults to kNESpeedUnavailable.
     */
    NESpeed speed;
    /**
     * The altitude in meters, if altitude is unknown then this value defaults to kNEAltitudeUnavailable.
     */
    NEAltitude altitude;
    /**
     *  The course of the location in degrees true North. Negative if course is invalid. 
     *  If course is unknown then this value defaults to kNEDirectionUnavailable.
     */
    NEDirection course;
    /**
     * The  floor level, 0 means ground floor, if floor is unknown then this value defaults to kNEFloorUnavailable.
     */
    NEFloor floor;
    /**
     * The horizontal accuracy of the location in meters. The radius of the circle the location is within. Negative if the lateral location is invalid. If unknown then this value defaults to kNELocationAccuracyUnavailable.
     */
    NELocationAccuracy horizontalAccuracy;
    /**
     * The vertical accuracy of the location in meters. Negative if the altitude is invalid. If unknown then this value defaults to kNELocationAccuracyUnavailable.
     */
    NELocationAccuracy verticalAccuracy;
} NELocation;

/**
 * Default NELocation instance.
 */
static const NELocation NELocation_default = { 
    .coordinate = _NELocationCoordinate2D_default,
    .speed = kNESpeedUnavailable,
    .altitude = kNEAltitudeUnavailable,
    .course = kNEDirectionUnavailable,
    .floor = kNEFloorUnavailable,
    .horizontalAccuracy = kNELocationAccuracyUnavailable,
    .verticalAccuracy = kNELocationAccuracyUnavailable
};

/**
 * Returns true if all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NELocation struct to compare context in it.
 * @param rhsPtr A pointer to an NELocation struct to compare against.
 */
bool NELocation_isEqual(const NELocation * const lhsPtr,
                        const NELocation * const rhsPtr);

/**
 * Returns true if the two objects are semantically equivalent, false otherwise.
 * Checks coordinate, altitude, and floor number.
 *
 * @param lhsPtr A pointer to an NELocation struct to compare context in it.
 * @param rhsPtr A pointer to an NELocation struct to compare against.
 */
bool NELocation_isSemanticallyEqual(const NELocation * const lhsPtr,
                                    const NELocation * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NELocation_H */
