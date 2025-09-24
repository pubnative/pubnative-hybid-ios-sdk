// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidCustomClickUtil.h"
#import <UIKit/UIKit.h>

NSString * const kPNClickUrlSchema = @"pnnativebrowser";
NSString * const kClickNavigateParam = @"url";

@implementation HyBidCustomClickUtil

+ (NSString*)extractPNClickUrl:(NSString*)urlString {
    if (urlString.length == 0) { return nil; }

    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];

    if (!components) {
        NSString *encoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        if (![encoded isEqualToString:urlString]) {
            components = [NSURLComponents componentsWithString:encoded];
        }
        if (!components) { return nil; }
    }

    if (![components.scheme isEqualToString:kPNClickUrlSchema]) {
        return nil;
    }

    for (NSURLQueryItem *item in (components.queryItems ?: @[])) {
        if ([item.name isEqualToString:kClickNavigateParam] && item.value.length > 0) {
            return item.value.stringByRemovingPercentEncoding ?: item.value;
        }
    }
    
    return nil;
}

@end
