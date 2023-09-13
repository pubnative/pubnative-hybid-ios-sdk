//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "HyBidMRAIDView.h"
#import "PNLiteMRAIDOrientationProperties.h"
#import "PNLiteMRAIDResizeProperties.h"
#import "PNLiteMRAIDParser.h"
#import "PNLiteMRAIDModalViewController.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "PNLiteMRAIDUtil.h"
#import "PNLiteMRAIDSettings.h"
#import "HyBidViewabilityManager.h"
#import "HyBidViewabilityWebAdSession.h"
#import "HyBidNavigatorGeolocation.h"
#import "HyBidCloseButton.h"

#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OMSDK_Pubnativenet/OMIDAdSession.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#import "HyBidSkipOverlay.h"
#import "HyBidTimerState.h"
#import <StoreKit/StoreKit.h>
#import "UIApplication+PNLiteTopViewController.h"

#define kCloseButtonSize 30

#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

//Viewbility Timeinterval Freqeuncy
#define HYBID_MRAID_Check_Viewable_Frequency 0.2

#define HYBID_MRAID_CLOSE_BUTTON_TAG 1001

CGFloat const kContentInfoViewHeight = 15.0f;
CGFloat const kContentInfoViewWidth = 15.0f;

typedef enum {
    PNLiteMRAIDStateLoading,
    PNLiteMRAIDStateDefault,
    PNLiteMRAIDStateExpanded,
    PNLiteMRAIDStateResized,
    PNLiteMRAIDStateHidden
} PNLiteMRAIDState;

@interface HyBidMRAIDView () <WKNavigationDelegate, WKUIDelegate, PNLiteMRAIDModalViewControllerDelegate, UIGestureRecognizerDelegate, HyBidContentInfoViewDelegate, HyBidSkipOverlayDelegate, SKStoreProductViewControllerDelegate, HyBidURLRedirectorDelegate>
{
    PNLiteMRAIDState state;
    // This corresponds to the MRAID placement type.
    BOOL isInterstitial;
    BOOL isEndcard;
    BOOL isAdSessionCreated;
    BOOL isScrollable;

    OMIDPubnativenetAdSession *adSession;
    
    // The only property of the MRAID expandProperties we need to keep track of
    // on the native side is the useCustomClose property.
    // The width, height, and isModal properties are not used in MRAID v2.0.
    // @Deprecated as from MRAID v3.0
    BOOL useCustomClose;
    
    NSInteger _skipOffset;
    
    PNLiteMRAIDOrientationProperties *orientationProperties;
    PNLiteMRAIDResizeProperties *resizeProperties;
    
    PNLiteMRAIDParser *mraidParser;
    PNLiteMRAIDModalViewController *modalVC;
    
    NSString *omSDKjs;
    
    NSURL *baseURL;
    
    NSArray *mraidFeatures;
    NSArray *supportedFeatures;
    
    WKWebView *webView;
    WKWebView *webViewPart2;
    WKWebView *currentWebView;
    
    HyBidNavigatorGeolocation* navigatorGeolocation;
    
    UIButton *closeButton;

    UIView *resizeView;
    UIButton *resizeCloseRegion;
    
    UIView *contentInfoViewContainer;
    HyBidContentInfoView *contentInfoView;
    
    CGSize previousMaxSize;
    CGSize previousScreenSize;
    
    UITapGestureRecognizer *tapGestureRecognizer;
    BOOL bonafideTapObserved; //supressing redirect from banners
    BOOL tapObserved; // observing taps on MRAID (specifically for taps on endcard)
    BOOL isStoreViewControllerPresented;
    BOOL isStoreViewControllerBeingPresented;
    BOOL startedFromTap;

    CGFloat adWidth;
    CGFloat adHeight;
    
    // Params for exposedChange introduced with MRAID 3.0
    CGFloat exposedPercentage;
    CGRect visibleRect;
    NSTimer *viewabilityTimer;
    BOOL adNeedsCloseButton;
    BOOL adNeedsSkipOverlay;
    BOOL obtainedUseCustomCloseValue;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification;

- (void)addCloseEventRegion;
- (void)showResizeCloseRegion;
- (void)removeResizeCloseRegion;
- (void)setResizeViewPosition;
- (void)addContentInfoViewToView:(UIView *)view;


// convenience methods to fire MRAID events
- (void)fireErrorEventWithAction:(NSString *)action message:(NSString *)message;
- (void)fireReadyEvent;
- (void)fireSizeChangeEvent;
- (void)fireStateChangeEvent;
- (void)fireViewableChangeEvent; // DEPRECATED: ViewableChangeEvent is deprecated as from MRAID 3.0
- (void)fireExposureChange;
// setters
- (void)setDefaultPosition;
- (void)setMaxSize;
- (void)setScreenSize;

// internal helper methods
- (void)initWebView:(WKWebView *)wv;
- (void)parseCommandUrl:(NSString *)commandUrlString;

@property (nonatomic, strong) NSTimer *closeButtonOffsetTimer;
@property (nonatomic, assign) NSTimeInterval closeButtonTimeElapsed;
@property (nonatomic, strong) HyBidSkipOverlay *skipOverlay;
@property (nonatomic, assign) HyBidCountdownStyle countdownStyle;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL isFeedbackScreenShown;
@property (nonatomic, assign) BOOL willShowFeedbackScreen;
@property (nonatomic, strong) HyBidSkipOffset *nativeCloseButtonDelay;
@property (nonatomic, assign) BOOL creativeAutoStorekitEnabled;

@end

@implementation HyBidMRAIDView

@synthesize isViewable=_isViewable;
@synthesize rootViewController = _rootViewController;
CGFloat secondsToWaitForCustomCloseValue = 0.5;

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithFrame is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithCoder is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString *)htmlData
        withBaseURL:(NSURL *)bsURL
             withAd:(HyBidAd *)ad
  supportedFeatures:(NSArray *)features
      isInterstital:(BOOL)isInterstitial
       isScrollable:(BOOL)isScrollable
           delegate:(id<HyBidMRAIDViewDelegate>)delegate
    serviceDelegate:(id<HyBidMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController
        contentInfo:(HyBidContentInfoView *)contentInfo
         skipOffset:(NSInteger)skipOffset
          isEndcard:(BOOL)isEndcardPresented {
    return [self initWithFrame:frame
                  withHtmlData:htmlData
                   withBaseURL:bsURL
                        withAd:ad
                asInterstitial:isInterstitial
                  isScrollable:isScrollable
             supportedFeatures:features
                      delegate:delegate
               serviceDelegate:serviceDelegate
            rootViewController:rootViewController
                   contentInfo:contentInfo
                    skipOffset:skipOffset
                     isEndcard:isEndcardPresented];
}

// designated initializer
- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString *)htmlData
        withBaseURL:(NSURL *)bsURL
             withAd:(HyBidAd *)ad
     asInterstitial:(BOOL)isInter
       isScrollable:(BOOL)canScroll
  supportedFeatures:(NSArray *)currentFeatures
           delegate:(id<HyBidMRAIDViewDelegate>)delegate
    serviceDelegate:(id<HyBidMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController
        contentInfo:(HyBidContentInfoView *)contentInfo
         skipOffset:(NSInteger)skipOffset
          isEndcard:(BOOL)isEndcardPresented {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpTapGestureRecognizer];
        [self determineNativeCloseButtonDelayForAd:ad];
        [self determineCreativeAutoStorekitEnabledForAd:ad];
        isInterstitial = isInter;
        isEndcard = isEndcardPresented;
        isScrollable = canScroll;
        adWidth = frame.size.width;
        adHeight = frame.size.height;
        _delegate = delegate;
        _serviceDelegate = serviceDelegate;
        _rootViewController = rootViewController;
        
        state = PNLiteMRAIDStateLoading;
        _isViewable = NO;
        useCustomClose = NO;
        tapObserved = NO;
        isStoreViewControllerPresented = NO;
        isStoreViewControllerBeingPresented = NO;
        _skipOffset = skipOffset;

        orientationProperties = [[PNLiteMRAIDOrientationProperties alloc] init];
        resizeProperties = [[PNLiteMRAIDResizeProperties alloc] init];
        
        contentInfoView = contentInfo;
        
        mraidParser = [[PNLiteMRAIDParser alloc] init];
        
        mraidFeatures = @[
                          PNLiteMRAIDSupportsSMS,
                          PNLiteMRAIDSupportsTel,
                          PNLiteMRAIDSupportsStorePicture,
                          PNLiteMRAIDSupportsInlineVideo,
                          PNLiteMRAIDSupportsLocation,
                          ];
        
        
        if([self isValidFeatureSet:currentFeatures] && serviceDelegate) {
            supportedFeatures=currentFeatures;
        }
        self.ad = ad;
        navigatorGeolocation = [[HyBidNavigatorGeolocation alloc] init];
        webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) configuration:[self createConfiguration]];
        [self initWebView:webView];
        currentWebView = webView;
        [navigatorGeolocation assignWebView:currentWebView];
        [self addSubview:currentWebView];
        
        [self setWebViewConstraintsInRelationWithView:self];
        
        previousMaxSize = CGSizeZero;
        previousScreenSize = CGSizeZero;
        
        [self addObserver:self forKeyPath:@"self.frame" options:NSKeyValueObservingOptionOld context:NULL];
       
        baseURL = bsURL;
        state = PNLiteMRAIDStateLoading;
        
        omSDKjs = [[HyBidViewabilityManager sharedInstance] getOMIDJS];
        if (omSDKjs) {
            [self injectJavaScript:omSDKjs];
        }
        
        if (baseURL != nil && [[baseURL absoluteString] length]!= 0) {
            __block NSString *htmlData = htmlData;
            [self htmlFromUrl:baseURL handler:^(NSString *html, NSError *error) {
                if(html && !error){
                    htmlData = [PNLiteMRAIDUtil processRawHtml:html];
                    [self loadHTMLData:htmlData];
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
                    if ([self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
                        [self.delegate mraidViewAdFailed:self];
                    }
                }
            }];
        } else {
            htmlData = [PNLiteMRAIDUtil processRawHtml:htmlData];
            [self loadHTMLData:htmlData];
        }
        
        if (isInter) {
            bonafideTapObserved = YES;  // no autoRedirect suppression for Interstitials
        }
        
        [self addObservers];
    }
    return self;
}

- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets safeArea = [super safeAreaInsets];
    safeArea.bottom = 0;
    return safeArea;
}

- (void)determineNativeCloseButtonDelayForAd:(HyBidAd *)ad {
    if (ad.nativeCloseButtonDelay) {
        if([ad.nativeCloseButtonDelay integerValue] >= 0 && [ad.nativeCloseButtonDelay integerValue] < HyBidSkipOffset.DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET){
            self.nativeCloseButtonDelay = [[HyBidSkipOffset alloc] initWithOffset:ad.nativeCloseButtonDelay isCustom:YES];
        } else {
            self.nativeCloseButtonDelay = [HyBidRenderingConfig sharedConfig].nativeCloseButtonOffset;
        }
    } else {
        self.nativeCloseButtonDelay = [HyBidRenderingConfig sharedConfig].nativeCloseButtonOffset;
    }
}

- (void)determineCreativeAutoStorekitEnabledForAd:(HyBidAd *)ad {
    if ([ad.creativeAutoStorekitEnabled boolValue]) {
        self.creativeAutoStorekitEnabled = YES;
    } else {
        self.creativeAutoStorekitEnabled = [HyBidRenderingConfig sharedConfig].creativeAutoStorekitEnabled;
    }
}


- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(feedbackScreenWillShow:)
                                                 name: @"adFeedbackViewWillShow"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(feedbackScreenDidShow:)
                                                 name: @"adFeedbackViewDidShow"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(feedbackScreenIsDismissed:)
                                                 name: @"adFeedbackViewIsDismissed"
                                               object: nil];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (modalVC != nil && !self.isFeedbackScreenShown) {
            [self playCountdownView];
            [self playCloseButtonDelay];
        }
    });
}

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    if (modalVC != nil && !self.isFeedbackScreenShown) {
        [self pauseCountdownView];
        [self pauseCloseButtonDelay];
    }
}

-(void)feedbackScreenWillShow:(NSNotification*)notification {
    self.willShowFeedbackScreen = YES;
}
- (void)feedbackScreenDidShow:(NSNotification*)notification {
    self.isFeedbackScreenShown = YES;
    if (modalVC != nil) {
        [self pauseCountdownView];
        [self pauseCloseButtonDelay];
    }
}

- (void)feedbackScreenIsDismissed:(NSNotification*)notification {
    self.isFeedbackScreenShown = NO;
    if (modalVC != nil) {
        [self playCountdownView];
        [self playCloseButtonDelay];
    }
}

- (void)playCountdownView {
    NSInteger remainingSeconds = [self.skipOverlay getRemainingTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds: remainingSeconds withTimerState:HyBidTimerState_Start];
}

- (void)pauseCountdownView {
    NSInteger remainingSeconds = [self.skipOverlay getRemainingTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds:(remainingSeconds) withTimerState:HyBidTimerState_Pause];
}

- (void)playCloseButtonDelay {
    if(!self.skipOverlay){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
    }
}

- (void)pauseCloseButtonDelay {
    if(!self.skipOverlay && [self.closeButtonOffsetTimer isValid]){
        [self invalidateCloseButtonOffsetTimer];
    }
}

- (void)htmlFromUrl:(NSURL *)url handler:(void (^)(NSString *html, NSError *error))handler {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: url];
    [urlRequest setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200) {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *mimeType = [httpResponse.MIMEType lowercaseString];
            if ([mimeType isEqualToString:@"text/html"] ||
                [mimeType isEqualToString:@"text/plain"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (handler)
                        handler(dataString, error);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(handler){
                        handler(nil, [NSError hyBidInvalidHTML]);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if(handler){
                    handler(nil, error);
                }
            });
        }
    }];
    dataTask.priority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    [dataTask resume];
}

- (void)loadHTMLData:(NSString *)htmlData {
    if (htmlData) {
        [currentWebView loadHTMLString:htmlData baseURL:baseURL];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad HTML is invalid, cannot load."];
        if ([self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
            [self.delegate mraidViewAdFailed:self];
        }
    }
}

- (void)cancel {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"cancel"];
    [currentWebView stopLoading];
    currentWebView = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)dealloc {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    
    [self removeObserver:self forKeyPath:@"self.frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    
    webView = nil;
    webViewPart2 = nil;
    currentWebView = nil;
    navigatorGeolocation = nil;
    
    mraidParser = nil;
    modalVC = nil;
    
    orientationProperties = nil;
    resizeProperties = nil;
    
    mraidFeatures = nil;
    supportedFeatures = nil;
    
    closeButton = nil;
    resizeView = nil;
    resizeCloseRegion = nil;
    
    contentInfoViewContainer = nil;
    contentInfoView = nil;
    
    viewabilityTimer = nil;
    
    self.delegate = nil;
    self.serviceDelegate = nil;
    self.ad = nil;
    self.skipOverlay = nil;
    self.isFeedbackScreenShown = nil;
    self.nativeCloseButtonDelay = nil;
    [self invalidateCloseButtonOffsetTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isValidFeatureSet:(NSArray *)features {
    NSArray *kFeatures = @[
                           PNLiteMRAIDSupportsSMS,
                           PNLiteMRAIDSupportsTel,
                           PNLiteMRAIDSupportsStorePicture,
                           PNLiteMRAIDSupportsInlineVideo,
                           PNLiteMRAIDSupportsLocation,
                           ];
    
    // Validate the features set by the user
    for (id feature in features) {
        if (![kFeatures containsObject:feature]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"feature %@ is unknown, no supports set.", feature]];
            return NO;
        }
    }
    return YES;
}

- (void)setIsViewable:(BOOL)newIsViewable {
    if(newIsViewable!=_isViewable) {
        _isViewable=newIsViewable;
        [self fireViewableChangeEvent];
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"isViewable: %@", _isViewable?@"YES":@"NO"]];
}

- (BOOL)isViewable {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    return _isViewable;
}

- (CGFloat)exposedPercent{
    CGFloat exposedPrecentage = 0;
    if(_isViewable){
        CGRect normalizedSelfRect = [currentWebView convertRect:currentWebView.bounds toView:nil];
        CGRect intersection = CGRectIntersection(self.frame, normalizedSelfRect);
        CGFloat intersectionArea = intersection.size.width  * intersection.size.height;
        int totalArea = normalizedSelfRect.size.width *normalizedSelfRect.size.height;
        exposedPrecentage  = (intersectionArea * 100)/(totalArea);
    }
    return exposedPrecentage;
}

- (CGRect)visibleRect{
    CGRect visibleRectangle =  CGRectMake(0,0,0,0);
    if(_isViewable){
        UIWindow *parentWindow = currentWebView.window;
        // We need to call convertRect:toView: on this view's superview rather than on this view itself.
        CGRect viewFrameInWindowCoordinates = [currentWebView.superview convertRect:currentWebView.frame toView:parentWindow];
        visibleRectangle = CGRectIntersection(viewFrameInWindowCoordinates, parentWindow.frame);
    }
    return visibleRectangle;
}

- (void)setRootViewController:(UIViewController *)newRootViewController {
    if(newRootViewController!=_rootViewController) {
        _rootViewController=newRootViewController;
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"setRootViewController: %@", _rootViewController]];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    @synchronized (self) {
        [self setScreenSize];
        [self setMaxSize];
        [self setDefaultPosition];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.frame"]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"self.frame has changed."];
        
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if (change[@"old"] != [NSNull null]) {
            oldFrame = [change[@"old"] CGRectValue];
        }
        if ([object valueForKeyPath:keyPath] != [NSNull null]) {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
        }
        
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"old %@", NSStringFromCGRect(oldFrame)]];
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"new %@", NSStringFromCGRect(newFrame)]];
        
        if (state == PNLiteMRAIDStateResized) {
            [self setResizeViewPosition];
        }
        [self setDefaultPosition];
        [self setMaxSize];
        [self fireSizeChangeEvent];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    currentWebView.backgroundColor = backgroundColor;
}

#pragma mark - SkipOverlay Delegate helpers

- (void)skipButtonTapped
{
    [self removeView:self.skipOverlay];
    [self close];
}

- (void)skipTimerCompleted
{
    if(isInterstitial && self.countdownStyle == HyBidCountdownPieChart){
        if([modalVC.view.subviews containsObject:self.skipOverlay]){
            [self setCloseButtonPosition: self.skipOverlay];
        }
    }
}

#pragma mark - interstitial support

- (void)showAsInterstitial {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self expand:nil supportVerve:NO];
    [self setIsViewable:YES];
    if(adNeedsCloseButton){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
    }
}

- (void)showAsInterstitialFromViewController:(UIViewController *)viewController {
    [self setRootViewController:viewController];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self expand:nil supportVerve:NO];
    [self setIsViewable:YES];
    if(adNeedsCloseButton){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
    }
}

- (void)hide {
    [self close];
}

#pragma mark - HyBidContentInfoViewDelegate

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width {
    contentInfoViewContainer.layer.frame = CGRectMake(contentInfoViewContainer.frame.origin.x, contentInfoViewContainer.frame.origin.y, [width floatValue], contentInfoViewContainer.frame.size.height);
}

#pragma mark - JavaScript --> native support

// These methods are (indirectly) called by JavaScript code.
// They provide the means for JavaScript code to talk to native code

- (void)unload {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
        [self.delegate mraidViewAdFailed:self];
    }
}

- (void)close {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
    
    if (state == PNLiteMRAIDStateLoading ||
        (state == PNLiteMRAIDStateDefault && !isInterstitial) ||
        state == PNLiteMRAIDStateHidden) {
        // do nothing
        return;
    }
    
    if (state == PNLiteMRAIDStateResized) {
        [self closeFromResize];
        return;
    }
    
    if (modalVC) {
        [self removeView: closeButton];
        [currentWebView removeFromSuperview];
        if ([modalVC respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            // used if running >= iOS 6
            [modalVC dismissViewControllerAnimated:NO completion:nil];
        } else {
            // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [modalVC dismissModalViewControllerAnimated:NO];
#pragma clang diagnostic pop
        }
    }
    
    modalVC = nil;
    
    if (webViewPart2) {
        // Clean up webViewPart2 if returning from 2-part expansion.
        webViewPart2.navigationDelegate = nil;
        webViewPart2.UIDelegate = nil;
        currentWebView = webView;
        webViewPart2 = nil;
    } else {
        // Reset frame of webView if returning from 1-part expansion.
        webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    if (!isInterstitial) {
        [self addContentInfoViewToView:webView];
    }
    
    [self addSubview:webView];
    [self setWebViewConstraintsInRelationWithView:self];

    if (!isInterstitial) {
        [self fireSizeChangeEvent];
    } else {
        self.isViewable = NO;
        [self fireViewableChangeEvent];
    }
    
    if (state == PNLiteMRAIDStateDefault && isInterstitial) {
        state = PNLiteMRAIDStateHidden;
    } else if (state == PNLiteMRAIDStateExpanded || state == PNLiteMRAIDStateResized) {
        state = PNLiteMRAIDStateDefault;
    }
    [self fireStateChangeEvent];
    
    if ([self.delegate respondsToSelector:@selector(mraidViewDidClose:)]) {
        [self.delegate mraidViewDidClose:self];
    }
    self.skipOverlay = nil;
    [self invalidateCloseButtonOffsetTimer];
}

// This is a helper method which is not part of the official MRAID API.
- (void)closeFromResize {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback helper %@", NSStringFromSelector(_cmd)]];
    [self removeResizeCloseRegion];
    state = PNLiteMRAIDStateDefault;
    [self fireStateChangeEvent];
    [webView removeFromSuperview];
    webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:webView];
    [resizeView removeFromSuperview];
    resizeView = nil;
    [self fireSizeChangeEvent];
    if ([self.delegate respondsToSelector:@selector(mraidViewDidClose:)]) {
        [self.delegate mraidViewDidClose:self];
    }
    [self setWebViewConstraintsInRelationWithView:self];
}

// Note: This method is also used to present an interstitial ad.
- (void)expand:(NSString *)urlString supportVerve:(BOOL)supportVerve {
    if (self.ad.mraidExpand) {
        [self decideMRAIDExpand:[self.ad.mraidExpand boolValue] withURL:urlString supportVerve:supportVerve];
    } else {
        [self decideMRAIDExpand:[HyBidRenderingConfig sharedConfig].mraidExpand withURL:urlString supportVerve:supportVerve];
    }
}

- (void)decideMRAIDExpand:(BOOL)mraidExpand withURL:(NSString *)urlString supportVerve:(BOOL)supportVerve {
    if (!mraidExpand) {
        if (!isInterstitial) {
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ expand disabled by the developer", NSStringFromSelector(_cmd)]];
        } else {
            [self expandCreative:urlString supportVerve:supportVerve];
        }
    } else {
        [self expandCreative:urlString supportVerve:supportVerve];
    }
}

- (void)expandCreative:(NSString *)urlString supportVerve:(BOOL)supportVerve {
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    BOOL isLandscape = (currentOrientation == UIInterfaceOrientationLandscapeLeft) || (currentOrientation == UIInterfaceOrientationLandscapeRight);
    BOOL isPortrait = (currentOrientation == UIInterfaceOrientationPortrait) || (currentOrientation == UIInterfaceOrientationPortraitUpsideDown);
    
    // Checking here if the orientation was changed after requesting ad
    // and if the aspect ration is not matching
    if ((isPortrait && adWidth > adHeight) ||
        (isLandscape && adHeight > adWidth)) {
        CGFloat tmpHeight = adHeight;
        
        adHeight = adWidth;
        adWidth = tmpHeight;
    }
    
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.expand() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), (urlString ? urlString : @"1-part")]];
    
    // The only time it is valid to call expand is when the ad is currently in either default or resized state.
    if (state != PNLiteMRAIDStateDefault && state != PNLiteMRAIDStateResized) {
        // do nothing
        return;
    }
    
    modalVC = [[PNLiteMRAIDModalViewController alloc] initWithOrientationProperties:orientationProperties];
    CGRect frame = self.frame;
    modalVC.view.frame = frame;
    modalVC.delegate = self;
    modalVC.willShowFeedbackScreen = self.willShowFeedbackScreen;
    
    if (!urlString) {
        // 1-part expansion
        webView.frame = CGRectMake(frame.size.width/2 - adWidth/2, frame.size.height/2 - adHeight/2, adWidth, adHeight);
        [webView removeFromSuperview];
    } else {
        // 2-part expansion
        webViewPart2 = [[WKWebView alloc] initWithFrame:frame configuration:[self createConfiguration]];
        [self initWebView:webViewPart2];
        currentWebView = webViewPart2;
        [navigatorGeolocation assignWebView:webViewPart2];
        bonafideTapObserved = YES; // by definition for 2 part expand a valid tap has occurred
        
        if (omSDKjs) {
            [self injectJavaScript:omSDKjs];
        }
        
        // Check to see whether we've been given an absolute or relative URL.
        // If it's relative, prepend the base URL.
        if (!supportVerve) {
            urlString = [urlString stringByRemovingPercentEncoding];
            if (![[NSURL URLWithString:urlString] scheme]) {
                // relative URL
                urlString = [[[baseURL absoluteString] stringByRemovingPercentEncoding] stringByAppendingString:urlString];
            }

            // Need to escape characters which are URL specific
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        }

        NSError *error;
        NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            if (!supportVerve) {
                [webViewPart2 loadHTMLString:content baseURL:baseURL];
            } else {
                [webViewPart2 loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]]];
            }
        } else {
            // Error! Clean up and return.
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Could not load part 2 expanded content for URL: %@" ,urlString]];
            currentWebView = webView;
            webViewPart2.navigationDelegate = nil;
            webViewPart2.UIDelegate = nil;
            webViewPart2 = nil;
            modalVC = nil;
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mraidViewWillExpand:)]) {
        [self.delegate mraidViewWillExpand:self];
    }
    
    [modalVC.view addSubview:currentWebView];
    
    if (modalVC.view != nil) {
        [self setWebViewConstraintsInRelationWithView:modalVC.view];
    }
    
    if ([self.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // used if running >= iOS 6
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {  // respect clear backgroundColor
            self.rootViewController.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self.rootViewController presentViewController:modalVC animated:NO completion:nil];
    } else {
        // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.rootViewController presentModalViewController:modalVC animated:NO];
#pragma clang diagnostic pop
    }
    
    if (!isInterstitial) {
        [self addContentInfoViewToView:modalVC.view];
        state = PNLiteMRAIDStateExpanded;
        [self fireStateChangeEvent];
    }

    if (isInterstitial) {
        [self addContentInfoViewToView:modalVC.view ];
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
    }
    
    if(state == PNLiteMRAIDStateExpanded){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
    }
    
    [self fireSizeChangeEvent];
    self.isViewable = YES;
}

- (void)addSkipOverlay
{
    self.skipOverlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:self->_skipOffset withCountdownStyle:HyBidCountdownPieChart withContentInfoPositionTopLeft:[self isContentInfoInTopLeftPosition] withShouldShowSkipButton:false];
    [self.skipOverlay addSkipOverlayViewIn:modalVC.view delegate:self withIsMRAID:YES];
}

- (void)setWebViewConstraintsInRelationWithView:(UIView *)view
{
    [currentWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[currentWebView.topAnchor constraintEqualToAnchor:view.topAnchor] setActive:YES];
    [[currentWebView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor] setActive:YES];
    [[currentWebView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor] setActive:YES];
    [[currentWebView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor] setActive:YES];
    
    [currentWebView layoutIfNeeded];
}

- (void)open:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.open() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];

    if (!isEndcard) {
        [self openBrowserWithURLString:urlString];
    }
    
    if (!self.creativeAutoStorekitEnabled && !startedFromTap) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to auto click while feature is disabled"];
        return;
    }
    
    // Avoid opening multiple Store ViewControllers
    if (isStoreViewControllerPresented || isStoreViewControllerBeingPresented) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to manual/auto click when task is not finished yet"];
        return;
    }
    
    if(tapObserved) {
        HyBidURLRedirector *redirector = [[HyBidURLRedirector alloc] init];
        redirector.delegate = self;
        [redirector drillWithUrl:urlString];
        return;
    }

    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];

    if([urlString containsString:@"sms"]){
        if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceSendSMSWithUrlString:)]) {
            [self.serviceDelegate mraidServiceSendSMSWithUrlString:urlString];
        }
    } else if ([urlString containsString:@"tel"]) {
        if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceCallNumberWithUrlString:)]) {
            [self.serviceDelegate mraidServiceCallNumberWithUrlString:urlString];
        }
    } else if ([[urlString lowercaseString] containsString:@"apps.apple.com"]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"Trying to present StoreViewController with url: %@", urlString]];
        [self openAppStoreWithAppID:urlString];
    } else if (tapObserved) {
        [self openBrowserWithURLString:urlString];
    }
    startedFromTap = NO;
}

- (void)playVideo:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.playVideo() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServicePlayVideoWithUrlString:)]) {
        [self.serviceDelegate mraidServicePlayVideoWithUrlString:urlString];
    }
}

- (void)sendSMS:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.sendSMS() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceSendSMSWithUrlString:)]) {
        [self.serviceDelegate mraidServiceSendSMSWithUrlString:urlString];
    }
}

- (void)callNumber:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.callNumber() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceCallNumberWithUrlString:)]) {
        [self.serviceDelegate mraidServiceCallNumberWithUrlString:urlString];
    }
}

- (void)resize {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.resize when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
    // If our delegate doesn't respond to the mraidViewShouldResizeToPosition:allowOffscreen: message,
    // then we can't do anything. We need help from the app here.
    if (![self.delegate respondsToSelector:@selector(mraidViewShouldResize:toPosition:allowOffscreen:)]) {
        return;
    }
    
    CGRect resizeFrame = CGRectMake(resizeProperties.offsetX, resizeProperties.offsetY, resizeProperties.width, resizeProperties.height);
    // The offset of the resize frame is relative to the origin of the default banner.
    CGPoint bannerOriginInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
    resizeFrame.origin.x += bannerOriginInRootView.x;
    resizeFrame.origin.y += bannerOriginInRootView.y;
    
    if (![self.delegate mraidViewShouldResize:self toPosition:resizeFrame allowOffscreen:resizeProperties.allowOffscreen]) {
        return;
    }
    
    // resize here
    state = PNLiteMRAIDStateResized;
    [self fireStateChangeEvent];
    
    if (!resizeView) {
        resizeView = [[UIView alloc] initWithFrame:resizeFrame];
        [webView removeFromSuperview];
        [resizeView addSubview:webView];
        [self addContentInfoViewToView:webView];
        [self.rootViewController.view addSubview:resizeView];
    }
    
    resizeView.frame = resizeFrame;
    webView.frame = resizeView.bounds;
    [self showResizeCloseRegion];
    [self fireSizeChangeEvent];
    [self setWebViewConstraintsInRelationWithView:resizeView];
}

- (void)setOrientationProperties:(NSDictionary *)properties; {
    BOOL allowOrientationChange = [[properties valueForKey:@"allowOrientationChange"] boolValue];
    NSString *forceOrientation = [properties valueForKey:@"forceOrientation"];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@ %@", NSStringFromSelector(_cmd), (allowOrientationChange ? @"YES" : @"NO"), forceOrientation]];
    orientationProperties.allowOrientationChange = allowOrientationChange;
    orientationProperties.forceOrientation = [PNLiteMRAIDOrientationProperties MRAIDForceOrientationFromString:forceOrientation];
    [modalVC forceToOrientation:orientationProperties];
}

- (void)setResizeProperties:(NSDictionary *)properties; {
    int width = [[properties valueForKey:@"width"] intValue];
    int height = [[properties valueForKey:@"height"] intValue];
    int offsetX = [[properties valueForKey:@"offsetX"] intValue];
    int offsetY = [[properties valueForKey:@"offsetY"] intValue];
    NSString *customClosePosition = [properties valueForKey:@"customClosePosition"];
    BOOL allowOffscreen = [[properties valueForKey:@"allowOffscreen"] boolValue];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %d %d %d %d %@ %@", NSStringFromSelector(_cmd), width, height, offsetX, offsetY, customClosePosition, (allowOffscreen ? @"YES" : @"NO")]];
    resizeProperties.width = width;
    resizeProperties.height = height;
    resizeProperties.offsetX = offsetX;
    resizeProperties.offsetY = offsetY;
    resizeProperties.customClosePosition = [PNLiteMRAIDResizeProperties MRAIDCustomClosePositionFromString:customClosePosition];
    resizeProperties.allowOffscreen = allowOffscreen;
}

- (void)storePicture:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.storePicture when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString=[urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    
    if ([supportedFeatures containsObject:PNLiteMRAIDSupportsStorePicture]) {
        if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceStorePictureWithUrlString:)]) {
            [self.serviceDelegate mraidServiceStorePictureWithUrlString:urlString];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"No PNLiteMRAIDSupportsStorePicture feature has been included"]];
    }
}

// DEPRECATED: useCustomClose is deprecated as from MRAID 3.0
- (void)useCustomClose:(NSString *)isCustomCloseString {
    BOOL isCustomClose = [isCustomCloseString boolValue];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), (isCustomClose ? @"YES" : @"NO")]];
    useCustomClose = isCustomClose;
    obtainedUseCustomCloseValue = YES;
}

#pragma mark - JavaScript --> native support helpers

// These methods are helper methods for the ones above.
- (void)addContentInfoViewToView:(UIView *)view {
    if (!contentInfoViewContainer) {
        contentInfoViewContainer = [[UIView alloc] init];
        [contentInfoViewContainer setIsAccessibilityElement:NO];
        contentInfoView.delegate = self;
    }
    [view addSubview:contentInfoViewContainer];
    [contentInfoViewContainer addSubview:contentInfoView];
    
    [[HyBidViewabilityWebAdSession sharedInstance] addFriendlyObstruction:contentInfoViewContainer toOMIDAdSession:adSession withReason:@"This view is related to Content Info" isInterstitial:isInterstitial];
    
    contentInfoViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObjects:
        [NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kContentInfoViewWidth],
        [NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kContentInfoViewHeight], nil];
    
    if (@available(iOS 11.0, *)) {
        contentInfoView.verticalPosition == HyBidContentInfoVerticalPositionTop ?
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]] :
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        
        contentInfoView.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ?
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]] :
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
    } else {
        contentInfoView.verticalPosition == HyBidContentInfoVerticalPositionTop ?
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]] :
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];

        contentInfoView.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ?
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]] :
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentInfoViewContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)addCloseEventRegion {
    for (UIView *view in modalVC.view.subviews) {
        if ([view tag] == HYBID_MRAID_CLOSE_BUTTON_TAG) {
            return;
        }
    }
    
    [self removeView:self.skipOverlay];
    
    if(modalVC.view){
        closeButton = [[HyBidCloseButton alloc] initWithRootView:modalVC.view action:@selector(close) target:self];
        [closeButton setTag:HYBID_MRAID_CLOSE_BUTTON_TAG];
    }
}

- (BOOL)isContentInfoInTopLeftPosition {
    BOOL isLeftPosition = contentInfoView.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ? YES : NO;
    BOOL isTopPosition = contentInfoView.verticalPosition == HyBidContentInfoVerticalPositionTop ? YES : NO;
    
    return isLeftPosition && isTopPosition ? YES : NO;
}

- (void)setCloseButtonPosition:(UIView *) closeButtonView {
    
    BOOL isCloseViewShown = [modalVC.view.subviews containsObject:closeButtonView];
    
    if(!isCloseViewShown){ return; }
    
    closeButtonView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [closeButtonView.superview.constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        if (constraint.firstItem == closeButtonView || constraint.secondItem == closeButtonView) {
            [closeButtonView.superview removeConstraint:constraint];
        }
    }];
    
    [closeButtonView removeConstraints:closeButtonView.constraints];
    
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObjects:
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseButtonSize],
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseButtonSize], nil];
    
    if([self isContentInfoInTopLeftPosition]){
        if (modalVC != nil) {
            if (@available(iOS 11.0, *)) {
                [constraints addObjectsFromArray: @[
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:modalVC.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]
                ]];
            } else {
                [constraints addObjectsFromArray: @[
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:modalVC.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]]];
            }
        }
    } else {
        if (modalVC != nil) {
            if (@available(iOS 11.0, *)) {
                [constraints addObjectsFromArray: @[
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]
                ]];
            } else {
                [constraints addObjectsFromArray: @[
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]
                ]];
            }
        }
    }
    [NSLayoutConstraint activateConstraints: constraints];
}

- (void)showResizeCloseRegion {
    if (!resizeCloseRegion) {
        resizeCloseRegion = [UIButton buttonWithType:UIButtonTypeCustom];
        resizeCloseRegion.frame = CGRectMake(0, 0, kCloseButtonSize, kCloseButtonSize);
        resizeCloseRegion.backgroundColor = [UIColor clearColor];
        [resizeCloseRegion addTarget:self action:@selector(closeFromResize) forControlEvents:UIControlEventTouchUpInside];
        [resizeView addSubview:resizeCloseRegion];
    }
    
    // align appropriately
    int x;
    int y;
    UIViewAutoresizing autoresizingMask = UIViewAutoresizingNone;
    
    switch (resizeProperties.customClosePosition) {
        case PNLiteMRAIDCustomClosePositionTopLeft:
        case PNLiteMRAIDCustomClosePositionBottomLeft:
            x = 0;
            break;
        case PNLiteMRAIDCustomClosePositionTopCenter:
        case PNLiteMRAIDCustomClosePositionCenter:
        case PNLiteMRAIDCustomClosePositionBottomCenter:
            x = (CGRectGetWidth(resizeView.frame) - CGRectGetWidth(resizeCloseRegion.frame)) / 2;
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
        case PNLiteMRAIDCustomClosePositionTopRight:
        case PNLiteMRAIDCustomClosePositionBottomRight:
            x = CGRectGetWidth(resizeView.frame) - CGRectGetWidth(resizeCloseRegion.frame);
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            break;
    }
    
    switch (resizeProperties.customClosePosition) {
        case PNLiteMRAIDCustomClosePositionTopLeft:
        case PNLiteMRAIDCustomClosePositionTopCenter:
        case PNLiteMRAIDCustomClosePositionTopRight:
            y = 0;
            break;
        case PNLiteMRAIDCustomClosePositionCenter:
            y = (CGRectGetHeight(resizeView.frame) - CGRectGetHeight(resizeCloseRegion.frame)) / 2;
            autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
        case PNLiteMRAIDCustomClosePositionBottomLeft:
        case PNLiteMRAIDCustomClosePositionBottomCenter:
        case PNLiteMRAIDCustomClosePositionBottomRight:
            y = CGRectGetHeight(resizeView.frame) - CGRectGetHeight(resizeCloseRegion.frame);
            autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
            break;
    }
    
    CGRect resizeCloseRegionFrame = resizeCloseRegion.frame;
    resizeCloseRegionFrame.origin = CGPointMake(x, y);
    resizeCloseRegion.frame = resizeCloseRegionFrame;
    resizeCloseRegion.autoresizingMask = autoresizingMask;
}

- (void)removeResizeCloseRegion {
    if (resizeCloseRegion) {
        [resizeCloseRegion removeFromSuperview];
        resizeCloseRegion = nil;
    }
}

- (void)removeView: (UIView*) view {
    if(view){
        [view removeFromSuperview];
        view = nil;
    }
}

- (void)invalidateCloseButtonOffsetTimer
{
    if([self.closeButtonOffsetTimer isValid]){
        [self.closeButtonOffsetTimer invalidate];
    }
    self.closeButtonOffsetTimer = nil;
}

- (void)setResizeViewPosition {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    CGRect oldResizeFrame = resizeView.frame;
    CGRect newResizeFrame = CGRectMake(resizeProperties.offsetX, resizeProperties.offsetY, resizeProperties.width, resizeProperties.height);
    // The offset of the resize frame is relative to the origin of the default banner.
    CGPoint bannerOriginInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
    newResizeFrame.origin.x += bannerOriginInRootView.x;
    newResizeFrame.origin.y += bannerOriginInRootView.y;
    if (!CGRectEqualToRect(oldResizeFrame, newResizeFrame)) {
        resizeView.frame = newResizeFrame;
    }
}

- (void)determineUseCustomCloseBehaviourWith:(HyBidSkipOffset*) closeButtonDelay showSkipOverlay:(BOOL) showSkipOverlay {
    adNeedsSkipOverlay = showSkipOverlay;
    //adding delay (0.5) to wait for get useCustomClose value
    CGFloat delay = obtainedUseCustomCloseValue ? 0.0 : secondsToWaitForCustomCloseValue;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(useCustomClose){
            [self removeView:self.skipOverlay];
            [self invalidateCloseButtonOffsetTimer];
            [self removeView:closeButton];
            if(closeButtonDelay){
                [self startCloseButtonTimerWith:closeButtonDelay];
            }
        } else {
            if(adNeedsSkipOverlay){
                if(!self.skipOverlay){
                    [self addSkipOverlay];
                }
            } else {
                [self addCloseEventRegion];
            }
        }
    });
}

- (void)startCloseButtonTimerWith:(HyBidSkipOffset*) closeButtonDelay
{
    [self removeView:self.skipOverlay];
    for (UIView *view in modalVC.view.subviews) {
        if ([view tag] == HYBID_MRAID_CLOSE_BUTTON_TAG) {
            [view removeFromSuperview];
        }
    }
    
    if(([closeButtonDelay.offset intValue] - self.closeButtonTimeElapsed) <= 0){
        [self addCloseEventRegion];
        return;
    }
    
    if(![self.closeButtonOffsetTimer isValid]){
        self.closeButtonOffsetTimer = [NSTimer scheduledTimerWithTimeInterval: 1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            self.closeButtonTimeElapsed += 1;
            NSInteger remaningCloseButtonDelayTime = [closeButtonDelay.offset intValue] - self.closeButtonTimeElapsed;
            if(remaningCloseButtonDelayTime <= 0){
                [self addCloseEventRegion];
                [self invalidateCloseButtonOffsetTimer];
            }
        }];
    }
}


#pragma mark - native -->  JavaScript support

- (void)injectJavaScript:(NSString *)js {
    [currentWebView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {}];
}

// convenience methods
- (void)fireErrorEventWithAction:(NSString *)action message:(NSString *)message {
    [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireErrorEvent('%@','%@');", message, action]];
}

- (void)fireReadyEvent {
    [self injectJavaScript:@"mraid.fireReadyEvent()"];
}

- (void)fireSizeChangeEvent {
    @synchronized(self) {
        int x;
        int y;
        int width;
        int height;
        if (state == PNLiteMRAIDStateExpanded || isInterstitial) {
            x = (int)currentWebView.frame.origin.x;
            y = (int)currentWebView.frame.origin.y;
            width = (int)currentWebView.frame.size.width;
            height = (int)currentWebView.frame.size.height;
        } else if (state == PNLiteMRAIDStateResized) {
            x = (int)resizeView.frame.origin.x;
            y = (int)resizeView.frame.origin.y;
            width = (int)resizeView.frame.size.width;
            height = (int)resizeView.frame.size.height;
        } else {
            // Per the MRAID spec, the current or default position is relative to the rectangle defined by the getMaxSize method,
            // that is, the largest size that the ad can resize to.
            CGPoint originInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
            x = originInRootView.x;
            y = originInRootView.y;
            width = (int)self.frame.size.width;
            height = (int)self.frame.size.height;
        }
        
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
        BOOL adjustOrientationForIOS8 = isInterstitial &&  isLandscape && !SYSTEM_VERSION_LESS_THAN(@"8.0");
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setCurrentPosition(%d,%d,%d,%d);", x, y, adjustOrientationForIOS8?height:width, adjustOrientationForIOS8?width:height]];
    }
}

- (void)fireStateChangeEvent {
    @synchronized(self) {
        NSArray *stateNames = @[
                                @"loading",
                                @"default",
                                @"expanded",
                                @"resized",
                                @"hidden",
                                ];
        
        NSString *stateName = stateNames[state];
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireStateChangeEvent('%@');", stateName]];
    }
}

- (void)fireViewableChangeEvent {
    [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireViewableChangeEvent(%@);", (self.isViewable ? @"true" : @"false")]];
}

- (void)fireExposureChange {
    
    CGFloat updatedExposedPercentage = [self exposedPercent];
    CGRect updatedVisibleRectangle = [self visibleRect];
    
    // Send exposureChange Event only when there is an update from the previous.
    if(exposedPercentage != updatedExposedPercentage || !CGRectEqualToRect(visibleRect,updatedVisibleRectangle)) {
        exposedPercentage = updatedExposedPercentage;
        visibleRect = updatedVisibleRectangle;
        
        NSString* jsonExposureChange = @"";
        if (exposedPercentage <=0 ) {
            // If exposure percentage is 0 then send visibleRectangle as null.
            jsonExposureChange = [NSString stringWithFormat:@"{\"exposedPercentage\":0.0,\"visibleRectangle\":null,\"occlusionRectangles\":null}"];
        } else {
            
            int offsetX = (visibleRect.origin.x > 0) ? floorf(visibleRect.origin.x) : ceilf(visibleRect.origin.x);
            int offsetY = (visibleRect.origin.y > 0) ? floorf(visibleRect.origin.y) : ceilf(visibleRect.origin.y);
            int width = floorf(visibleRect.size.width);
            int height = floorf(visibleRect.size.height);
            
            jsonExposureChange = [NSString stringWithFormat:@"{\"exposedPercentage\":%.01f,\"visibleRectangle\":{\"x\":%i,\"y\":%i,\"width\":%i,\"height\":%i},\"occlusionRectangles\":null}",exposedPercentage,offsetX,offsetY,width,height];
        }

        [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireExposureChangeEvent(%@);", jsonExposureChange]];
    }
}

- (void)fireAudioVolumeChangeEvent {
    [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireAudioVolumeChangeEvent(%@);", [HyBidSettings sharedInstance].audioVolumePercentage]];
}

- (void)setDefaultPosition {
    if (isInterstitial) {
        // For interstitials, we define defaultPosition to be the same as screen size, so set the value there.
        return;
    }
    
    // getDefault position from the parent frame if we are not directly added to the rootview
    if(self.superview != self.rootViewController.view) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(%f,%f,%f,%f);", self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height]];
    } else {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(%f,%f,%f,%f);", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height]];
    }
}

- (void)setMaxSize {
    if (isInterstitial) {
        // For interstitials, we define maxSize to be the same as screen size, so set the value there.
        return;
    }
    CGSize maxSize = self.rootViewController.view.bounds.size;
    if (!CGSizeEqualToSize(maxSize, previousMaxSize)) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setMaxSize(%d,%d);",
                                (int)maxSize.width,
                                (int)maxSize.height]];
        previousMaxSize = CGSizeMake(maxSize.width, maxSize.height);
    }
}

- (void)setScreenSize {
    CGSize screenSize = self.frame.size;
    // screenSize is ALWAYS for portrait orientation, so we need to figure out the
    // actual interface orientation to get the correct current screenRect.
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        screenSize = CGSizeMake(screenSize.width, screenSize.height);
    } else {
        if (isLandscape) {
            screenSize = CGSizeMake(screenSize.height, screenSize.width);
        }
    }
    if (!CGSizeEqualToSize(screenSize, previousScreenSize)) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setScreenSize(%d,%d);",
                                (int)screenSize.width,
                                (int)screenSize.height]];
        previousScreenSize = CGSizeMake(screenSize.width, screenSize.height);
        if (isInterstitial) {
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setMaxSize(%d,%d);",
                                    (int)screenSize.width,
                                    (int)screenSize.height]];
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(0,0,%d,%d);",
                                    (int)screenSize.width,
                                    (int)screenSize.height]];
        }
    }
}

- (void)setSupports:(NSArray *)currentFeatures {
    for (id aFeature in mraidFeatures) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setSupports('%@',%@);", aFeature,[currentFeatures containsObject:aFeature]?@"true":@"false"]];
    }
}

-(void)setLocation {
    if ([HyBidLocationConfig sharedConfig].locationTrackingEnabled) {
        CLLocation* location = [HyBidSettings sharedInstance].location;
        if (location) {
            NSArray *objects = [[NSArray alloc] initWithObjects:
                                [NSNumber numberWithDouble:location.coordinate.latitude],
                                [NSNumber numberWithDouble:location.coordinate.longitude],
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithDouble:[location horizontalAccuracy]],
                                [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:location.timestamp]], nil];
            NSArray *keys = [[NSArray alloc] initWithObjects:@"lat", @"lon", @"type", @"accuracy", @"lastfix", nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
            if (!error) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self injectJavaScript:[NSString stringWithFormat:@"mraid.setLocation(%@);", jsonString]];
            } else {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Error creating the JSON location object."];
                [self injectJavaScript:@"mraid.setLocation(-1);"];
            }
        } else {
            [self injectJavaScript:@"mraid.setLocation(-1);"];
        }
    } else {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Location tracking is not enabled."];
        [self injectJavaScript:@"mraid.setLocation(-1);"];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    @synchronized(self) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
        
        if (webView.frame.size.height == CGSizeZero.height && webView.frame.size.width == CGSizeZero.width) {
            self.frame = CGRectMake(0, 0, webView.scrollView.contentSize.width, webView.scrollView.contentSize.height);
            CGRect frame = webView.frame;
            frame.size = self.frame.size;
            frame.origin = self.frame.origin;
            webView.frame = frame;
        }
        
        // If wv is webViewPart2, that means the part 2 expanded web view has just loaded.
        // In this case, state should already be PNLiteMRAIDStateExpanded and should not be changed.
        // if (wv != webViewPart2) {
        
        if (PNLite_ENABLE_JS_LOG) {
            [webView evaluateJavaScript:@"var enableLog = true" completionHandler:^(id result, NSError *error) {}];
        }
        
        if (PNLite_SUPPRESS_JS_ALERT) {
            [webView evaluateJavaScript:@"function alert(){}; function prompt(){}; function confirm(){}" completionHandler:^(id result, NSError *error) {}];
        }
        
        [webView evaluateJavaScript:[navigatorGeolocation getJavaScriptToEvaluate] completionHandler:^(id result, NSError *error) {}];
        
        if (state == PNLiteMRAIDStateLoading) {
            state = PNLiteMRAIDStateDefault;
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setPlacementType('%@');", (isInterstitial ? @"interstitial" : @"inline")]];
            [self setSupports:supportedFeatures];
            [self setLocation];
            [self setDefaultPosition];
            [self setMaxSize];
            [self setScreenSize];
            [self fireStateChangeEvent];
            [self fireSizeChangeEvent];
            [self fireReadyEvent];
            
            if ([self.delegate respondsToSelector:@selector(mraidViewAdReady:)]) {
                // Interstitials isViewable flag will be fired only when they are showing.
                if (!isInterstitial) {
                    self.isViewable = YES;
                }
                [self setupTimerForCheckingViewability:HYBID_MRAID_Check_Viewable_Frequency];
                [self.delegate mraidViewAdReady:self];
            }
            
            if (!isInterstitial) {
                [self addContentInfoViewToView:self];
            }
            
            // Start monitoring device orientation so we can reset max Size and screenSize if needed.
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(deviceOrientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = [navigationAction.request URL];
    NSString *scheme = [url scheme];
    NSString *absUrlString = [url absoluteString];
    
    if ([scheme isEqualToString:@"mraid"]) {
        [self parseCommandUrl:absUrlString];
        
    } else if ([scheme isEqualToString:@"console-log"]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS console: %@",
                                                         [[absUrlString substringFromIndex:14] stringByRemovingPercentEncoding ]]];
    } else {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Found URL %@ with type %@", absUrlString, @(navigationAction.navigationType)]];
        
        // Links, Form submissions
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            // For banner views
            if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS webview load: %@",
                                                                 [absUrlString stringByRemovingPercentEncoding]]];
                if ([absUrlString containsString:@"tags-prod.vrvm.com"]
                    && [absUrlString containsString:@"type=expandable"]
                    && self.isViewable) {
                    [self expand:absUrlString supportVerve:YES];
                    if(isInterstitial){
                        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
                    }
                } else if ([absUrlString containsString:@"https://feedback.verve.com"]){
                    if ([absUrlString containsString:@"close"]) {
                        [self close];
                    }
                } else {
                    [self.delegate mraidViewNavigate:self withURL:url];
                }
            }
        } else {
            // Need to let browser to handle rendering and other things
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
}

#pragma mark - OM SDK Viewability

- (void)startAdSession {
    
    if (!isAdSessionCreated) {
        
        adSession = [[HyBidViewabilityWebAdSession sharedInstance] createOMIDAdSessionforWebView:currentWebView isVideoAd:NO];

        if (isInterstitial) {
            [[HyBidViewabilityWebAdSession sharedInstance] addFriendlyObstruction:closeButton toOMIDAdSession:adSession withReason:@"" isInterstitial:isInterstitial];
            [[HyBidViewabilityWebAdSession sharedInstance] addFriendlyObstruction:self.skipOverlay toOMIDAdSession:adSession withReason:@"" isInterstitial:isInterstitial];
        }
        [[HyBidViewabilityWebAdSession sharedInstance] startOMIDAdSession:adSession];
        isAdSessionCreated = YES;
        [[HyBidViewabilityWebAdSession sharedInstance] fireOMIDAdLoadEvent:adSession];
        [[HyBidViewabilityWebAdSession sharedInstance] fireOMIDImpressionOccuredEvent:adSession];
    }
     
}

- (void)stopAdSession {
    if (isAdSessionCreated) {
        [[HyBidViewabilityWebAdSession sharedInstance] stopOMIDAdSession:adSession];
        isAdSessionCreated = NO;
    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    // Open any links to new windows in the current WKWebView rather than create a new one
    if (!navigationAction.targetFrame.isMainFrame) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS webview load: %@",
                                                                                                                              [[[navigationAction.request URL] absoluteString] stringByRemovingPercentEncoding]]];
            [self.delegate mraidViewNavigate:self withURL:[navigationAction.request URL]];
        }
    }
    
    return nil;
}

#pragma mark - MRAIDModalViewControllerDelegate

- (void)mraidModalViewControllerDidRotate:(PNLiteMRAIDModalViewController *)modalViewController {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self setScreenSize];
    [self fireSizeChangeEvent];
}

#pragma mark - internal helper methods

- (WKWebViewConfiguration *)createConfiguration {
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webConfiguration.userContentController = wkUController;

    if ([supportedFeatures containsObject:PNLiteMRAIDSupportsInlineVideo]) {
        webConfiguration.allowsInlineMediaPlayback = YES;
        webConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    } else {
        webConfiguration.allowsInlineMediaPlayback = NO;
        webConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"No inline video support has been included, videos will play full screen without autoplay."]];
    }
    
    return webConfiguration;
}

- (void)initWebView:(WKWebView *)wv {
    wv.navigationDelegate = self;
    wv.UIDelegate = self;
    wv.opaque = NO;
    
    // disable scrolling
    UIScrollView *scrollView;
    if ([wv respondsToSelector:@selector(scrollView)]) {
        scrollView = [wv scrollView];
    } else {
        for (id subview in [self subviews]) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                scrollView = subview;
                break;
            }
        }
    }
    scrollView.scrollEnabled = isScrollable;
    
    // disable selection
    NSString *js = @"window.getSelection().removeAllRanges();";
    [wv evaluateJavaScript:js completionHandler:^(id result, NSError *error) {}];
    
    // Alert suppression
    if (PNLite_SUPPRESS_JS_ALERT)
        [wv evaluateJavaScript:@"function alert(){}; function prompt(){}; function confirm(){}" completionHandler:^(id result, NSError *error) {}];
}

- (void)parseCommandUrl:(NSString *)commandUrlString {
    NSDictionary *commandDict = [mraidParser parseCommandUrl:commandUrlString];
    if (!commandDict) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"invalid command URL: %@", commandUrlString]];
        return;
    }
    
    NSString *command = [commandDict valueForKey:@"command"];
    NSObject *paramObj = [commandDict valueForKey:@"paramObj"];
    
    if ([command isEqualToString:@"expand:"]) {
        command = @"expand:supportVerve:";
    }
    SEL selector = NSSelectorFromString(command);
    
    // Turn off the warning "PerformSelector may cause a leak because its selector is unknown".
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:selector withObject:paramObj];
    
#pragma clang diagnostic pop
}

#pragma mark - Gesture Methods

- (void)setUpTapGestureRecognizer {
    if(!PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        return;  // return without adding the GestureRecognizer if the feature is not enabled
    }
    // One finger, one tap
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerOneTap)];
    
    // Set up
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    // Add the gesture to the view
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)oneFingerOneTap {
    bonafideTapObserved=YES;
    tapObserved = YES;
    startedFromTap = YES;
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture oneFingerTap observed"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == resizeCloseRegion || touch.view == closeButton) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture 'shouldReceiveTouch'=NO"];
        return NO;
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture 'shouldReceiveTouch'=YES"];
    return YES;
}

// MRAID Viewbility Timer

-(void)setupTimerForCheckingViewability:(NSTimeInterval)timeInterval {
    
    if (viewabilityTimer) {
        [viewabilityTimer invalidate];
    }

    __weak HyBidMRAIDView *weakSelf = self;

    if (@available(iOS 10.0, *)) {
        viewabilityTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf fireExposureChange];
        }];
    } else {
        // Fallback on earlier versions
        // Runs only once when MRAID is loaded
        [weakSelf fireExposureChange];
    }
    
}

#pragma mark Handling Auto/Manual taps

- (void)openBrowserWithURLString:(NSString *)urlString {
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) {
        [self.serviceDelegate mraidServiceOpenBrowserWithUrlString:urlString];
    }
}

- (void)doTrackingEndcardWithUrlString:(NSString *)urlString {
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceTrackingEndcardWithUrlString:)]) {
        [self.serviceDelegate mraidServiceTrackingEndcardWithUrlString:urlString];
    }
}

- (void)openAppStoreWithAppID:(NSString *)urlString {
    if (isStoreViewControllerPresented || isStoreViewControllerBeingPresented) {
        return; // Return early if the Store VC is already being presented
    }
    
    isStoreViewControllerBeingPresented = YES;
    
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;
    
    NSString* appID = [self extractAppIDFromAppStoreURL:urlString];
    
    if (appID) {
        NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: appID};
        [storeViewController loadProductWithParameters:parameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self doTrackingEndcardWithUrlString:urlString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].topViewController presentViewController:storeViewController animated:YES completion:nil];
                    isStoreViewControllerPresented = YES;
                });
            } else {
                [self openBrowserWithURLString:urlString];
            }
            isStoreViewControllerBeingPresented = NO;
        }];
    } else {
        [self openBrowserWithURLString:urlString];
        isStoreViewControllerBeingPresented = NO;
    }
}

- (NSString *)extractAppIDFromAppStoreURL:(NSString *)urlString {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\/id(\\d+)" options:0 error:&error];
    
    if (!error) {
        NSTextCheckingResult *result = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
        if (result && result.range.location != NSNotFound) {
            NSRange idRange = [result rangeAtIndex:1];
            NSString *appID = [urlString substringWithRange:idRange];
            return appID;
        }
    }
    
    return nil;
}

#pragma mark HyBidURLRedirectorDelegate

- (void)onURLRedirectorFailWithUrl:(NSString * _Nonnull)url withError:(NSError * _Nonnull)error {
    tapObserved = NO;
    startedFromTap = NO;
}

- (void)onURLRedirectorFinishWithUrl:(NSString * _Nonnull)url {
    tapObserved = NO;
    [self open:url];
}

- (void)onURLRedirectorRedirectWithUrl:(NSString * _Nonnull)url {
    
}

- (void)onURLRedirectorStartWithUrl:(NSString * _Nonnull)url {
    
}

#pragma mark SKStoreProductViewControllerDelegate

// Delegate method when Store VC is dismissed
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    isStoreViewControllerPresented = NO;
}

@end
