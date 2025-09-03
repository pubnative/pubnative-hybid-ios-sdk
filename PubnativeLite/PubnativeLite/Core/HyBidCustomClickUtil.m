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

+ (NSString*)extractPNClickUrl:(NSString*) url {
    if (url != nil && ![url isEqualToString:@""]) {
        NSURL *clickUrl = [NSURL URLWithString:url];
        __block BOOL canOpenURL = NO;
        if ([NSThread isMainThread]) {
            canOpenURL = [[UIApplication sharedApplication] canOpenURL:clickUrl];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                canOpenURL = [[UIApplication sharedApplication] canOpenURL:clickUrl];
            });
        }
        if(!canOpenURL){
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
            clickUrl = [NSURL URLWithString:url];
        }
        
        if ([clickUrl.scheme isEqualToString:kPNClickUrlSchema]) {
            NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:clickUrl resolvingAgainstBaseURL:false];
            NSArray *queryItems = urlComponents.queryItems;
            int i = 0;
            while (i < queryItems.count) {
                NSURLQueryItem *item = queryItems[i];
                if ([item.name isEqualToString:kClickNavigateParam] && ![item.value isEqualToString:@""]) {
                    return [item.value stringByRemovingPercentEncoding];
                } else {
                    i++;
                }
            }
        }
    }
    
    return nil;
}

@end
