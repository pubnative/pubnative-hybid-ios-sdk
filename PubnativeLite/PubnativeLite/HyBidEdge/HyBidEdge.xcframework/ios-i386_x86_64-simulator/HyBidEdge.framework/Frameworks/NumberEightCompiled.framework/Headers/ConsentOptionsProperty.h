#ifndef ConsentOptionsProperty_h
#define ConsentOptionsProperty_h

#if __has_include("../../types/ctypes/NETypeUtils.h")
#include "../../types/ctypes/NETypeUtils.h"
#else
#include "NETypeUtils.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef NE_ENUM(uint32_t, TCFv2Purpose) {
    STORAGE = 1,
    BASIC_ADS = 2,
    PERSONALISED_ADS = 3,
    SELECT_ADS = 4,
    PERSONALISED_CONTENT = 5,
    SELECT_CONTENT = 6,
    MEASURE_ADS = 7,
    MEASURE_CONTENT = 8,
    MARKET_RESEARCH = 9,
    IMPROVE_PRODUCTS = 10
};

typedef NE_ENUM(uint32_t, TCFv2SpecialFeature) {
    PRECISE_GEOLOCATION = 1,
    SCAN_CHARACTERISTICS = 2
};

typedef NE_ENUM(uint32_t, ConsentOptionsProperty) {
    ConsentOptionsProperty_begin = 0,

    /**
     * Allow processing of data. This must be enabled for NumberEight to start.
     * NE's legal basis: Legitimate Interest.
     */
    ALLOW_PROCESSING,

    /**
     * Allow use of the device's sensor data.
     * NE's legal basis: Legitimate Interest.
     */
    ALLOW_SENSOR_ACCESS,

    /**
     * Allow storing and accessing information on the device.
     * NE's legal basis: Consent.
     */
    ALLOW_STORAGE,

    /**
     * Allow use of technology for personalised ads.
     * NE's legal basis: Consent or Legitimate Interest.
     */
    ALLOW_USE_FOR_AD_PROFILES,

    /**
     * Allow use of technology for personalised content.
     * NE's legal basis: Legitimate Interest or Consent.
     */
    ALLOW_USE_FOR_PERSONALISED_CONTENT,

    /**
     * Allow use of technology for market research and audience insights.
     * NE's legal basis: Legitimate Interest.
     */
    ALLOW_USE_FOR_REPORTING,

    /**
     * Allow use of technology for improving NumberEight's products.
     * NE's legal basis: Consent.
     */
    ALLOW_USE_FOR_IMPROVEMENT,

    /**
     * Allow linking different devices to the user through deterministic or probabilistic means.
     * NE's legal basis: Consent.
     */
    ALLOW_LINKING_DEVICES,

    /**
     * Allow use of automatically provided device information such as manufacturer, model,
     * IP addresses and MAC addresses.
     * NE's legal basis: Legitimate Interest.
     */
    ALLOW_USE_OF_DEVICE_INFO,

    /**
     * Allow use of independent identifiers to ensure the secure operation of systems.
     * NE's legal basis: Legitimate Interest.
     * There is no right-to-object for this particular processing activity.
     */
    ALLOW_USE_FOR_SECURITY,

    /**
     * Allow processing of diagnostic information using an independent identifier
     * to ensure the correct operation of systems.
     * NE's legal basis: Consent or Legitimate Interest.
     */
    ALLOW_USE_FOR_DIAGNOSTICS,

    /**
     * Allow use of precise geolocation data (within 500 metres accuracy).
     * NE's legal basis: Consent.
     */
    ALLOW_PRECISE_GEOLOCATION,

    ConsentOptionsProperty_end,
};

#ifdef __cplusplus
}
#endif

#endif
