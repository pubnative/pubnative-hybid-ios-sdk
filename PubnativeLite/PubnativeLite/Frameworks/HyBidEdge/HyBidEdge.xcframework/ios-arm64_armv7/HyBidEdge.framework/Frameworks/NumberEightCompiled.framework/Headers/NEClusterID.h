/**
 * @file NEClusterID.h
 * NEClusterID type.
 */

#ifndef NEClusterID_h
#define NEClusterID_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

typedef int32_t NEClusterIDValue;

typedef struct NEClusterID {
    NEClusterIDValue value;
} NEClusterID;

/**
 * Default NEClusterID. Value will take `0` as default value.
 */
static const NEClusterID NEClusterID_default = {
    .value = 0,
};

/**
 * Returns true if the cluster id is a `noise` false otherwise.
 * Ids between -1 and INT32_MIN+1 inclusive are `noise` ids.
 */
bool NEClusterID_isNoise(const NEClusterID * const self);

/**
 * Returns true if the cluster id is a `valid` false otherwise.
 * Positive ids from 1 are `valid` ids.
 */
bool NEClusterID_isValid(const NEClusterID * const self);

/**
 * Returns true if the cluster id is 0 indicating that no valid or noise cluser id has arrived yet.
 */
bool NEClusterID_isAwaitingFirst(const NEClusterID * const self);

/**
 * Turns a `valid` id into a `noise` id by multiplying it with -1, if not already a `noise` cluster;
 */
void NEClusterID_turnIntoNoise(NEClusterID * const self);

/**
 * Turns a noise id into a valid id by multiplying it with -1, if not already a `valid` cluster;
 */
void NEClusterID_turnIntoValid(NEClusterID * const self);

/**
 * Returns true if overflow did occur and correction was performed false otherwise.
 *
 * @param self A pointer to an NEClusterID to work on.
 */
bool NEClusterID_safelyIncrement(NEClusterID * const self);


#ifdef __cplusplus
}
#endif

#endif /* NEClusterID_h */


