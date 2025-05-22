// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdFeedbackView.h"
#import "HyBidMRAIDView.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "HyBidError.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidAdFeedbackMacroUtil.h"
#import "HyBidAdFeedbackJavaScriptInterface.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBidAdFeedbackMacroUtil.h"
#import "HyBidAdFeedbackViewDelegate.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidAdFeedbackView () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate>

@property (nonatomic, strong) HyBidMRAIDView *mraidView;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;
@property (nonatomic, weak) NSObject <HyBidAdFeedbackViewDelegate> *delegate;

@end

@implementation HyBidAdFeedbackView

- (void)dealloc {
    self.zoneID = nil;
    self.mraidView = nil;
    self.serviceProvider = nil;
}

- (instancetype)initWithURL:(NSString *)url withZoneID:(NSString *)zoneID {
    self = [super init];
    if (self) {
        self.zoneID = zoneID;
        
        if (url && url.length != 0) {
            NSURLComponents *components = [NSURLComponents componentsWithString:url];
            NSMutableArray *mutableQueryItems;
            if (![self isAppTokenQueryPresentInURLComponents:components]) {
                if (!components.queryItems) {
                    mutableQueryItems = [NSMutableArray new];
                } else {
                    mutableQueryItems = [components.queryItems mutableCopy];
                }
                NSURLQueryItem *appToken = [[NSURLQueryItem alloc] initWithName:@"apptoken" value:@"token_macro"];
                [mutableQueryItems addObject:appToken];
                components.queryItems = mutableQueryItems;
                url = [components.URL absoluteString];
                url = [url stringByReplacingOccurrencesOfString:@"token_macro"
                                                     withString:HYBID_AD_FEEDBACK_MACRO_APP_TOKEN];
            }
        }
        NSString *processedString = [HyBidAdFeedbackMacroUtil formatUrl:url withZoneID:self.zoneID];
        if (processedString && processedString.length != 0) {
            url = processedString;
        }
        
        self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
        self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
                                                  withHtmlData:nil
                                                   withBaseURL:[NSURL URLWithString:url]
                                                        withAd:nil
                                             supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
                                                 isInterstital:YES
                                                  isScrollable:YES
                                                      delegate:self
                                               serviceDelegate:self
                                            rootViewController:[UIApplication sharedApplication].topViewController
                                                   contentInfo:nil
                                                    skipOffset:0
                                                     isEndcard:NO
                                     shouldHandleInterruptions:NO];
        self.delegate = HyBidInterruptionHandler.shared;
    }
    return self;
}

- (BOOL)isAppTokenQueryPresentInURLComponents:(NSURLComponents *)components {
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"apptoken"]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)show {
    [HyBidInterruptionHandler.shared adFeedbackViewWillShow];
    [self.mraidView showAsInterstitial];
    [HyBidInterruptionHandler.shared adFeedbackViewDidShow];
}

#pragma mark HyBidMRAIDViewDelegate

- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView {
    HyBidAdFeedbackJavaScriptInterface *feedbackJSInterface = [[HyBidAdFeedbackJavaScriptInterface alloc] init];
    [feedbackJSInterface submitDataWithZoneID:self.zoneID withMRAIDView:self.mraidView];
    [self.delegate adFeedbackViewDidLoad];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [self.delegate adFeedbackViewDidFailWithError:[NSError hyBidAdFeedbackFormNotLoaded]];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {}
- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidInterruptionHandler.shared adFeedbackViewDidDismiss];
}
- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    [self.serviceProvider openBrowser:url.absoluteString];
}
- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return allowOffscreen;
}

#pragma mark HyBidMRAIDServiceDelegate

- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString {}
- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString {}
- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString {}
- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {}
- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {}

@end
