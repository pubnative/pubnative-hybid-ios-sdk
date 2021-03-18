/**
 * @file NELocationCluster.h
 * NELocationCluster type.
 */

#ifndef NELocationCluster_h
#define NELocationCluster_h

#include "NETypeUtils.h"
#include "NELocationCoordinate2D.h"

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Represents a latitude and longitude in decimal degrees, and a speed in metres per second.
 */
typedef struct NELocationCluster {
    NELocationCoordinate2D centroid;
    int32_t clusterID;
} NELocationCluster;

/**
 * Default NELocation instance.
 */
static const NELocationCluster NELocationCluster_default = {
    .centroid = _NELocationCoordinate2D_default,
    .clusterID = 0,
};

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NELocationCluster struct to compare context in it.
 * @param rhsPtr A pointer to an NELocationCluster struct to compare against.
 */
bool NELocationCluster_isEqual(const NELocationCluster * const lhsPtr,
                               const NELocationCluster * const rhsPtr);

/**
 * Returns true if the the two objects are semantically equivalent, false otherwise.
 * Checks clusterID only.
 *
 * @param lhsPtr A pointer to an NELocationCluster struct to compare context in it.
 * @param rhsPtr A pointer to an NELocationCluster struct to compare against.
 */
bool NELocationCluster_isSemanticallyEqual(const NELocationCluster * const lhsPtr,
                                           const NELocationCluster * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NELocationCluster_h */
