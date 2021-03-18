/**
 * @file NEPlace.h
 * NEPlace type.
 */

#ifndef NEPlace_H
#define NEPlace_H

#include "NETypeUtils.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/**
 * Possible major types for NEPlace.
 */
typedef NE_ENUM(uint32_t, NEPlaceMajor) {
    // NB: When updating these, also update the situation_home.fll, situation_work.fll etc... files
    NEPlaceMajorUnavailable = 0,
    NEPlaceMajorNotAPlace = 1,
    NEPlaceMajorUnknown = 2,
    NEPlaceMajorAcademic = 3,
    NEPlaceMajorCommercial = 4,
    NEPlaceMajorCultural = 5,
    NEPlaceMajorEntertainment = 6,
    NEPlaceMajorFoodAndDrink = 7,
    NEPlaceMajorOffice = 8,
    NEPlaceMajorRecreational = 9,
    NEPlaceMajorResidential = 10,
    NEPlaceMajorShopsAndServices = 11,
    NEPlaceMajorSport = 12,
    NEPlaceMajorTransportation = 13,
};

/**
 * Possible minor types for NEPlace.
 */
typedef NE_ENUM(uint32_t, NEPlaceMinor) {
    // NB: When updating these, also update the place_penalty.fll file and increment the archive version on PlaceMapSensor
    NEPlaceMinorUnknown = 0,

    // Academic
    NEPlaceMinorLibrary,

    // Commercial

    // Cultural
    NEPlaceMinorArtGallery,
    NEPlaceMinorExhibition,
    NEPlaceMinorHistoricSite,
    NEPlaceMinorMuseum,

    // Entertainment
    NEPlaceMinorCinema,
    NEPlaceMinorConcert,
    NEPlaceMinorFestival,
    NEPlaceMinorStadium,

    // Food and Drink
    NEPlaceMinorBar,
    NEPlaceMinorCafe,
    NEPlaceMinorFoodCourt,
    NEPlaceMinorNightclub,
    NEPlaceMinorRestaurant,

    // Office

    // Recreational
    NEPlaceMinorBeach,
    NEPlaceMinorCampsite,
    NEPlaceMinorGardens,
    NEPlaceMinorHotel,
    NEPlaceMinorLake,
    NEPlaceMinorNatureSite,
    NEPlaceMinorPark,
    NEPlaceMinorRecreationCentre,

    // Residential

    // Shops and Services
    NEPlaceMinorAntiquesShop,
    NEPlaceMinorBank,
    NEPlaceMinorBicycleShop,
    NEPlaceMinorBookShop,
    NEPlaceMinorCarDealership,
    NEPlaceMinorCharity,
    NEPlaceMinorClothingShop,
    NEPlaceMinorConvenienceStore,
    NEPlaceMinorCosmeticsShop,
    NEPlaceMinorDepartmentStore,
    NEPlaceMinorElectronicsShop,
    NEPlaceMinorFabricShop,
    NEPlaceMinorFishingShop,
    NEPlaceMinorFlorist,
    NEPlaceMinorFootwearShop,
    NEPlaceMinorServiceStation,
    NEPlaceMinorHairSalon,
    NEPlaceMinorHardwareShop,
    NEPlaceMinorHealthAndBeauty,
    NEPlaceMinorHomewaresShop,
    NEPlaceMinorHuntingShop,
    NEPlaceMinorLuxuryShop,
    NEPlaceMinorMarket,
    NEPlaceMinorMusicShop,
    NEPlaceMinorOutdoorsShop,
    NEPlaceMinorPetServices,
    NEPlaceMinorPetShop,
    NEPlaceMinorPostalService,
    NEPlaceMinorRealEstateAgent,
    NEPlaceMinorShoppingMall,
    NEPlaceMinorSpecialityFoodsShop,
    NEPlaceMinorSportsShop,
    NEPlaceMinorSupermarketTier1,
    NEPlaceMinorSupermarketTier2,
    NEPlaceMinorSupermarketTier3,
    NEPlaceMinorToyShop,
    NEPlaceMinorTravelAgents,
    NEPlaceMinorVehiclePartsShop,

    // Sport
    NEPlaceMinorGym,
    NEPlaceMinorSportsFacility,
    NEPlaceMinorSportsField,

    // Transportation
    NEPlaceMinorAirport,
    NEPlaceMinorBusStop,
    NEPlaceMinorPort,
    NEPlaceMinorSubwayStation,
    NEPlaceMinorTrainStation,

    NEPlaceMinor_max
};

/**
 * Possible states for context.
 */
typedef NE_ENUM(uint32_t, NEPlaceContextKnowledge) {
    NEPlaceContextKnowledgeUnknown = 0,
    NEPlaceContextKnowledgeNotAtPlace,
    NEPlaceContextKnowledgeAtPlace,
};

/**
 * Possible name states for NEPlaceContextIndex.
 */
typedef NE_ENUM(uint32_t, NEPlaceContextIndex) {
    NEPlaceContextIndexHome = 0,
    NEPlaceContextIndexWork
};

static const NEPlaceContextIndex NEPlaceContextIndex_notFound = (NEPlaceContextIndex)UINT32_MAX;

typedef struct NEPlaceContext {
    NEPlaceContextKnowledge home;
    NEPlaceContextKnowledge work;
} NEPlaceContext;

static const size_t NEPlaceContext_numberOfMembers = sizeof(NEPlaceContext) / sizeof(NEPlaceContextKnowledge);

/**
 * Returns a newly contructed NEPlaceContext object with default knowledges.
 */
extern NEPlaceContext NEPlaceContext_makeDefault(void);

/**
 * Returns a newly contructed NEPlaceContext object with knowledge assigned to each of it's fields.
 *
 * @param knowledge The default knowledge to use.
 */
extern NEPlaceContext NEPlaceContext_makeWithDefaultKnowledge(NEPlaceContextKnowledge knowledge);

extern NEPlaceContextKnowledge NEPlaceContext_knowledgeAt(const NEPlaceContext * const self, NEPlaceContextIndex index);

/**
 * Helper function to determine the context contains a knowledge value at any of it's fields at least once.
 *
 * @param self A pointer to an NEPlaceContext struct.
 */
bool NEPlaceContext_contains(const NEPlaceContext * const self, NEPlaceContextKnowledge knowledge);
bool NEPlaceContext_isEqual(const NEPlaceContext * const lhsPtr, const NEPlaceContext * const rhsPtr);

/**
 * Represents abstract information about a place, including a semantic name, major, and minor type.
 *
 * The context describes whether or not the current place has a semantic meaning to the user (e.g. Home, Work...).
 * The major type represents a high-level category for the type of place.
 * The minor type gives a more granular category representation of the place.
 */
typedef struct NEPlace {
    /**
     * An array describing the possible contexts of a given place for the user.
     * Each type of context has an entry in the array (e.g. Home, Work...) and the respective
     * entry is a ternary, either the current place is of that context, it is not of that context
     * or it is not known whether or not it is of that context.
     */
    union {
        /* public context field */
        NEPlaceContext context;
        /* private _asArray field is forbidden to access from any C++ code, due to anti-aliasing rules of C++ */
        NEPlaceContextKnowledge _asArray[NEPlaceContext_numberOfMembers];
    };
    /**
     * High-level category for the place.
     */
    NEPlaceMajor major;
    /**
     * Granular category for the place.
     */
    NEPlaceMinor minor;
} NEPlace;


/**
 * Default NEPlace instance.
 */
extern const NEPlace NEPlace_default;

/**
 * NEPlace instance representing the case when the place cannot be determined.
 */
extern const NEPlace NEPlace_unavailable;

/**
 * NEPlace instance representing the case when the user is not at a specific place.
 */
extern const NEPlace NEPlace_notAPlace;

/**
 * NEPlace instance representing the case when the place type is unknown.
 */
extern const NEPlace NEPlace_unknown;

/**
 * C String array mapping for NEPlaceContextKnowledge
 */
static const char * const NEPlaceContextKnowledgeStrings[] = {
    [NEPlaceContextKnowledgeUnknown] = "Unknown",
    [NEPlaceContextKnowledgeNotAtPlace] = "Not At Place",
    [NEPlaceContextKnowledgeAtPlace] = "At Place"
};

static const char * const NEPlaceContextKnowledgeReprs[] = {
    [NEPlaceContextKnowledgeUnknown] = "unknown",
    [NEPlaceContextKnowledgeNotAtPlace] = "not-at-place",
    [NEPlaceContextKnowledgeAtPlace] = "at-place"
};


const char * NEPlace_stringFromContextKnowledge(NEPlaceContextKnowledge context);
const char * NEPlace_reprFromContextKnowledge(NEPlaceContextKnowledge context);
NEPlaceContextKnowledge NEPlace_contextKnowledgeFromRepr(const char * repr);

/**
 * C String array mapping for NEPlaceContextIndex
 */
static const char * const NEPlaceContextIndexStrings[] = {
    [NEPlaceContextIndexHome] = "Home",
    [NEPlaceContextIndexWork] = "Work"
};

static const char * const NEPlaceContextIndexReprs[] = {
    [NEPlaceContextIndexHome] = "home",
    [NEPlaceContextIndexWork] = "work"
};

const char * NEPlace_stringFromContextIndex(NEPlaceContextIndex contextIndex);
const char * NEPlace_reprFromContextIndex(NEPlaceContextIndex contextIndex);
NEPlaceContextIndex NEPlace_contextIndexFromRepr(const char * repr);

/**
 * C String array mapping for NEPlaceMajor
 */
static const char * const NEPlaceMajorStrings[] = {
    [NEPlaceMajorUnavailable] = "Unavailable",
    [NEPlaceMajorNotAPlace] = "Not A Place",
    [NEPlaceMajorUnknown] = "Unknown Place Type",
    [NEPlaceMajorAcademic] = "Academic Facility",
    [NEPlaceMajorCommercial] = "Commercial Facility",
    [NEPlaceMajorCultural] = "Cultural Site",
    [NEPlaceMajorEntertainment] = "Entertainment Venue",
    [NEPlaceMajorFoodAndDrink] = "Food/Drink Related",
    [NEPlaceMajorOffice] = "Office Building",
    [NEPlaceMajorRecreational] = "Recreational Site",
    [NEPlaceMajorResidential] = "Residential Area",
    [NEPlaceMajorShopsAndServices] = "Shops and Services",
    [NEPlaceMajorSport] = "Sports Facility",
    [NEPlaceMajorTransportation] = "Transport Station",
};

static const char * const NEPlaceMajorReprs[] = {
    [NEPlaceMajorUnavailable] = "unavailable",
    [NEPlaceMajorNotAPlace] = "not-a-place",
    [NEPlaceMajorUnknown] = "unknown",
    [NEPlaceMajorAcademic] = "academic",
    [NEPlaceMajorCommercial] = "commercial",
    [NEPlaceMajorCultural] = "cultural",
    [NEPlaceMajorEntertainment] = "entertainment",
    [NEPlaceMajorFoodAndDrink] = "food-and-drink",
    [NEPlaceMajorOffice] = "office",
    [NEPlaceMajorRecreational] = "recreational",
    [NEPlaceMajorResidential] = "residential",
    [NEPlaceMajorShopsAndServices] = "shops-and-services",
    [NEPlaceMajorSport] = "sport",
    [NEPlaceMajorTransportation] = "transportation",
};

const char * NEPlace_stringFromMajor(NEPlaceMajor major);
const char * NEPlace_reprFromMajor(NEPlaceMajor major);
NEPlaceMajor NEPlace_majorFromRepr(const char * repr);

static const char * const NEPlaceMinorStrings[] = {
    [NEPlaceMinorUnknown] = "Unknown",

    [NEPlaceMinorLibrary] = "Library",

    [NEPlaceMinorArtGallery] = "Art Gallery",
    [NEPlaceMinorExhibition] = "Exhibition",
    [NEPlaceMinorHistoricSite] = "Historic Site",
    [NEPlaceMinorMuseum] = "Museum",

    [NEPlaceMinorCinema] = "Cinema",
    [NEPlaceMinorConcert] = "Concert",
    [NEPlaceMinorFestival] = "Festival",
    [NEPlaceMinorStadium] = "Stadium",

    [NEPlaceMinorBar] = "Bar",
    [NEPlaceMinorCafe] = "Cafe",
    [NEPlaceMinorFoodCourt] = "Food Court",
    [NEPlaceMinorNightclub] = "Nightclub",
    [NEPlaceMinorRestaurant] = "Restaurant",

    [NEPlaceMinorBeach] = "Beach",
    [NEPlaceMinorCampsite] = "Campsite",
    [NEPlaceMinorGardens] = "Gardens",
    [NEPlaceMinorHotel] = "Hotel",
    [NEPlaceMinorLake] = "Lake",
    [NEPlaceMinorNatureSite] = "Nature Site",
    [NEPlaceMinorPark] = "Park",
    [NEPlaceMinorRecreationCentre] = "Recreation Centre",

    [NEPlaceMinorAntiquesShop] = "Antiques Shop",
    [NEPlaceMinorBank] = "Bank",
    [NEPlaceMinorBicycleShop] = "Bicycle Shop",
    [NEPlaceMinorBookShop] = "Book Shop",
    [NEPlaceMinorCarDealership] = "Car Dealershop",
    [NEPlaceMinorCharity] = "Charity",
    [NEPlaceMinorClothingShop] = "Clothing Shop",
    [NEPlaceMinorConvenienceStore] = "Convenience Store",
    [NEPlaceMinorCosmeticsShop] = "Cosmetics Shop",
    [NEPlaceMinorDepartmentStore] = "Department Store",
    [NEPlaceMinorElectronicsShop] = "Electronics Shop",
    [NEPlaceMinorFabricShop] = "Fabric Shop",
    [NEPlaceMinorFishingShop] = "Fishing Shop",
    [NEPlaceMinorFlorist] = "Florist",
    [NEPlaceMinorFootwearShop] = "Footwear Shop",
    [NEPlaceMinorServiceStation] = "Service Station",
    [NEPlaceMinorHairSalon] = "Hair Salon",
    [NEPlaceMinorHardwareShop] = "Hardware Shop",
    [NEPlaceMinorHealthAndBeauty] = "Health and Beauty",
    [NEPlaceMinorHomewaresShop] = "Homewares Shop",
    [NEPlaceMinorHuntingShop] = "Hunting Shop",
    [NEPlaceMinorLuxuryShop] = "Luxury Shop",
    [NEPlaceMinorMarket] = "Market",
    [NEPlaceMinorMusicShop] = "Music Shop",
    [NEPlaceMinorOutdoorsShop] = "Outdoors Shop",
    [NEPlaceMinorPetServices] = "Pet Services",
    [NEPlaceMinorPetShop] = "Pet Shop",
    [NEPlaceMinorPostalService] = "Postal Service",
    [NEPlaceMinorRealEstateAgent] = "Real Estate Agent",
    [NEPlaceMinorShoppingMall] = "Shopping Mall",
    [NEPlaceMinorSpecialityFoodsShop] = "Speciality Food Shop",
    [NEPlaceMinorSportsShop] = "Sports Shop",
    [NEPlaceMinorSupermarketTier1] = "Supermarket",
    [NEPlaceMinorSupermarketTier2] = "Supermarket",
    [NEPlaceMinorSupermarketTier3] = "Supermarket",
    [NEPlaceMinorToyShop] = "Toy Shop",
    [NEPlaceMinorTravelAgents] = "Travel Agents",
    [NEPlaceMinorVehiclePartsShop] = "Vehicle Parts Shop",

    [NEPlaceMinorGym] = "Gym",
    [NEPlaceMinorSportsFacility] = "Sports Facility",
    [NEPlaceMinorSportsField] = "Sports Field",

    [NEPlaceMinorAirport] = "Airport",
    [NEPlaceMinorBusStop] = "Bus Stop",
    [NEPlaceMinorPort] = "Port",
    [NEPlaceMinorSubwayStation] = "Subway Station",
    [NEPlaceMinorTrainStation] = "Train Station",
};

static const char * const NEPlaceMinorReprs[] = {
    [NEPlaceMinorUnknown] = "unknown",

    [NEPlaceMinorLibrary] = "library",

    [NEPlaceMinorArtGallery] = "art-gallery",
    [NEPlaceMinorExhibition] = "exhibition",
    [NEPlaceMinorHistoricSite] = "historic-site",
    [NEPlaceMinorMuseum] = "museum",

    [NEPlaceMinorCinema] = "cinema",
    [NEPlaceMinorConcert] = "concert",
    [NEPlaceMinorFestival] = "festival",
    [NEPlaceMinorStadium] = "stadium",

    [NEPlaceMinorBar] = "bar",
    [NEPlaceMinorCafe] = "cafe",
    [NEPlaceMinorFoodCourt] = "food-court",
    [NEPlaceMinorNightclub] = "nightclub",
    [NEPlaceMinorRestaurant] = "restaurant",

    [NEPlaceMinorBeach] = "beach",
    [NEPlaceMinorCampsite] = "campsite",
    [NEPlaceMinorGardens] = "gardens",
    [NEPlaceMinorHotel] = "hotel",
    [NEPlaceMinorLake] = "lake",
    [NEPlaceMinorNatureSite] = "nature-site",
    [NEPlaceMinorPark] = "park",
    [NEPlaceMinorRecreationCentre] = "recreation-centre",

    [NEPlaceMinorAntiquesShop] = "antiques-shop",
    [NEPlaceMinorBank] = "bank",
    [NEPlaceMinorBicycleShop] = "bicycle-shop",
    [NEPlaceMinorBookShop] = "book-shop",
    [NEPlaceMinorCarDealership] = "car-dealershop",
    [NEPlaceMinorCharity] = "charity",
    [NEPlaceMinorClothingShop] = "clothing-shop",
    [NEPlaceMinorConvenienceStore] = "convenience-store",
    [NEPlaceMinorCosmeticsShop] = "cosmetics-shop",
    [NEPlaceMinorDepartmentStore] = "department-store",
    [NEPlaceMinorElectronicsShop] = "electronics-shop",
    [NEPlaceMinorFabricShop] = "fabric-shop",
    [NEPlaceMinorFishingShop] = "fishing-shop",
    [NEPlaceMinorFlorist] = "florist",
    [NEPlaceMinorFootwearShop] = "footwear-shop",
    [NEPlaceMinorServiceStation] = "service-station",
    [NEPlaceMinorHairSalon] = "hair-salon",
    [NEPlaceMinorHardwareShop] = "hardware-shop",
    [NEPlaceMinorHealthAndBeauty] = "health-and-beauty",
    [NEPlaceMinorHomewaresShop] = "homewares-shop",
    [NEPlaceMinorHuntingShop] = "hunting-shop",
    [NEPlaceMinorLuxuryShop] = "luxury-shop",
    [NEPlaceMinorMarket] = "market",
    [NEPlaceMinorMusicShop] = "music-shop",
    [NEPlaceMinorOutdoorsShop] = "outdoors-shop",
    [NEPlaceMinorPetServices] = "pet-services",
    [NEPlaceMinorPetShop] = "pet-shop",
    [NEPlaceMinorPostalService] = "postal-service",
    [NEPlaceMinorRealEstateAgent] = "real-estate-agent",
    [NEPlaceMinorShoppingMall] = "shopping-mall",
    [NEPlaceMinorSpecialityFoodsShop] = "speciality-food-shop",
    [NEPlaceMinorSportsShop] = "sports-shop",
    [NEPlaceMinorSupermarketTier1] = "supermarket-tier-1",
    [NEPlaceMinorSupermarketTier2] = "supermarket-tier-2",
    [NEPlaceMinorSupermarketTier3] = "supermarket-tier-3",
    [NEPlaceMinorToyShop] = "toy-shop",
    [NEPlaceMinorTravelAgents] = "travel-agents",
    [NEPlaceMinorVehiclePartsShop] = "vehicle-parts-shop",

    [NEPlaceMinorGym] = "gym",
    [NEPlaceMinorSportsFacility] = "sports-facility",
    [NEPlaceMinorSportsField] = "sports-field",

    [NEPlaceMinorAirport] = "airport",
    [NEPlaceMinorBusStop] = "bus-stop",
    [NEPlaceMinorPort] = "port",
    [NEPlaceMinorSubwayStation] = "subway-station",
    [NEPlaceMinorTrainStation] = "train-station",
};

const char * NEPlace_stringFromMinor(NEPlaceMinor minor);
const char * NEPlace_reprFromMinor(NEPlaceMinor minor);
NEPlaceMinor NEPlace_minorFromRepr(const char * repr);

extern void NEPlace_setContextKnowledgeAt(NEPlace * const self,
                                          NEPlaceContextIndex index,
                                          NEPlaceContextKnowledge newKnowledge);

extern NEPlaceContextKnowledge NEPlace_contextKnowledgeAt(const NEPlace * const self,
                                                          NEPlaceContextIndex index);


void NEPlace_setAllContextFields(NEPlace * const self, NEPlaceContextKnowledge toKnowledge);

/**
 * Returns true if the all the fields are identical in the two NEPlaceContexts objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEPlace struct to compare context in it.
 * @param rhsPtr A pointer to an NEPlace struct to compare against.
 */
bool NEPlace_isContextEqual(const NEPlace * const lhsPtr, const NEPlace * const rhsPtr);

/**
 * Helper function to determine the context contains a knowledge value at any of it's fields at least once.
 *
 * @param self A pointer to an NEPlace struct must not be NULL.
 * @param contextKnowledge The contextKnowledge to search for.
 */
bool NEPlace_containsContextKnowledge(const NEPlace * const self,
                                      NEPlaceContextKnowledge contextKnowledge);

/**
 * Returns true if all the fields are identical in the two objects, false otherwise.
 *
 * @param lhsPtr A pointer to an NEPlace struct to compare context in it.
 * @param rhsPtr A pointer to an NEPlace struct to compare against.
 */
bool NEPlace_isEqual(const NEPlace * const lhsPtr, const NEPlace * const rhsPtr);

/**
 * Returns true if the two objects are semantically equivalent, false otherwise.
 * Checks major and minor type, unless one or more are unknown, followed by context.
 *
 * @param lhsPtr A pointer to an NEPlace struct to compare context in it.
 * @param rhsPtr A pointer to an NEPlace struct to compare against.
 */
bool NEPlace_isSemanticallyEqual(const NEPlace * const lhsPtr,
                                 const NEPlace * const rhsPtr);

#ifdef __cplusplus
}
#endif

#endif /* NEPlace_H */
