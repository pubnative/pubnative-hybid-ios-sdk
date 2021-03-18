/**
 * @file TopicStringConstants.h
 * Constants for common topic names (see source code).
 */
#ifndef TOPIC_STRING_CONSTANTS_H
#define TOPIC_STRING_CONSTANTS_H

#ifndef TopicStrType
    // iOS (engine/NEXTopics.h defines NE_USE_IOS_TOPICS)
    #ifdef NE_USE_IOS_TOPICS
    #import <Foundation/Foundation.h>
    // Turn strings into NSStrings, init with @("<string>")
    #define TopicStrType NSString*
    #define TopicStrVal(val) @(val)
    #else
    // Leave strings as C++ strings, noop
    #define TopicStrType char* const
    #define TopicStrVal(val) val
    #endif
#endif // end TopicStrType

static const TopicStrType kNETopicActivity = TopicStrVal("activity");
static const TopicStrType kNETopicDeviceMovement = TopicStrVal("motion/device_movement");
static const TopicStrType kNETopicDevicePosition = TopicStrVal("device_position");
static const TopicStrType kNETopicIndoorOutdoor = TopicStrVal("indoor_outdoor");
static const TopicStrType kNETopicJogging = TopicStrVal("extended/jogging");
static const TopicStrType kNETopicPlace = TopicStrVal("place");
static const TopicStrType kNETopicSituation = TopicStrVal("situation");
static const TopicStrType kNETopicTime = TopicStrVal("time");
static const TopicStrType kNETopicWeather = TopicStrVal("weather");
static const TopicStrType kNETopicLockStatus = TopicStrVal("lock_status");
static const TopicStrType kNETopicReachability = TopicStrVal("reachability");

static const TopicStrType kNETopicPlaceInternal = TopicStrVal("_/place");
static const TopicStrType kNETopicNaivePlace = TopicStrVal("_/place_naive");
static const TopicStrType kNETopicPlaceContextInternal = TopicStrVal("_/place_context");

static const TopicStrType kNETopicMagneticVariance = TopicStrVal("magnetism/magnetic_variance");
static const TopicStrType kNETopicUserMovement = TopicStrVal("motion/user_movement");
static const TopicStrType kNETopicAccelerometer = TopicStrVal("motion/accelerometer");
static const TopicStrType kNETopicAcceleration = TopicStrVal("motion/acceleration");
static const TopicStrType kNETopicSpeed = TopicStrVal("motion/speed");
static const TopicStrType kNETopicGyroscope = TopicStrVal("motion/gyroscope");
static const TopicStrType kNETopicMotionActivity = TopicStrVal("motion/activity");
static const TopicStrType kNETopicMagnetometer = TopicStrVal("magnetism/magnetometer");
static const TopicStrType kNETopicCalibratedMagnetometer = TopicStrVal("magnetism/calibrated_magnetometer");
static const TopicStrType kNETopicRelativeAltitude = TopicStrVal("ambient/relativeAltitude");
static const TopicStrType kNETopicAmbientPressure = TopicStrVal("ambient/pressure");
static const TopicStrType kNETopicAmbientLight = TopicStrVal("ambient/light");
static const TopicStrType kNETopicAmbientLightDetected = TopicStrVal("ambient/light/detected");
static const TopicStrType kNETopicAmbientLightInferred = TopicStrVal("ambient/light/inferred");
static const TopicStrType kNETopicScreenBrightness = TopicStrVal("screen_brightness");
static const TopicStrType kNETopicProximity = TopicStrVal("proximity");
static const TopicStrType kNETopicLocation = TopicStrVal("location");
static const TopicStrType kNETopicCellularConnection = TopicStrVal("signal/cellular/connection");
static const TopicStrType kNETopicWifiConnection = TopicStrVal("signal/wifi/connection");
static const TopicStrType kNETopicSunlight = TopicStrVal("sunlight");

static const TopicStrType kNETopicLocationCluster = TopicStrVal("location_cluster");
static const TopicStrType kNETopicLSTMCluster = TopicStrVal("location_cluster_lstm");

static const TopicStrType kNETopicGPSLocation = TopicStrVal("location/gps");
static const TopicStrType kNETopicLowPowerLocation = TopicStrVal("location/low_power");
static const TopicStrType kNETopicLowPowerIPLocation = TopicStrVal("location/low_power/ip");
static const TopicStrType kNETopicCLRegions = TopicStrVal("location/regions");
static const TopicStrType kNETopicCLBackgroundLocation = TopicStrVal("location/background_location");
static const TopicStrType kNETopicLazyGPS = TopicStrVal("gps/lazy");

#ifndef NE_USE_IOS_TOPICS
    // Not available on iOS
    #include <string>
    #define NTH_TOPIC(topic, nth) std::string(topic) + "/" + std::to_string(nth)
#endif

#endif // File Guard end
