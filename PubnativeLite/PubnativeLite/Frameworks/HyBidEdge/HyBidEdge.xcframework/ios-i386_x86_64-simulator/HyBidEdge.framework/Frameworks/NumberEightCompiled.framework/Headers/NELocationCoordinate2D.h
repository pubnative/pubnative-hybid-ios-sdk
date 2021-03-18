/**
 * @file NELocationCoordinate2D.h
 * NELocationCoordinate2D type.
 */

#ifndef NELocationCoordinate2D_H
#define NELocationCoordinate2D_H

#include <math.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Represents a latitude and longitude in decimal degrees.
 */
typedef struct NELocationCoordinate2D {
    /**
     * The latitude in decimal degrees.
     */
    double latitude;
    /**
     * The longitude in decimal degrees.
     */
    double longitude;
} NELocationCoordinate2D;


#define _NELocationCoordinate2D_default { \
    .latitude = 0.0, \
    .longitude = 0.0 \
}

/**
 * Default NELocationCoordinate2D instance.
 */
static const NELocationCoordinate2D NELocationCoordinate2D_default = _NELocationCoordinate2D_default;

bool NELocationCoordinate2D_isEqual(const NELocationCoordinate2D * const lhs,
                                    const NELocationCoordinate2D * const rhs);

#ifdef __cplusplus
}
#endif

#endif /* NELocationCoordinate2D_H */
