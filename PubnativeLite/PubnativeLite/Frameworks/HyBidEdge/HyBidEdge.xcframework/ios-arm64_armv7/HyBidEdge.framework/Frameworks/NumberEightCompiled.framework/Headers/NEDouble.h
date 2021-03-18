/**
 * @file NEDouble.h
 * NEDouble type.
 */

#ifndef NEDouble_H
#define NEDouble_H

#include "NETypeUtils.h"
#include <float.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Encapsulates a double-precision floating point number.
 */
typedef struct NEDouble {
    double value;
} NEDouble;

/**
 * Default NEDouble instance.
 */
static const NEDouble NEDouble_default = {
    .value = 0.0
};

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEDouble struct to compare context in it.
 * @param rhsPtr A pointer to an NEDouble struct to compare against.
 */
bool NEDouble_isEqual(const NEDouble * const lhsPtr,
                      const NEDouble * const rhsPtr);

#ifdef __cplusplus
}
#endif


#endif /* NEDouble_H */
