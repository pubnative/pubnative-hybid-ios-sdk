/**
 * @file NEReachability.h
 * NEReachability type.
 */

#ifndef NEReachability_H
#define NEReachability_H

#include "NETypeUtils.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible cellular connection states.
 */
typedef NE_ENUM(uint32_t, NEReachabilityCellState) {
    NEReachabilityCellStateUnknown = 0,
    NEReachabilityCellStateOff,
    NEReachabilityCellStateNoService,
    NEReachabilityCellStateInService,
};

/**
 * Possible cellular data connection states.
 */
typedef NE_ENUM(uint32_t, NEReachabilityCellDataState) {
    NEReachabilityCellDataStateUnknown = 0,
    NEReachabilityCellDataStateOff,
    NEReachabilityCellDataStateDisconnected,
    NEReachabilityCellDataStateConnected,
};

/**
 * Possible wifi connection states.
 */
typedef NE_ENUM(uint32_t, NEReachabilityWifiState) {
    NEReachabilityWifiStateUnknown = 0,
    NEReachabilityWifiStateOff,
    NEReachabilityWifiStateDisconnected,
    NEReachabilityWifiStateConnected,
};


/**
 * Connection quality flags.
 */
typedef NE_OPTIONS(uint8_t, NEReachabilityFlag) {
    NEReachabilityFlagNoFlag = 0,
    NEReachabilityFlagHasInternet = 1 << 0,
    NEReachabilityFlagSlowConnection = 1 << 1,
    NEReachabilityFlagIsMetered = 1 << 2,
};

typedef NEReachabilityFlag NEReachabilityFlags;

/**
 * Represents the reachability of the device's radios: cellular and Wifi.
 *
 * Includes the connection status and whether the device has Internet access.
 */
typedef struct NEReachability {
    /**
     * The reachability status of the device's voice-only cellular radios.
     */
    NEReachabilityCellState cellState;
    /**
     * The reachability status of the device's cellular data service.
     */
    NEReachabilityCellDataState cellDataState;
    /**
     * The reachability status of the device's Wifi radios.
     */
    NEReachabilityWifiState wifiState;
    /**
     * Flags indicating connection quality:
     * - NEReachabilityFlagHasInternet -
     *          An active and working Internet connection exists.
     * - NEReachabilityFlagSlowConnection -
     *          Internet connection has a slow data rate,
     *          i.e. only suitable for text/email transfers.
     * - NEReachabilityFlagIsMetered -
     *          Internet connection is limited or billed by usage.
     *          Data usage should be light and infrequent when this flag is true.
     */
    NEReachabilityFlags flags;
} NEReachability;

/**
 * Default NEReachability instance.
 */
static const NEReachability NEReachability_default = {
    .cellState = NEReachabilityCellStateUnknown,
    .cellDataState = NEReachabilityCellDataStateUnknown,
    .wifiState = NEReachabilityWifiStateUnknown,
    .flags = NEReachabilityFlagNoFlag,
};

/**
 * C String array mapping for NEReachabilityCellState
 */
static const char * const NEReachabilityCellStateStrings[] = {
    [NEReachabilityCellStateUnknown] = "Unknown",
    [NEReachabilityCellStateOff] = "Cellular Off",
    [NEReachabilityCellStateNoService] = "No Service",
    [NEReachabilityCellStateInService] = "In Service",
};

static const char * const NEReachabilityCellStateReprs[] = {
    [NEReachabilityCellStateUnknown] = "unknown",
    [NEReachabilityCellStateOff] = "cell-off",
    [NEReachabilityCellStateNoService] = "no-service",
    [NEReachabilityCellStateInService] = "in-service",
};

/**
 * C String array mapping for NEReachabilityCellDataState
 */
static const char * const NEReachabilityCellDataStateStrings[] = {
    [NEReachabilityCellDataStateUnknown] = "Unknown",
    [NEReachabilityCellDataStateOff] = "Cellular Data Off",
    [NEReachabilityCellDataStateDisconnected] = "No Cellular Data",
    [NEReachabilityCellDataStateConnected] = "Cellular Data",
};

static const char * const NEReachabilityCellDataStateReprs[] = {
    [NEReachabilityCellDataStateUnknown] = "unknown",
    [NEReachabilityCellDataStateOff] = "cell-data-off",
    [NEReachabilityCellDataStateDisconnected] = "no-cell-data",
    [NEReachabilityCellDataStateConnected] = "cell-data",
};

/**
 * C String array mapping for NEReachabilityWifiState
 */
static const char * const NEReachabilityWifiStateStrings[] = {
    [NEReachabilityWifiStateUnknown] = "Unknown",
    [NEReachabilityWifiStateOff] = "Wifi Off",
    [NEReachabilityWifiStateDisconnected] = "No Wifi",
    [NEReachabilityWifiStateConnected] = "Wifi",
};

static const char * const NEReachabilityWifiStateReprs[] = {
    [NEReachabilityWifiStateUnknown] = "unknown",
    [NEReachabilityWifiStateOff] = "wifi-off",
    [NEReachabilityWifiStateDisconnected] = "no-wifi",
    [NEReachabilityWifiStateConnected] = "wifi",
};

static const char * const NEReachabilityFlagsReprs[] = {
    [0] = "---",
    [NEReachabilityFlagHasInternet] = "--i",
    [NEReachabilityFlagSlowConnection] = "-s-",
    [NEReachabilityFlagSlowConnection | NEReachabilityFlagHasInternet] = "-si",
    [NEReachabilityFlagIsMetered] = "m--",
    [NEReachabilityFlagIsMetered | NEReachabilityFlagHasInternet] = "m-i",
    [NEReachabilityFlagIsMetered | NEReachabilityFlagSlowConnection] = "ms-",
    [NEReachabilityFlagIsMetered | NEReachabilityFlagSlowConnection | NEReachabilityFlagHasInternet] = "msi",
};

const char * NEReachability_stringFromCellState(NEReachabilityCellState state);

const char * NEReachability_reprFromCellState(NEReachabilityCellState state);

NEReachabilityCellState NEReachability_cellStateFromRepr(const char * repr);

const char * NEReachability_stringFromCellDataState(NEReachabilityCellDataState state);

const char * NEReachability_reprFromCellDataState(NEReachabilityCellDataState state);

NEReachabilityCellDataState NEReachability_cellDataStateFromRepr(const char * repr);

const char * NEReachability_stringFromWifiState(NEReachabilityWifiState state);

const char * NEReachability_reprFromWifiState(NEReachabilityWifiState state);

NEReachabilityWifiState NEReachability_wifiStateFromRepr(const char * repr);

const char * NEReachability_reprFromFlags(NEReachabilityFlags flags);

NEReachabilityFlags NEReachability_flagsFromRepr(const char * repr);

/**
 * @return `true` if the cell state is not Off or Unknown.
 */
bool NEReachability_isCellStateOn(const NEReachability * const self);

/**
 * @return `true` if the cell data state is not Off or Unknown.
 */
bool NEReachability_isCellDataStateOn(const NEReachability * const self);

/**
 * @return `true` if the wifi state is not Off or Unknown.
 */
bool NEReachability_isWifiStateOn(const NEReachability * const self);

/**
 * @return `true` if an active and working Internet connection exists.
 */
bool NEReachability_hasInternet(const NEReachability * const self);

/**
 * @return `true` if Internet connection has a slow data rate,
 *          i.e. only suitable for text/email transfers.
 */
bool NEReachability_isSlow(const NEReachability * const self);

/**
 * Convenience getter for hasInternet() && !isSlow().
 *
 * @return `true` if Internet connection exists, and is suitable for most applications,
 *          e.g. browsing the web or downloading images.
 */
bool NEReachability_isGood(const NEReachability * const self);

/**
 * @return `true` if Internet connection is limited or billed by usage.
 *          Data usage should be light and infrequent when this flag is true.
 */
bool NEReachability_isMetered(const NEReachability * const self);

/**
 * Returns true if all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEReachability struct to compare context in it.
 * @param rhsPtr A pointer to an NEReachability struct to compare against.
 */
bool NEReachability_isEqual(const NEReachability * const lhsPtr,
                            const NEReachability * const rhsPtr);


#ifdef __cplusplus
}
#endif

#endif /* NEReachability_H */
