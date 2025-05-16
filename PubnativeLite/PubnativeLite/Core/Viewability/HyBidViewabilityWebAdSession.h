// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"
#import <WebKit/WebKit.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidViewabilityWebAdSession : HyBidViewabilityAdSession

- (OMIDPubnativenetAdSession*)createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd;

@end
