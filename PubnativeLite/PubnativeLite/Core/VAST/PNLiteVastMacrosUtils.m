// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVastMacrosUtils.h"
#import "HyBidUserDataManager.h"
#import "HyBidWebBrowserUserAgentInfo.h"
#import "HyBidStringUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation PNLiteVastMacrosUtils

+ (NSString *)formatUrl:(NSString *)vastUrl {
    NSString *idfa = [HyBidSettings sharedInstance].advertisingId ?: @"-1";
    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${IDFA}" replacement:idfa] ?: vastUrl;
    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${BUNDLE_ID}" replacement:[HyBidSettings sharedInstance].appBundleID] ?: vastUrl;
    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${CB}" replacement:[NSString stringWithFormat:@"%f", [[NSDate alloc]init].timeIntervalSince1970]] ?: vastUrl;
    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${UA}" replacement:[self urlEncode:HyBidWebBrowserUserAgentInfo.hyBidUserAgent]] ?: vastUrl;

    if ([[HyBidUserDataManager sharedInstance] getIABGDPRConsentString] != nil) {
        vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${CONSENT_STRING}" replacement:[[HyBidUserDataManager sharedInstance] getIABGDPRConsentString]] ?: vastUrl;
    }

    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${CONSENT_OPTIN}" replacement:[NSString stringWithFormat:@"%d", ![[HyBidUserDataManager sharedInstance] shouldAskConsent]]] ?: vastUrl;
    vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${CONSENT_OPTOUT}" replacement:[NSString stringWithFormat:@"%d", [[HyBidUserDataManager sharedInstance] isConsentDenied]]] ?: vastUrl;

    if ([HyBidConsentConfig sharedConfig].coppa) {
        NSNumber *age = [HyBidSDKConfig sharedConfig].targeting.age;
        vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${AGE}" replacement:[NSString stringWithFormat:@"%@", age]] ?: vastUrl;
        vastUrl = [HyBidStringUtils safeReplaceInValue:vastUrl target:@"${GENDER}" replacement:[HyBidSDKConfig sharedConfig].targeting.gender] ?: vastUrl;
    }

    return [vastUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString *)urlEncode: (NSString *) stringUrl {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [stringUrl
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}

@end
