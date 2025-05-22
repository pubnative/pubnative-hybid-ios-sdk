// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidWebBrowserUserAgentInfo : NSObject

/**
 The current user agent as determined by @c WKWebView.
 @returns The user agent.
*/
+ (NSString *)hyBidUserAgent;

@end
