// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidError.h"

NSString * const kHyBidErrorDomain = @"net.pubnative.PubnativeLite";

@implementation NSError (HyBid)

+ (NSError *)errorWithCode:(HyBidErrorCode)code localizedDescription:(NSString *)description {
    NSDictionary * userInfo = nil;
    if (description != nil) {
        userInfo = @{ NSLocalizedDescriptionKey: description };
    }

    return [self errorWithDomain:kHyBidErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)hyBidNoFill {
    return [NSError errorWithCode:HyBidErrorCodeNoFill localizedDescription:@"HyBid - No fill"];
}

+ (instancetype)hyBidParseError {
    return [NSError errorWithCode:HyBidErrorCodeParse localizedDescription:@"Can't parse JSON from server"];
}

+ (instancetype)hyBidServerError {
    return [NSError errorWithCode:HyBidErrorCodeServer localizedDescription:@"HyBid - Server error"];
}

+ (instancetype)hyBidServerErrorWithMessage:(NSString *)message {
    if (message != nil) {
        return [NSError errorWithCode:HyBidErrorCodeServer localizedDescription:[@"HyBid - Server error: " stringByAppendingString: message]];
    }
    return [NSError errorWithCode:HyBidErrorCodeServer localizedDescription:@"HyBid - Server error"];
}

+ (instancetype)hyBidInvalidAsset {
    return [NSError errorWithCode:HyBidErrorCodeInvalidAsset localizedDescription:@"The server has returned an invalid ad asset"];
}

+ (instancetype)hyBidUnsupportedAsset {
    return [NSError errorWithCode:HyBidErrorCodeUnsupportedAsset localizedDescription:@"The server has returned an unsupported ad asset"];
}

+ (instancetype)hyBidNullAd {
    return [NSError errorWithCode:HyBidErrorCodeNullAd localizedDescription:@"Server returned null ad"];
}

+ (instancetype)hyBidInvalidAd {
    return [NSError errorWithCode:HyBidErrorCodeInvalidAd localizedDescription:@"The provided ad is invalid"];
}

+ (instancetype)hyBidInvalidZoneId {
    return [NSError errorWithCode:HyBidErrorCodeInvalidZoneId localizedDescription:@"Invalid zone id provided"];
}

+ (instancetype)hyBidInvalidSignalData {
    return [NSError errorWithCode:HyBidErrorCodeInvalidSignalData localizedDescription:@"Invalid signal data provided"];
}

+ (instancetype)hyBidNotInitialised {
    return [NSError errorWithCode:HyBidErrorCodeNotInitialised localizedDescription:@"The HyBid SDK has not been initialised"];
}

+ (instancetype)hyBidAuctionNoAd {
    return [NSError errorWithCode:HyBidErrorCodeAuctionNoAd localizedDescription:@"The auction returned no ad"];
}

+ (instancetype)hyBidRenderingBanner {
    return [NSError errorWithCode:HyBidErrorCodeRenderingBanner localizedDescription:@"An error has occurred while rendering the ad"];
}

+ (instancetype)hyBidRenderingInterstitial {
    return [NSError errorWithCode:HyBidErrorCodeRenderingInterstitial localizedDescription:@"An error has occurred while rendering the interstitial"];
}

+ (instancetype)hyBidRenderingRewarded {
    return [NSError errorWithCode:HyBidErrorCodeRenderingRewarded localizedDescription:@"An error has occurred while rendering the rewarded ad"];
}

+ (instancetype)hyBidMraidPlayer {
    return [NSError errorWithCode:HyBidErrorCodeMraidPlayer localizedDescription:@"Error rendering HTML/MRAID ad"];
}

+ (instancetype)hyBidVastPlayer {
    return [NSError errorWithCode:HyBidErrorCodeVastPlayer localizedDescription:@"Error rendering VAST ad"];
}

+ (instancetype)hyBidTrackingUrl {
    return [NSError errorWithCode:HyBidErrorCodeTrackingUrl localizedDescription:@"Error reporting URL tracker"];
}

+ (instancetype)hyBidTrackingJS {
    return [NSError errorWithCode:HyBidErrorCodeTrackingJS localizedDescription:@"Error reporting JS tracker"];
}

+ (instancetype)hyBidInvalidUrl {
    return [NSError errorWithCode:HyBidErrorCodeInvalidUrl localizedDescription:@"Invalid request URL"];
}

+ (instancetype)hyBidInternalError {
    return [NSError errorWithCode:HyBidErrorCodeInternal localizedDescription:@"An internal error has occurred in the HyBid SDK"];
}

+ (instancetype)hyBidUnknownError {
    return [NSError errorWithCode:HyBidErrorCodeUnknown localizedDescription:@"An unknown error has occurred in the HyBid SDK"];
}

+ (instancetype)hyBidDisabledFormatError {
    return [NSError errorWithCode:HyBidErrorCodeDisabledFormat localizedDescription:@"The requested ad format has been disabled"];
}

+ (instancetype)hyBidDisabledRenderingEngineError {
    return [NSError errorWithCode:HyBidErrorCodeDisabledRenderingEngine localizedDescription:@"The requested rendering engine has been disabled"];
}

+ (instancetype)hyBidExpiredAd {
    return [NSError errorWithCode:HyBidExpiredAd localizedDescription:@"The ad has expired"];
}

+ (instancetype)hyBidVASTParserMovieTooShortError
{
    return [NSError errorWithCode:HyBidErrorVASTParserMovieTooShort localizedDescription:@"HyBid VAST Parser - Movie is too short"];
}

+ (instancetype)hyBidVASTParserNoInternetConnectionError
{
    return [NSError errorWithCode:HyBidErrorVASTParserNoInternetConnection localizedDescription:@"HyBid VAST Parser - No internet connection"];
}

+ (instancetype)hyBidVASTParserNoCompatibleMediaFileError
{
    return [NSError errorWithCode:HyBidErrorVASTParserNoCompatibleMediaFile localizedDescription:@"HyBid VAST Parser - No compatible media file"];
}

+ (instancetype)hyBidVASTParserTooManyWrappersError
{
    return [NSError errorWithCode:HyBidErrorVASTParserTooManyWrappers localizedDescription:@"Too many wrappers"];
}

+ (instancetype)hyBidVASTParserSchemaValidationError
{
    return [NSError errorWithCode:HyBidErrorVASTParserSchemaValidation localizedDescription:@"HyBid VAST Parser - Schema validation error"];
}

+ (instancetype)hyBidAdFeedbackFormNotLoaded {
    return [NSError errorWithCode:HyBidErrorVASTParserSchemaValidation localizedDescription:@"An error has ocurred while loading the ad feedback form"];
}

+ (instancetype)hyBidInvalidHTML {
    return [NSError errorWithCode:HyBidErrorVASTParserSchemaValidation localizedDescription:@"Invalid HTML"];
}

+ (instancetype)hyBidVASTNoAdResponse {
    return [NSError errorWithCode:HyBidErrorVASTParserNoAdResponse localizedDescription:@"Server does not or cannot return an Ad"];
}

+ (instancetype)hyBidVASTBothAdAndErrorPresentInRootResponse {
    return [NSError errorWithCode:HyBidErrorVASTParserNoAdResponse localizedDescription:@"An error has been detected on the root of the VAST response"];
}

+ (instancetype)hyBidInvalidCustomCTAIconUrl {
    return [NSError errorWithCode:HyBidErrorCodeInvalidCustomCTAIconUrl localizedDescription:@"Invalid icon URL of custom CTA"];
}

+ (instancetype)hyBidInvalidRemoteConfigData {
    return [NSError errorWithCode:HyBidErrorCodeInvalidRemoteConfigData localizedDescription:@"Invalid remote config data provided"];
}

@end
