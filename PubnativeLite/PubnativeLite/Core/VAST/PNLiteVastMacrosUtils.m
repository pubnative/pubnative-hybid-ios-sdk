// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVastMacrosUtils.h"
#import "HyBidUserDataManager.h"
#import "HyBidWebBrowserUserAgentInfo.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation PNLiteVastMacrosUtils

+ (NSString *)formatUrl:(NSString *)vastUrl {
    if ([HyBidSettings sharedInstance].advertisingId) {
        vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${IDFA}"
                                             withString:[HyBidSettings sharedInstance].advertisingId];
    } else {
        vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${IDFA}"
                                             withString:@"-1"];
    }
    vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${BUNDLE_ID}"
                                         withString:[HyBidSettings sharedInstance].appBundleID];
    vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${CB}"
                                                  withString:[NSString stringWithFormat:@"%f", [[NSDate alloc]init].timeIntervalSince1970]];
    vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${UA}"
                                         withString:[self urlEncode:HyBidWebBrowserUserAgentInfo.hyBidUserAgent]];
   
    if ([[HyBidUserDataManager sharedInstance]getIABGDPRConsentString] != nil) {
        vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${CONSENT_STRING}"
                                             withString: [[HyBidUserDataManager sharedInstance]getIABGDPRConsentString]];
    }

    vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${CONSENT_OPTIN}"
                                                 withString:[NSString stringWithFormat:@"%d", ![[HyBidUserDataManager sharedInstance]shouldAskConsent]]];
    vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${CONSENT_OPTOUT}"
                                                 withString:[NSString stringWithFormat:@"%d", [[HyBidUserDataManager sharedInstance]isConsentDenied]]];
    if ([HyBidConsentConfig sharedConfig].coppa) {
        NSNumber* age = [HyBidSDKConfig sharedConfig].targeting.age ;
        vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${AGE}"
                                                     withString:[NSString stringWithFormat:@"%@",age]];
        vastUrl = [vastUrl stringByReplacingOccurrencesOfString:@"${GENDER}"
                                             withString:[HyBidSDKConfig sharedConfig].targeting.gender];
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
