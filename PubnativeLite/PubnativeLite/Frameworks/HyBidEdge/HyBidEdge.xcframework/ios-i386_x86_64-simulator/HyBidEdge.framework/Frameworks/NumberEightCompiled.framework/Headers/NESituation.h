/**
 * @file NESituation.h
 * NESituation type.
 */

#ifndef NESituation_H
#define NESituation_H

#include "NETypeUtils.h"
#include <ctype.h>
#include <string.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Possible states for NESituation.
 */
typedef NE_ENUM(uint32_t, NESituationMajor) {
    NESituationMajorUnknown = 0,
    NESituationMajorHousework = 1,
    NESituationMajorLeisure = 2,
    NESituationMajorMorningRituals = 3,
    NESituationMajorShopping = 4,
    NESituationMajorSleeping = 5,
    NESituationMajorSocial = 6,
    NESituationMajorTravelling = 7,
    NESituationMajorWorking = 8,
    NESituationMajorWorkingOut = 9
};

typedef NE_ENUM(uint32_t, NESituationMinor) {
    NESituationMinorUnknown = 0,
    NESituationMinorAtABeach = 1,
    NESituationMinorAtAGym = 2,
    NESituationMinorAtALibrary = 3,
    NESituationMinorBrowsingGardens = 4,
    NESituationMinorCamping = 5,
    NESituationMinorClubbing = 6,
    NESituationMinorDining = 7,
    NESituationMinorHavingCoffee = 8,
    NESituationMinorHavingDrinks = 9,
    NESituationMinorInAnOffice = 10,
    NESituationMinorInAPark = 11,
    NESituationMinorLeisureTravel = 12,
    NESituationMinorMajorEvent = 13,
    NESituationMinorOutdoorSports = 14,
    NESituationMinorPartying = 15,
    NESituationMinorViewingArt = 16,
    NESituationMinorWatchingMovies = 17,
    NESituationMinorWorkTravel = 18
};

/**
 * Represents the overall situation of the user, comprising a major and minor type.
 *
 * The major type is the high-level situation of the user.
 * The minor type is a more granular situation.
 */
typedef struct NESituation {
    /**
     * A high-level representation of the user's situation.
     */
    NESituationMajor major;
    /**
     * A granular representation of the user's situation.
     */
    NESituationMinor minor;
} NESituation;

/**
 * Default NESituation instance.
 */
static const NESituation NESituation_default = {
    .major = NESituationMajorUnknown, 
    .minor = NESituationMinorUnknown 
};

/**
 * C String array mapping for NESituationMajor
 */
static const char * const NESituationMajorStrings[] = {
        [NESituationMajorUnknown] = "Unknown",
        [NESituationMajorMorningRituals] = "Morning Rituals",
        [NESituationMajorTravelling] = "Travelling",
        [NESituationMajorWorking] = "Working",
        [NESituationMajorWorkingOut] = "Working Out",
        [NESituationMajorShopping] = "Shopping",
        [NESituationMajorLeisure] = "Leisure",
        [NESituationMajorSocial] = "Social",
        [NESituationMajorHousework] = "Doing Housework",
        [NESituationMajorSleeping] = "Sleeping",
};

static const char * const NESituationMajorReprs[] = {
        [NESituationMajorUnknown] = "unknown",
        [NESituationMajorMorningRituals] = "morning-rituals",
        [NESituationMajorTravelling] = "travelling",
        [NESituationMajorWorking] = "working",
        [NESituationMajorWorkingOut] = "working-out",
        [NESituationMajorShopping] = "shopping",
        [NESituationMajorLeisure] = "leisure",
        [NESituationMajorSocial] = "social",
        [NESituationMajorHousework] = "housework",
        [NESituationMajorSleeping] = "sleeping",
};

const char * NESituation_stringFromMajor(NESituationMajor major);
const char * NESituation_reprFromMajor(NESituationMajor major);
NESituationMajor NESituation_majorFromRepr(const char * repr);

/**
 * C String array mapping for NESituationMinor
 */
static const char * const NESituationMinorStrings[] = {
        [NESituationMinorUnknown] = "Unknown",
        [NESituationMinorAtABeach] = "On a Beach",
        [NESituationMinorAtAGym] = "At a Gym",
        [NESituationMinorAtALibrary] = "At a Library",
        [NESituationMinorBrowsingGardens] = "Browsing Gardens",
        [NESituationMinorCamping] = "Camping",
        [NESituationMinorClubbing] = "Clubbing",
        [NESituationMinorDining] = "Dining",
        [NESituationMinorHavingCoffee] = "Having Coffee",
        [NESituationMinorHavingDrinks] = "Having Drinks",
        [NESituationMinorInAnOffice] = "In an Office",
        [NESituationMinorInAPark] = "In a Park",
        [NESituationMinorLeisureTravel] = "Travelling",
        [NESituationMinorMajorEvent] = "At a Major Entertainment Event",
        [NESituationMinorOutdoorSports] = "Playing Sports",
        [NESituationMinorPartying] = "Partying",
        [NESituationMinorViewingArt] = "Viewing Art",
        [NESituationMinorWatchingMovies] = "Watching Movies",
        [NESituationMinorWorkTravel] = "Commuting",
};

static const char * const NESituationMinorReprs[] = {
        [NESituationMinorUnknown] = "unknown",
        [NESituationMinorAtABeach] = "at-a-beach",
        [NESituationMinorAtAGym] = "at-a-gym",
        [NESituationMinorAtALibrary] = "at-a-library",
        [NESituationMinorBrowsingGardens] = "browsing-gardens",
        [NESituationMinorCamping] = "camping",
        [NESituationMinorClubbing] = "clubbing",
        [NESituationMinorDining] = "dining",
        [NESituationMinorHavingCoffee] = "having-coffee",
        [NESituationMinorHavingDrinks] = "having-drinks",
        [NESituationMinorInAnOffice] = "in-an-office",
        [NESituationMinorInAPark] = "in-a-park",
        [NESituationMinorLeisureTravel] = "leisure-travel",
        [NESituationMinorMajorEvent] = "major-event",
        [NESituationMinorOutdoorSports] = "outdoor-sports",
        [NESituationMinorPartying] = "partying",
        [NESituationMinorViewingArt] = "viewing-art",
        [NESituationMinorWatchingMovies] = "watching-movies",
        [NESituationMinorWorkTravel] = "work-travel",
};

const char * NESituation_stringFromMinor(NESituationMinor minor);
const char * NESituation_reprFromMinor(NESituationMinor minor);
NESituationMinor NESituation_minorFromRepr(const char * repr);

/**
 * Returns true if the all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NESituation struct to compare context in it.
 * @param rhsPtr A pointer to an NESituation struct to compare against.
 */
bool NESituation_isEqual(const NESituation * const lhsPtr,
                         const NESituation * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NESituation_H */
