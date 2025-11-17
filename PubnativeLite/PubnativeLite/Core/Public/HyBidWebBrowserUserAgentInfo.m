// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
 The `UserDefaults` key for accessing the cached user agent value.
 */
NSString * const kUserDefaultsHyBidUserAgentKey = @"com.pubnative.hybid-ios-sdk.user-agent";

@interface HyBidWebBrowserUserAgentInfo ()

@property (atomic, copy) NSString *userAgent;
/**
 Variable for keeping `WKWebView` alive until the async call for user agent finishes.
 Note: JavaScript evaluation will fail if the `WKWebView` is deallocated before completion.
 */
@property (atomic, strong) WKWebView *webView;

@end

@implementation HyBidWebBrowserUserAgentInfo

@dynamic sharedInstance;
@synthesize userAgent;

+ (instancetype)sharedInstance {
    static HyBidWebBrowserUserAgentInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidWebBrowserUserAgentInfo alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userAgent = [self defaultUserAgent];
        [self loadWebKitUserAgent];
    }
    return self;
}

- (NSString *)defaultUserAgent {
    NSString *cachedUserAgent = [NSUserDefaults.standardUserDefaults stringForKey:kUserDefaultsHyBidUserAgentKey];
    if (cachedUserAgent.length > 0) {
        // Use the cached value before the async JavaScript evaluation is successful.
        return cachedUserAgent;
    } else {
        NSString *systemVersion = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        NSString *deviceType = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
        return [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
                      deviceType, deviceType, systemVersion];
    }
}

- (void)loadWebKitUserAgent {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView = [WKWebView new]; // `WKWebView` must be created in main thread
        [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                if ([HyBidSDKConfig sharedConfig].reporting) {
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
                }
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(@selector(loadWebKitUserAgent)) withMessage:error.localizedDescription];
            } else if ([result isKindOfClass:NSString.class]) {
                self.userAgent = result;
                [NSUserDefaults.standardUserDefaults setValue:result forKeyPath:kUserDefaultsHyBidUserAgentKey];
            }
            self.webView = nil;
        }];
    });
}

+ (NSString *)hyBidUserAgent {
    return self.sharedInstance.userAgent;
}

@end
