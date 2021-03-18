/**
 * @file NETime.h
 * NETime type.
 */

#ifndef NETime_H
#define NETime_H

#include "NETypeUtils.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible times of the day for NETime.
 */
typedef NE_ENUM(uint32_t, NETimeTime) {
    NETimeTimeUnknown = 0,
    NETimeTimeEarlyMorning,
    NETimeTimeMorning,
    NETimeTimeBreakfast,
    NETimeTimeBeforeLunch,
    NETimeTimeLunch,
    NETimeTimeAfternoon,
    NETimeTimeEvening,
    NETimeTimeDinner,
    NETimeTimeNight,
    NETimeTimeLateNight
};

/**
 * Possible types of day for NETime.
 */
typedef NE_ENUM(uint32_t, NETimeType) {
    NETimeTypeUnknown = 0,
    NETimeTypeWeekday,
    NETimeTypeWeekend,
    NETimeTypeHoliday
};

/**
 * A representation of semantic time relative to the user's habits, and a type of day.
 *
 * Time of day represents semantic time (e.g. lunch, dinner, evening).
 * Type of day represents whether it is a weekday, weekend, or holiday.
 */
typedef struct NETime {
    /**
     * Semantic time relative to the user's habits.
     */
    NETimeTime time;
    /**
     * Whether the day is a weekend, weekday, or holiday.
     */
    NETimeType type;
} NETime;

/**
 * Default NETime instance.
 */
static const NETime NETime_default = {
    .time = NETimeTimeUnknown,
    .type = NETimeTypeUnknown
};

/**
 * C String array mapping for NETimeTime
 */
static const char * const NETimeTimeStrings[] = {
    [NETimeTimeUnknown] = "Unknown",
    [NETimeTimeEarlyMorning] = "Early Morning",
    [NETimeTimeMorning] = "Morning",
    [NETimeTimeBreakfast] = "Breakfast",
    [NETimeTimeBeforeLunch] = "Before Lunch",
    [NETimeTimeLunch] = "Lunch",
    [NETimeTimeAfternoon] = "Afternoon",
    [NETimeTimeEvening] = "Evening",
    [NETimeTimeDinner] = "Dinner",
    [NETimeTimeNight] = "Night",
    [NETimeTimeLateNight] = "Late Night"
};

static const char * const NETimeTimeReprs[] = {
    [NETimeTimeUnknown] = "unknown",
    [NETimeTimeEarlyMorning] = "early-morning",
    [NETimeTimeMorning] = "morning",
    [NETimeTimeBreakfast] = "breakfast",
    [NETimeTimeBeforeLunch] = "before-lunch",
    [NETimeTimeLunch] = "lunch",
    [NETimeTimeAfternoon] = "afternoon",
    [NETimeTimeEvening] = "evening",
    [NETimeTimeDinner] = "dinner",
    [NETimeTimeNight] = "night",
    [NETimeTimeLateNight] = "late-night"
};

const char * NETime_stringFromTime(NETimeTime timeTime);
const char * NETime_reprFromTime(NETimeTime timeTime);
NETimeTime NETime_timeFromRepr(const char * repr);
/**
 * C String array mapping for NETimeTime
 */
static const char * const NETimeTypeStrings[] = {
        [NETimeTypeUnknown] = "Unknown",
        [NETimeTypeWeekday] = "Weekday",
        [NETimeTypeWeekend] = "Weekend",
        [NETimeTypeHoliday] = "Holiday",
};

static const char * const NETimeTypeReprs[] = {
        [NETimeTypeUnknown] = "unknown",
        [NETimeTypeWeekday] = "weekday",
        [NETimeTypeWeekend] = "weekend",
        [NETimeTypeHoliday] = "holiday",
};

const char * NETime_stringFromType(NETimeType type);
const char * NETime_reprFromType(NETimeType type);
NETimeType NETime_typeFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NETime struct to compare context in it.
 * @param rhsPtr A pointer to an NETime struct to compare against.
 */
bool NETime_isEqual(const NETime * const lhsPtr,
                    const NETime * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NETime_H */
