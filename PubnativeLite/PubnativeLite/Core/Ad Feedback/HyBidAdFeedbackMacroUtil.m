// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdFeedbackMacroUtil.h"
#import "HyBidAdFeedbackParameters.h"

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
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_APP_TOKEN
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].appToken];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].audioState && [HyBidAdFeedbackParameters sharedInstance].audioState.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_AUDIO_STATE
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].audioState];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].appVersion && [HyBidAdFeedbackParameters sharedInstance].appVersion.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_APP_VERSION
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].appVersion];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].deviceInfo && [HyBidAdFeedbackParameters sharedInstance].deviceInfo.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_DEVICE_INFO
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].deviceInfo];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].sdkVersion && [HyBidAdFeedbackParameters sharedInstance].sdkVersion.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_SDK_VERSION
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].sdkVersion];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].zoneID && [HyBidAdFeedbackParameters sharedInstance].zoneID.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_ZONE_ID
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].zoneID];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].creativeID && [HyBidAdFeedbackParameters sharedInstance].creativeID.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_CREATIVE_ID
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].creativeID];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].impressionBeacon && [HyBidAdFeedbackParameters sharedInstance].impressionBeacon.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_IMPRESSION_BEACON
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].impressionBeacon];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].integrationType && [HyBidAdFeedbackParameters sharedInstance].integrationType.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_INTEGRATION_TYPE
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].integrationType];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].adFormat && [HyBidAdFeedbackParameters sharedInstance].adFormat.length != 0) {
        feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_AD_FORMAT
                                                             withString:[HyBidAdFeedbackParameters sharedInstance].adFormat];
    }
    
    feedbackUrl = [feedbackUrl stringByReplacingOccurrencesOfString:HYBID_AD_FEEDBACK_MACRO_HAS_END_CARD
                                                         withString:[HyBidAdFeedbackParameters sharedInstance].hasEndCard ? @"true" : @"false"];
    return [feedbackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
