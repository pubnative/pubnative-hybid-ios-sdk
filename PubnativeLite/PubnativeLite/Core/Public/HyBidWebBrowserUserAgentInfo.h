// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidWebBrowserUserAgentInfo : NSObject

/// Returns shared instance that holds user agent;
@property (class, atomic, strong) HyBidWebBrowserUserAgentInfo *sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 The current user agent as determined by @c WKWebView.
 @returns The user agent.
 */
@property (atomic, copy, readonly) NSString *userAgent;

/**
 The current user agent as determined by @c WKWebView.
 @returns The user agent.
*/
+ (NSString *)hyBidUserAgent;

@end
