/**
 * @file NEVector3D.h
 * NEVector3D type.
 */

#ifndef NEVector3D_H
#define NEVector3D_H

#include "NETypeUtils.h"

#include <stdio.h>
#include <math.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Encapsulates a 3-dimensional vector of double-precision floating point numbers.
 */
typedef struct NEVector3D {
    /**
     * The x coordinate.
     */
    double x;
    /**
     * The y coordinate.
     */
    double y;
    /**
     * The z coordinate.
     */
    double z;
} NEVector3D;

/**
 * Default NEVector3D instance.
 */
static const NEVector3D NEVector3D_default = {
    .x = 0.0,
    .y = 0.0,
    .z = 0.0
};

/**
 * @copydoc NE::Vector3D::magnitudeSquared()
 *
 * @param vec NEVector3D.
 * @return The squared magnitude.
 */
double NEVector3D_magnitudeSquared(NEVector3D vec);

/**
 * @copydoc NE::Vector3D::magnitude()
 *
 * @param vec NEVector3D.
 * @return The magnitude.
 */
double NEVector3D_magnitude(NEVector3D vec);

    /**
 * @copydoc NE::Vector3D::normalized()
 *
 * @param vec NEVector3D.
 * @return new unit-length NEVector3D.
 */
NEVector3D NEVector3D_normalized(NEVector3D vec);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEVector3D struct to compare context in it.
 * @param rhsPtr A pointer to an NEVector3D struct to compare against.
 */
bool NEVector3D_isEqual(const NEVector3D * const lhsPtr,
                        const NEVector3D * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEVector3D_H */
