//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>
#import "HyBidDeeplinkHandler.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
#import <UIKit/UIKit.h>
#import <HyBid/HyBid-Swift.h>
#else
#import <UIKit/UIKit.h>
#import "HyBid-Swift.h"
#endif

@implementation HyBidDeeplinkHandler

- (instancetype)initWithLink:(NSString * _Nullable)link {
    self = [super init];
    if (!self) return nil;

    _deeplinkURL = nil;
    _fallbackURL = nil;
    _isCapable   = NO;

    NSURL *linkURL = (link.length > 0) ? [NSURL URLWithString:link] : nil;
    NSURLComponents *components = linkURL ? [NSURLComponents componentsWithURL:linkURL resolvingAgainstBaseURL:NO] : nil;

    BOOL isWrapper = (components.scheme.length > 0 &&
                      [[components.scheme lowercaseString] isEqualToString:HyBidConstants.HYBID_DEEPLINK_SCHEME]);
    if (!isWrapper) return self;

    NSMutableDictionary<NSString *, NSString *> *q = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *qi in components.queryItems ?: @[]) {
        if (qi.name && qi.value) { q[qi.name] = qi.value; }
    }

    NSString *deeplinkStr = q[HyBidConstants.HYBID_DEEPLINK_PARAM];
    NSString *fallbackStr = q[HyBidConstants.HYBID_FALLBACK_PARAM];

    NSURL *deeplink = (deeplinkStr.length > 0) ? [NSURL URLWithString:deeplinkStr] : nil;
    NSURL *fallback = (fallbackStr.length > 0) ? [NSURL URLWithString:fallbackStr] : nil;
    
    // Require deeplinkUrl to be present and valid
    if (deeplink == nil || deeplink.scheme.length == 0) {
        return self;
    }
    
    // FallbackUrl is optional, but if present must be valid
    if (fallbackStr.length > 0 && (fallback == nil || fallback.scheme.length == 0)) {
        return self;
    }
    
    _deeplinkURL = deeplink;
    _fallbackURL = fallback;
    _isCapable = YES;
    return self;
}

- (void)openWithNavigationType:(NSString *)navigationType {
    [self openWithNavigationType:navigationType clickthroughURL:nil];
}

- (void)openWithNavigationType:(NSString *)navigationType clickthroughURL:(NSString * _Nullable)clickthroughURL {
    if (!self.isCapable) { return; }

    [[UIApplication sharedApplication] openURL:self.deeplinkURL
                                       options:@{}
                             completionHandler:^(BOOL success) {
        if (success) { return; }

        // Priority 2: Use fallbackURL from Link Meta if available
        if (self.fallbackURL) {
            [self openUrlInBrowser:[self.fallbackURL absoluteString] navigationType:navigationType];
        }
        // Priority 3: Use VAST/MRAID clickthrough URL if fallbackURL is missing
        else if (clickthroughURL.length > 0) {
            [self openUrlInBrowser:clickthroughURL navigationType:navigationType];
        }
    }];
}

- (void)openUrlInBrowser:(NSString*) url navigationType:(NSString *)navigationType {
    HyBidWebBrowserNavigation navigation = [HyBidInternalWebBrowser.shared webBrowserNavigationBehaviourFromString: navigationType];
    
    if (navigation == HyBidWebBrowserNavigationInternal) {
        [HyBidInternalWebBrowser.shared navigateToURL:url];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                           options:@{}
                                 completionHandler:nil];
    }
}

@end
