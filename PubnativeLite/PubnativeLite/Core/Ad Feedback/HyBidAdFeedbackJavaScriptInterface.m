// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdFeedbackJavaScriptInterface.h"
#import "HyBidAdFeedbackParameters.h"

#define HYBID_AD_FEEDBACK_JS_VAR @"hybidFeedback"
#define HYBID_AD_FEEDBACK_JS_PARAM_APP_TOKEN @"appToken"
#define HYBID_AD_FEEDBACK_JS_PARAM_AUDIO_STATE @"audioState"
#define HYBID_AD_FEEDBACK_JS_PARAM_APP_VERSION @"appVersion"
#define HYBID_AD_FEEDBACK_JS_PARAM_DEVICE_INFO @"deviceInfo"
#define HYBID_AD_FEEDBACK_JS_PARAM_SDK_VERSION @"sdkVersion"
#define HYBID_AD_FEEDBACK_JS_PARAM_ZONE_ID @"zoneId"
#define HYBID_AD_FEEDBACK_JS_PARAM_CREATIVE_ID @"creativeId"
#define HYBID_AD_FEEDBACK_JS_PARAM_CREATIVE @"creative"
#define HYBID_AD_FEEDBACK_JS_PARAM_IMPRESSION_BEACON @"impressionBeacon"
#define HYBID_AD_FEEDBACK_JS_PARAM_INTEGRATION_TYPE @"integrationType"
#define HYBID_AD_FEEDBACK_JS_PARAM_AD_FORMAT @"adFormat"
#define HYBID_AD_FEEDBACK_JS_PARAM_HAS_END_CARD @"hasEndCard"

@implementation HyBidAdFeedbackJavaScriptInterface

- (void)submitDataWithZoneID:(NSString *)zoneID withMRAIDView:(HyBidMRAIDView *)mraidView {
    NSString *javaScript = [self buildJavaScriptWithZoneID:zoneID];
    if (mraidView && javaScript && javaScript.length > 0) {
        [mraidView injectJavaScript:javaScript];
    }
}

- (NSString *)buildJavaScriptWithZoneID:(NSString *)zoneID {
    NSString *javaScript = @"";
    [HyBidAdFeedbackParameters sharedInstance].requestedZoneID = zoneID;
    
    if ([HyBidAdFeedbackParameters sharedInstance].appToken && [HyBidAdFeedbackParameters sharedInstance].appToken.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_APP_TOKEN withParameter:[HyBidAdFeedbackParameters sharedInstance].appToken]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].audioState && [HyBidAdFeedbackParameters sharedInstance].audioState.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_AUDIO_STATE withParameter:[HyBidAdFeedbackParameters sharedInstance].audioState]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].appVersion && [HyBidAdFeedbackParameters sharedInstance].appVersion.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_APP_VERSION withParameter:[HyBidAdFeedbackParameters sharedInstance].appVersion]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].deviceInfo && [HyBidAdFeedbackParameters sharedInstance].deviceInfo.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_DEVICE_INFO withParameter:[HyBidAdFeedbackParameters sharedInstance].deviceInfo]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].sdkVersion && [HyBidAdFeedbackParameters sharedInstance].sdkVersion.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_SDK_VERSION withParameter:[HyBidAdFeedbackParameters sharedInstance].sdkVersion]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].zoneID && [HyBidAdFeedbackParameters sharedInstance].zoneID.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_ZONE_ID withParameter:[HyBidAdFeedbackParameters sharedInstance].zoneID]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].creativeID && [HyBidAdFeedbackParameters sharedInstance].creativeID.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_CREATIVE_ID withParameter:[HyBidAdFeedbackParameters sharedInstance].creativeID]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].creative && [HyBidAdFeedbackParameters sharedInstance].creative.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_CREATIVE withParameter:[[HyBidAdFeedbackParameters sharedInstance].creative stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].impressionBeacon && [HyBidAdFeedbackParameters sharedInstance].impressionBeacon.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_IMPRESSION_BEACON withParameter:[HyBidAdFeedbackParameters sharedInstance].impressionBeacon]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].integrationType && [HyBidAdFeedbackParameters sharedInstance].integrationType.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_INTEGRATION_TYPE withParameter:[HyBidAdFeedbackParameters sharedInstance].integrationType]];
    }
    
    if ([HyBidAdFeedbackParameters sharedInstance].adFormat && [HyBidAdFeedbackParameters sharedInstance].adFormat.length != 0) {
        javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_AD_FORMAT withParameter:[HyBidAdFeedbackParameters sharedInstance].adFormat]];
    }
    
    javaScript = [javaScript stringByAppendingString:[self getJavaScriptWithParameterName:HYBID_AD_FEEDBACK_JS_PARAM_HAS_END_CARD withParameter:[HyBidAdFeedbackParameters sharedInstance].hasEndCard ? @"true" : @"false"]];

    return javaScript;
}

- (NSString *)getJavaScriptWithParameterName:(NSString *)parameterName withParameter:(NSString *)parameter {
    return [NSString stringWithFormat:@"%@.%@ = \"%@\";", HYBID_AD_FEEDBACK_JS_VAR, parameterName, parameter];
}

@end
