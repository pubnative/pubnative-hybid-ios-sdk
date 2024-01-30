//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import <WebKit/WebKit.h>
#import "HyBidWebBrowserUserAgentInfo.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

/**
 Global variable for holding the user agent string.
 */
NSString *gHyBidUserAgent = nil;

/**
 Global variable for keeping `WKWebView` alive until the async call for user agent finishes.
 Note: JavaScript evaluation will fail if the `WKWebView` is deallocated before completion.
 */
WKWebView *gHyBidWkWebView = nil;

/**
 The `UserDefaults` key for accessing the cached user agent value.
 */
NSString * const kUserDefaultsHyBidUserAgentKey = @"com.pubnative.hybid-ios-sdk.user-agent";

@implementation HyBidWebBrowserUserAgentInfo

+ (void)load {
    // No need for "dispatch once" since `load` is called only once during app launch.
    [self obtainUserAgentFromWebView];
}

+ (void)obtainUserAgentFromWebView {
    NSString *cachedUserAgent = [NSUserDefaults.standardUserDefaults stringForKey:kUserDefaultsHyBidUserAgentKey];
    if (cachedUserAgent.length > 0) {
        // Use the cached value before the async JavaScript evaluation is successful.
        gHyBidUserAgent = cachedUserAgent;
    } else {
        NSString *systemVersion = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        NSString *deviceType = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
        gHyBidUserAgent = [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
                      deviceType, deviceType, systemVersion];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        gHyBidWkWebView = [WKWebView new]; // `WKWebView` must be created in main thread
        [gHyBidWkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:error.localizedDescription];
            } else if ([result isKindOfClass:NSString.class]) {
                gHyBidUserAgent = result;
                [NSUserDefaults.standardUserDefaults setValue:result forKeyPath:kUserDefaultsHyBidUserAgentKey];
            }
            gHyBidWkWebView = nil;
        }];
    });
}

+ (NSString *)hyBidUserAgent {
    return gHyBidUserAgent;
}

@end
