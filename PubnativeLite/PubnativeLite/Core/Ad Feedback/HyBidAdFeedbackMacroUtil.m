// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdFeedbackMacroUtil.h"
#import "HyBidAdFeedbackParameters.h"
#import "HyBidStringUtils.h"

#define HYBID_AD_FEEDBACK_MACRO_AUDIO_STATE @"${AUDIOSTATE}"
#define HYBID_AD_FEEDBACK_MACRO_APP_VERSION @"${APPVERSION}"
#define HYBID_AD_FEEDBACK_MACRO_DEVICE_INFO @"${DEVICEINFO}"
#define HYBID_AD_FEEDBACK_MACRO_SDK_VERSION @"${SDKVERSION}"
#define HYBID_AD_FEEDBACK_MACRO_ZONE_ID @"${ZONEID}"
#define HYBID_AD_FEEDBACK_MACRO_CREATIVE_ID @"${CREATIVEID}"
#define HYBID_AD_FEEDBACK_MACRO_IMPRESSION_BEACON @"${IMPRESSIONBEACON}"
#define HYBID_AD_FEEDBACK_MACRO_INTEGRATION_TYPE @"${INTEGRATIONTYPE}"
#define HYBID_AD_FEEDBACK_MACRO_AD_FORMAT @"${ADFORMAT}"
#define HYBID_AD_FEEDBACK_MACRO_HAS_END_CARD @"${HASENDCARD}"

@implementation HyBidAdFeedbackMacroUtil

+ (NSString *)formatUrl:(NSString *)feedbackUrl withZoneID:(NSString *)zoneID {
    [HyBidAdFeedbackParameters sharedInstance].requestedZoneID = zoneID;
    
    if ([HyBidAdFeedbackParameters sharedInstance].appToken && [HyBidAdFeedbackParameters sharedInstance].appToken.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_APP_TOKEN replacement:[HyBidAdFeedbackParameters sharedInstance].appToken] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].audioState && [HyBidAdFeedbackParameters sharedInstance].audioState.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_AUDIO_STATE replacement:[HyBidAdFeedbackParameters sharedInstance].audioState] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].appVersion && [HyBidAdFeedbackParameters sharedInstance].appVersion.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_APP_VERSION replacement:[HyBidAdFeedbackParameters sharedInstance].appVersion] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].deviceInfo && [HyBidAdFeedbackParameters sharedInstance].deviceInfo.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_DEVICE_INFO replacement:[HyBidAdFeedbackParameters sharedInstance].deviceInfo] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].sdkVersion && [HyBidAdFeedbackParameters sharedInstance].sdkVersion.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_SDK_VERSION replacement:[HyBidAdFeedbackParameters sharedInstance].sdkVersion] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].zoneID && [HyBidAdFeedbackParameters sharedInstance].zoneID.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_ZONE_ID replacement:[HyBidAdFeedbackParameters sharedInstance].zoneID] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].creativeID && [HyBidAdFeedbackParameters sharedInstance].creativeID.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_CREATIVE_ID replacement:[HyBidAdFeedbackParameters sharedInstance].creativeID] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].impressionBeacon && [HyBidAdFeedbackParameters sharedInstance].impressionBeacon.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_IMPRESSION_BEACON replacement:[HyBidAdFeedbackParameters sharedInstance].impressionBeacon] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].integrationType && [HyBidAdFeedbackParameters sharedInstance].integrationType.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_INTEGRATION_TYPE replacement:[HyBidAdFeedbackParameters sharedInstance].integrationType] ?: feedbackUrl;
    }

    if ([HyBidAdFeedbackParameters sharedInstance].adFormat && [HyBidAdFeedbackParameters sharedInstance].adFormat.length != 0) {
        feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_AD_FORMAT replacement:[HyBidAdFeedbackParameters sharedInstance].adFormat] ?: feedbackUrl;
    }

    feedbackUrl = [HyBidStringUtils safeReplaceInValue:feedbackUrl target:HYBID_AD_FEEDBACK_MACRO_HAS_END_CARD replacement:[HyBidAdFeedbackParameters sharedInstance].hasEndCard ? @"true" : @"false"] ?: feedbackUrl;

    return [feedbackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
