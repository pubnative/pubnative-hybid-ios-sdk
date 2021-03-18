/**
 * @file NEWeather.h
 * NEWeather type.
 */

#ifndef NEWeather_H
#define NEWeather_H

#include "NETypeUtils.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible temperature states for NEWeather.
 */
typedef NE_ENUM(uint32_t, NEWeatherTemperature) {
    NEWeatherTemperatureUnknown = 0,
    NEWeatherTemperatureVeryHot,
    NEWeatherTemperatureHot,
    NEWeatherTemperatureWarm,
    NEWeatherTemperatureCold,
    NEWeatherTemperatureFreezing
};

/**
 * Possible condition states for NEWeather.
 */
typedef NE_ENUM(uint32_t, NEWeatherConditions) {
    NEWeatherConditionsUnknown = 0,
    NEWeatherConditionsClear,
    NEWeatherConditionsSunny,
    NEWeatherConditionsCloudy,
    NEWeatherConditionsWindy,
    NEWeatherConditionsBreezy,
    NEWeatherConditionsSnow,
    NEWeatherConditionsRain,
    NEWeatherConditionsDrizzle,
    NEWeatherConditionsThunderstorm,
    NEWeatherConditionsExtremeStorm
};

/**
 * A representation of weather, comprising semantic temperature and conditions.
 *
 * The temperature is relative to the user's expectations: 15C is warm for Iceland, but cold for Ethiopia.
 * The conditions are an abstracted representation of the weather summary.
 */
typedef struct NEWeather {
    /**
     * A temperature relative to the user's expectations.
     */
    NEWeatherTemperature temperature;
    /**
     * An abstract representation of weather summary.
     */
    NEWeatherConditions conditions;
} NEWeather;

/**
 * Default NEWeather instance.
 */
static const NEWeather NEWeather_default = {
    .temperature = NEWeatherTemperatureUnknown,
    .conditions = NEWeatherConditionsUnknown
};

/**
 * C String array mapping for NEWeatherTemperature
 */
static const char * const NEWeatherTemperatureStrings[] = {
    [NEWeatherTemperatureUnknown] = "Unknown",
    [NEWeatherTemperatureVeryHot] = "Very Hot",
    [NEWeatherTemperatureHot] = "Hot",
    [NEWeatherTemperatureWarm] = "Warm",
    [NEWeatherTemperatureCold] = "Cold",
    [NEWeatherTemperatureFreezing] = "Freezing",
};

static const char * const NEWeatherTemperatureReprs[] = {
    [NEWeatherTemperatureUnknown] = "unknown",
    [NEWeatherTemperatureVeryHot] = "very-hot",
    [NEWeatherTemperatureHot] = "hot",
    [NEWeatherTemperatureWarm] = "warm",
    [NEWeatherTemperatureCold] = "cold",
    [NEWeatherTemperatureFreezing] = "freezing",
};

const char * NEWeather_stringFromTemperature(NEWeatherTemperature temperature);
const char * NEWeather_reprFromTemperature(NEWeatherTemperature temperature);
NEWeatherTemperature NEWeather_temperatureFromRepr(const char * repr);

/**
 * C String array mapping for NEWeatherConditions
 */
static const char * const NEWeatherConditionsStrings[] = {
    [NEWeatherConditionsUnknown] = "Unknown",
    [NEWeatherConditionsClear] = "Clear",
    [NEWeatherConditionsSunny] = "Sunny",
    [NEWeatherConditionsCloudy] = "Cloudy",
    [NEWeatherConditionsWindy] = "Windy",
    [NEWeatherConditionsBreezy] = "Breezy",
    [NEWeatherConditionsSnow] = "Snow",
    [NEWeatherConditionsRain] = "Rain",
    [NEWeatherConditionsDrizzle] = "Drizzle",
    [NEWeatherConditionsThunderstorm] = "Thunderstorm",
    [NEWeatherConditionsExtremeStorm] = "Extreme Storm",
};

static const char * const NEWeatherConditionsReprs[] = {
    [NEWeatherConditionsUnknown] = "unknown",
    [NEWeatherConditionsClear] = "clear",
    [NEWeatherConditionsSunny] = "sunny",
    [NEWeatherConditionsCloudy] = "cloudy",
    [NEWeatherConditionsWindy] = "windy",
    [NEWeatherConditionsBreezy] = "breezy",
    [NEWeatherConditionsSnow] = "snow",
    [NEWeatherConditionsRain] = "rain",
    [NEWeatherConditionsDrizzle] = "drizzle",
    [NEWeatherConditionsThunderstorm] = "thunderstorm",
    [NEWeatherConditionsExtremeStorm] = "extreme-storm",
};

const char * NEWeather_stringFromConditions(NEWeatherConditions conditions);
const char * NEWeather_reprFromConditions(NEWeatherConditions conditions);
NEWeatherConditions NEWeather_conditionsFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEWeather struct to compare context in it.
 * @param rhsPtr A pointer to an NEWeather struct to compare against.
 */
bool NEWeather_isEqual(const NEWeather * const lhsPtr, const NEWeather * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEWeather_H */
