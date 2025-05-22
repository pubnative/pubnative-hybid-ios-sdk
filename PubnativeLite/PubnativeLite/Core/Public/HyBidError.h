// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

extern NSString * const kHyBidErrorDomain;

typedef enum {
    HyBidErrorCodeNoFill = 1,
    HyBidErrorCodeParse = 2,
    HyBidErrorCodeServer = 3,
    HyBidErrorCodeInvalidAsset = 4,
    HyBidErrorCodeUnsupportedAsset = 5,
    HyBidErrorCodeNullAd = 6,
    HyBidErrorCodeInvalidAd = 7,
    HyBidErrorCodeInvalidZoneId = 8,
    HyBidErrorCodeInvalidSignalData = 9,
    HyBidErrorCodeNotInitialised = 10,
    HyBidErrorCodeAuctionNoAd = 11,
    HyBidErrorCodeRenderingBanner = 12,
    HyBidErrorCodeRenderingInterstitial = 13,
    HyBidErrorCodeRenderingRewarded = 14,
    HyBidErrorCodeMraidPlayer = 15,
    HyBidErrorCodeVastPlayer = 16,
    HyBidErrorCodeTrackingUrl = 17,
    HyBidErrorCodeTrackingJS = 18,
    HyBidErrorCodeInvalidUrl = 19,
    HyBidErrorCodeInternal = 20,
    HyBidErrorCodeUnknown = 21,
    HyBidErrorCodeDisabledFormat = 22,
    HyBidErrorCodeDisabledRenderingEngine = 23,
    HyBidExpiredAd = 24,
    HyBidErrorVASTParserSchemaValidation = 25,
    HyBidErrorVASTParserTooManyWrappers = 26,
    HyBidErrorVASTParserNoCompatibleMediaFile = 27,
    HyBidErrorVASTParserNoInternetConnection = 28,
    HyBidErrorVASTParserMovieTooShort = 29,
    HyBidErrorCodeAdFeedbackFormNotLoaded = 30,
    HyBidErrorCodeInvalidHTML = 31,
    HyBidErrorVASTParserNoAdResponse = 32,
    HyBidErrorVASTParserBothAdAndErrorPresentInRootResponse = 33,
    HyBidErrorCodeInvalidCustomCTAIconUrl = 34,
    HyBidErrorCodeInvalidRemoteConfigData = 35
} HyBidErrorCode;

@interface NSError (HyBid)

+ (NSError *)errorWithCode:(HyBidErrorCode)code localizedDescription:(NSString *)description;

+ (instancetype)hyBidNoFill;
+ (instancetype)hyBidParseError;
+ (instancetype)hyBidServerError;
+ (instancetype)hyBidServerErrorWithMessage:(NSString *) message;
+ (instancetype)hyBidInvalidAsset;
+ (instancetype)hyBidUnsupportedAsset;
+ (instancetype)hyBidNullAd;
+ (instancetype)hyBidInvalidAd;
+ (instancetype)hyBidInvalidZoneId;
+ (instancetype)hyBidInvalidSignalData;
+ (instancetype)hyBidNotInitialised;
+ (instancetype)hyBidAuctionNoAd;
+ (instancetype)hyBidRenderingBanner;
+ (instancetype)hyBidRenderingInterstitial;
+ (instancetype)hyBidRenderingRewarded;
+ (instancetype)hyBidMraidPlayer;
+ (instancetype)hyBidVastPlayer;
+ (instancetype)hyBidTrackingUrl;
+ (instancetype)hyBidTrackingJS;
+ (instancetype)hyBidInvalidUrl;
+ (instancetype)hyBidInternalError;
+ (instancetype)hyBidUnknownError;
+ (instancetype)hyBidDisabledFormatError;
+ (instancetype)hyBidDisabledRenderingEngineError;
+ (instancetype)hyBidExpiredAd;
+ (instancetype)hyBidVASTParserSchemaValidationError;
+ (instancetype)hyBidVASTParserTooManyWrappersError;
+ (instancetype)hyBidVASTParserNoCompatibleMediaFileError;
+ (instancetype)hyBidVASTParserNoInternetConnectionError;
+ (instancetype)hyBidVASTParserMovieTooShortError;
+ (instancetype)hyBidAdFeedbackFormNotLoaded;
+ (instancetype)hyBidInvalidHTML;
+ (instancetype)hyBidVASTNoAdResponse;
+ (instancetype)hyBidVASTBothAdAndErrorPresentInRootResponse;
+ (instancetype)hyBidInvalidCustomCTAIconUrl;
+ (instancetype)hyBidInvalidRemoteConfigData;

@end
