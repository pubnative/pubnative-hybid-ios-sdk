/**
 * @file NEInteger.h
 * NEInteger type.
 */

#ifndef NEInteger_H
#define NEInteger_H

#include "NETypeUtils.h"

#ifdef __cplusplus
#include <string>
extern "C" {
#endif

#include <stdbool.h>

/**
 * Encapsulates an integer.
 */
typedef struct NEInteger {
    int32_t value;
} NEInteger;

/**
 * Default NEInteger instance.
 */
static const NEInteger NEInteger_default = { .value = 0 };

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEInteger struct to compare context in it.
 * @param rhsPtr A pointer to an NEInteger struct to compare against.
 */
bool NEInteger_isEqual(const NEInteger * const lhsPtr,
                       const NEInteger * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEInteger_H */
