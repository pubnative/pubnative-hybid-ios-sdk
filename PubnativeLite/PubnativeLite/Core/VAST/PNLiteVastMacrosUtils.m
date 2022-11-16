//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
