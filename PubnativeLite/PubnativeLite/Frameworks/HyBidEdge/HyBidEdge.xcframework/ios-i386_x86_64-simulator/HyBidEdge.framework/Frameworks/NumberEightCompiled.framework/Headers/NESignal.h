/**
 * @file NESignal.h
 * NESignal type.
 */

#ifndef NESignal_H
#define NESignal_H

#include "NETypeUtils.h"

#include <limits.h>
#include <string.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NESIGNAL_DEFAULT_BSID "<unknown>"
#define NESIGNAL_DEFAULT_ADDR ""

static const size_t NESignal_baseStationID_maxlen = 63;
static const size_t NESignal_netaddr_maxlen = 45;
static const size_t NESignal_baseStationID_size = NESignal_baseStationID_maxlen + 1;
static const size_t NESignal_netaddr_size = NESignal_netaddr_maxlen + 1;

/**
 * Represents a signal strength to a connected radio base station.
 *
 * This could be Wifi, cellular, Bluetooth, and more.
 * It contains an identifier for the base station, and a signal strength in dBm.
 *
 * For cellular towers, the baseStationID is a concatenation of MCC, MNC, LAC or TAC, and CID or CI.
 * For Wifi, this is the SSID or BSSID.
 */
typedef struct NESignal {
    /**
     * A unique identifier for the base station.
     * For cellular towers, the baseStationID is a concatenation of MCC, MNC, LAC or TAC, and CID or CI.
     * For Wifi, this is the SSID or BSSID.
     */
    char baseStationID[NESignal_baseStationID_size];
    /**
     * Signal strength in dBm.
     */
    int strength;
    /**
     * A local network address for the device connected to the base station.
     * This may be a MAC address, IPv4, or IPv6 address.
     */
    char localAddress[NESignal_netaddr_size];
    /**
     * A local network address for the base station.
     * This may be a MAC address, IPv4, or IPv6 address.
     */
    char gatewayAddress[NESignal_netaddr_size];
    /**
     * A remote network address for the device via this base station.
     * This may be a MAC address, IPv4, or IPv6 address.
     */
    char remoteAddress[NESignal_netaddr_size];
} NESignal;

/**
 * Default NESignal instance.
 */
static const NESignal NESignal_default = {
    .baseStationID = NESIGNAL_DEFAULT_BSID,
    .strength = INT_MIN,
    .localAddress = NESIGNAL_DEFAULT_ADDR,
    .gatewayAddress = NESIGNAL_DEFAULT_ADDR,
    .remoteAddress = NESIGNAL_DEFAULT_ADDR
};

bool NESignal_isBaseStationIDValid(const char * const bsid);

bool NESignal_isNetAddrValid(const char * const netaddr);

bool NESignal_isValid(const NESignal * const self);

void NESignal_setBaseStationID(NESignal * const self,
                               const char * const bsid,
                               const size_t strLen);

void NESignal_setLocalAddress(NESignal * const self,
                              const char * const netaddr,
                              const size_t strLen);

void NESignal_setGatewayAddress(NESignal * const self,
                                const char * const netaddr,
                                const size_t strLen);

void NESignal_setRemoteAddress(NESignal * const self,
                               const char * const netaddr,
                               const size_t strLen);

/**
 * Returns true if all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NESignal struct to compare context in it.
 * @param rhsPtr A pointer to an NESignal struct to compare against.
 */
bool NESignal_isEqual(const NESignal * const lhsPtr,
                      const NESignal * const rhsPtr);

/**
 * Returns true if the two objects are semantically equivalent, false otherwise.
 * Checks baseStationID only.
 *
 * @param lhsPtr A pointer to an NESignal struct to compare context in it.
 * @param rhsPtr A pointer to an NESignal struct to compare against.
 */
bool NESignal_isSemanticallyEqual(const NESignal * const lhsPtr,
                                  const NESignal * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NESignal_H */
