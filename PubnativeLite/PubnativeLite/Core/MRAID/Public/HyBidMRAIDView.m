// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidMRAIDView.h"
#import "PNLiteMRAIDOrientationProperties.h"
#import "PNLiteMRAIDResizeProperties.h"
#import "PNLiteMRAIDParser.h"
#import "PNLiteMRAIDModalViewController.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "PNLiteMRAIDUtil.h"
#import "PNLiteMRAIDSettings.h"

#import "HyBidViewabilityWebAdSession.h"
#import "HyBidNavigatorGeolocation.h"
#import "HyBidCloseButton.h"

#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#import "HyBidSkipOverlay.h"
#import "HyBidTimerState.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidEndCardView.h"
#import "HyBidStoreKitUtils.h"
#import "HyBidCustomClickUtil.h"
#import "HyBidURLDriller.h"
#import "OMIDAdSessionWrapper.h"

#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define HYBID_MRAID_CLOSE_BUTTON_TAG 1001

CGFloat const kContentInfoViewHeight = 15.0f;
CGFloat const kContentInfoViewWidth = 15.0f;
CGFloat const landingPageJSInjectionDelay = 2.0f;
CGFloat const landingPageSecondsToCloseAdDelay = 30.0f;

typedef enum {
    PNLiteMRAIDStateLoading,
    PNLiteMRAIDStateDefault,
    PNLiteMRAIDStateExpanded,
    PNLiteMRAIDStateResized,
    PNLiteMRAIDStateHidden
} PNLiteMRAIDState;

@interface HyBidMRAIDView () <WKNavigationDelegate, WKUIDelegate, PNLiteMRAIDModalViewControllerDelegate, UIGestureRecognizerDelegate, HyBidContentInfoViewDelegate, HyBidSkipOverlayDelegate, HyBidInterruptionDelegate, HyBidURLRedirectorDelegate, HyBidEndCardViewDelegate, HyBidURLDrillerDelegate>
{
    PNLiteMRAIDState state;
    // This corresponds to the MRAID placement type.
    BOOL isInterstitial;
    BOOL isEndcard;
    BOOL isAdSessionCreated;
    BOOL isScrollable;
    BOOL isExpanded;

    OMIDAdSessionWrapper *adSession;
    
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
    BOOL startedFromTap;
    
    NSString* urlFromMraidOpen;

    CGFloat adWidth;
    CGFloat adHeight;
    
    // Params for exposedChange introduced with MRAID 3.0
    CGFloat exposedPercentage;
    CGRect visibleRect;
    
    BOOL adNeedsCloseButton;
    BOOL adNeedsSkipOverlay;
    BOOL obtainedUseCustomCloseValue;
    CGSize buttonSize;
    BOOL landingPageFlowActive;
    BOOL firstLinkActiveRedirected;
    BOOL hideCountdownForLandingPage;
    BOOL isSkipTimerCompleted;
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
- (void)parseCommandUrl:(NSString *)commandUrlString prefixToRemove:(NSString *)prefixToRemove;

@property (nonatomic, strong) NSTimer *closeButtonOffsetTimer;
@property (nonatomic, assign) NSTimeInterval closeButtonTimeElapsed;
@property (nonatomic, strong) HyBidSkipOverlay *skipOverlay;
@property (nonatomic, assign) HyBidCountdownStyle countdownStyle;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL willShowFeedbackScreen;
@property (nonatomic, strong) HyBidSkipOffset *nativeCloseButtonDelay;
@property (nonatomic, assign) BOOL creativeAutoStorekitEnabled;
@property (nonatomic, strong) NSString *landingPageTemplateScript;
@property (nonatomic, assign) int landingpageCloseDelay;
@property (nonatomic, strong) NSTimer *landingpageTimer;
@property (nonatomic, assign) int landingpageTimeElapsed;
@property (nonatomic, assign) BOOL landingpageTimerShouldPause;
@property (nonatomic, assign) HyBidLandingBehaviourType landingpageBehaviour;
@property (nonatomic, strong) HyBidEndCardView *endCardView;
@property (nonatomic, strong) NSURL * _Nullable clickThrough;
@property (nonatomic, strong) NSTimer *autoStoreKitDelayTimer;
@property (nonatomic, assign) NSTimeInterval storekitDelayTimeElapsed;
@property (nonatomic, strong) NSDate *storekitDelayTimerStartDate;
@property (nonatomic, assign) BOOL isTimerPaused;
@property (nonatomic, assign) BOOL isAutoStoreKit;
@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;
@property (nonatomic, assign) BOOL shouldHandleInterruptions;

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
          isEndcard:(BOOL)isEndcardPresented
shouldHandleInterruptions:(BOOL)shouldHandleInterruptions {
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
                     isEndcard:isEndcardPresented
     shouldHandleInterruptions:shouldHandleInterruptions];
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
          isEndcard:(BOOL)isEndcardPresented
shouldHandleInterruptions:(BOOL)shouldHandleInterruptions {
    self = [super initWithFrame:frame];
    if (self) {
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
        _skipOffset = skipOffset;
        isExpanded = NO;

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
        
        self.shouldHandleInterruptions = shouldHandleInterruptions;
        
        if([self isValidFeatureSet:currentFeatures] && serviceDelegate) {
            supportedFeatures=currentFeatures;
        }
        self.ad = ad;
        navigatorGeolocation = [[HyBidNavigatorGeolocation alloc] init];
        if ([NSThread isMainThread]) {
            webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) configuration:[self createConfiguration]];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) configuration:[self createConfiguration]];
            });
        }
        [self initWebView:webView];
        currentWebView = webView;
        [navigatorGeolocation assignWebView:currentWebView];
        [self addSubview:currentWebView];
        
        [self setWebViewConstraintsInRelationWithView:self];
        
        previousMaxSize = CGSizeZero;
        previousScreenSize = CGSizeZero;
        
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
       
        baseURL = bsURL;
        state = PNLiteMRAIDStateLoading;
        
        [self setUpTapGestureRecognizer];
        if (baseURL != nil && [[baseURL absoluteString] length]!= 0) {
            __block NSString *htmlData = htmlData;
            [self htmlFromUrl:baseURL handler:^(NSString *html, NSError *error) {
                if(html && !error){
                    htmlData = [PNLiteMRAIDUtil processRawHtml:html];
                    [self loadHTMLDataWithBaseURL:htmlData];
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
                    
                    if (isEndcard && [self.delegate respondsToSelector:@selector(mraidViewAdFailed:withError:)]) {
                        [self.delegate mraidViewAdFailed:self withError:error];
                    } else if ([self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
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
        
        buttonSize = [HyBidCloseButton buttonDefaultSize];
        
        self.landingpageBehaviour = HyBidLandingBehaviourTypeCountdown;
        self.landingpageCloseDelay = landingPageSecondsToCloseAdDelay;
        
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEventsDictionary:nil
                                                                   progressEventsDictionary:nil
                                                                                   delegate:nil];
        if (![self hasValidSkanObject] && ad.link && [ad.link isKindOfClass:[NSString class]]) {
            NSString *link = [ad.link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (link.length > 0 && ad.link == link) {
                NSURL *url = [[NSURL alloc] initWithString:link];
                self.clickThrough = url;
            }
        }
    }
    return self;
}

- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets safeArea = [super safeAreaInsets];
    safeArea.bottom = 0;
    return safeArea;
}

- (nullable UIView *)modalView {
    if (modalVC && modalVC.view) { return modalVC.view; }
    return nil;
}

- (void)determineNativeCloseButtonDelayForAd:(HyBidAd *)ad {
    if (ad.nativeCloseButtonDelay) {
        if([ad.nativeCloseButtonDelay integerValue] >= 0 && [ad.nativeCloseButtonDelay integerValue] < HyBidSkipOffset.DEFAULT_NATIVE_CLOSE_BUTTON_OFFSET){
            self.nativeCloseButtonDelay = [[HyBidSkipOffset alloc] initWithOffset:ad.nativeCloseButtonDelay isCustom:YES];
        } else {
            self.nativeCloseButtonDelay = HyBidConstants.nativeCloseButtonOffset;
        }
    } else {
        self.nativeCloseButtonDelay = HyBidConstants.nativeCloseButtonOffset;
    }
}

- (void)determineCreativeAutoStorekitEnabledForAd:(HyBidAd *)ad {
    if ([ad.creativeAutoStorekitEnabled boolValue] && ![ad.sdkAutoStorekitEnabled boolValue]) {
        self.creativeAutoStorekitEnabled = YES;
    } else {
        self.creativeAutoStorekitEnabled = HyBidConstants.creativeAutoStorekitEnabled;
    }
}

- (void)playCountdownView {
    self.landingpageTimerShouldPause = NO;
    [self playLandingpageTimer];
    if (!self.skipOverlay) { return; }
    NSInteger remainingSeconds = [self.skipOverlay getRemainingTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds: remainingSeconds withTimerState:HyBidTimerState_Start];
}

- (void)pauseCountdownView {
    self.landingpageTimerShouldPause = YES;
    [self pauseLandingpageTimer];
    if (!self.skipOverlay) { return; }
    NSInteger remainingSeconds = [self.skipOverlay getRemainingTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds:(remainingSeconds) withTimerState:HyBidTimerState_Pause];
}

- (void)playCloseButtonDelay {
    self.landingpageTimerShouldPause = NO;
    [self playLandingpageTimer];
    if(!self.skipOverlay){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
    }
}

- (void)pauseCloseButtonDelay {
    self.landingpageTimerShouldPause = YES;
    [self pauseLandingpageTimer];
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
        [currentWebView loadHTMLString:htmlData baseURL:[NSURL URLWithString:@"https://example.com"]];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad HTML is invalid, cannot load."];
        if ([self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
            [self.delegate mraidViewAdFailed:self];
        }
    }
}

- (void)loadHTMLDataWithBaseURL:(NSString *)htmlData {
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
    
    [self removeObserver:self forKeyPath:@"frame"];
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
        
    self.delegate = nil;
    self.serviceDelegate = nil;
    self.ad = nil;
    self.skipOverlay = nil;
    self.nativeCloseButtonDelay = nil;
    self.urlStringForEndCardTracking = nil;
    [self invalidateCloseButtonOffsetTimer];
    self.landingPageTemplateScript = nil;
    self.landingpageTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.endCardView = nil;
    self.clickThrough = nil;
    [self removingAutoStoreKitViewTimer];
    self.storekitDelayTimeElapsed = 0;
    self.storekitDelayTimerStartDate = nil;
    self.vastEventProcessor = nil;
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
        CGRect parentFrame = currentWebView.frame;
        // We need to call convertRect:toView: on this view's superview rather than on this view itself.
        CGRect viewFrameInWindowCoordinates = [currentWebView.superview convertRect:currentWebView.frame toView:currentWebView];
        visibleRectangle = CGRectIntersection(viewFrameInWindowCoordinates, parentFrame);
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
    if ([keyPath isEqualToString:@"frame"]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"frame has changed."];
        
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

- (void)skipOverlayStarts {
    if (self.landingpageTimerShouldPause) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pauseCountdownView];
        });
    }
}

- (void)skipButtonTapped
{
    if ([self isValidToCreateCustomEndCardForAd:self.ad]) {
        [self showCustomEndCard];
    } else {
        [self removeView:self.skipOverlay];
        [self close];
    }
}

- (void)skipTimerCompleted
{
    isSkipTimerCompleted = YES;
    buttonSize = [HyBidCloseButton buttonSizeBasedOn:self.ad];
    if(isInterstitial && self.countdownStyle == HyBidCountdownPieChart){
        if (hideCountdownForLandingPage && [self.skipOverlay isHidden]) { [self.skipOverlay setHidden:NO]; }
        if([modalVC.view.subviews containsObject:self.skipOverlay]){
            [self setCloseButtonPosition: self.skipOverlay];
        }
    }
}

- (void)showCustomEndCard {
    HyBidEndCard *customEndCard = [[HyBidEndCard alloc] init];
    [customEndCard setType:HyBidEndCardType_HTML];
    [customEndCard setContent:self.ad.customEndCardData];
    [customEndCard setClickThrough:self.clickThrough.absoluteString];
    [customEndCard setIsCustomEndCard:YES];
    self.ad.customEndCard = customEndCard;
    
    NSString *iconXposition = contentInfoView.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ? @"left" : @"right";
    NSString *iconYposition = contentInfoView.verticalPosition == HyBidContentInfoVerticalPositionTop ? @"top" : @"bottom";
    self.endCardView = [[HyBidEndCardView alloc] initWithDelegate:self
                                                   withViewController:modalVC
                                                               withAd:self.ad
                                                           withVASTAd:nil
                                                       isInterstitial:isInterstitial
                                                        iconXposition:iconXposition
                                                        iconYposition:iconYposition
                                                       withSkipButton:NO
                                          vastCompanionsClicksThrough:nil
                                         vastCompanionsClicksTracking:nil
                                              vastVideoClicksTracking:nil
    ];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mraidViewWillShowEndCard:isCustomEndCard:skOverlayDelegate:)]){
        [self.delegate mraidViewWillShowEndCard:self isCustomEndCard:YES skOverlayDelegate:self.endCardView];
    }
    
    if(self.skipOverlay){ [self.skipOverlay removeFromSuperview]; }
    [self.endCardView setAutoStoreKitPresentationAllowed:NO];
    [self.endCardView displayEndCard:customEndCard withCTAButton:nil withViewController:modalVC];
    self.ad.shouldReportCustomEndcardImpression = YES;
    [contentInfoViewContainer setHidden: YES];
        
    [modalVC.view addSubview:self.endCardView];
    self.endCardView.frame = modalVC.view.frame;
    [self addingConstrainsForEndcard];
}

- (void)addingConstrainsForEndcard {
    if (self.endCardView == nil) {return;}
    [self.endCardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.endCardView.topAnchor constraintEqualToAnchor:modalVC.view.topAnchor] setActive:YES];
    [[self.endCardView.bottomAnchor constraintEqualToAnchor:modalVC.view.bottomAnchor] setActive:YES];
    [[self.endCardView.leadingAnchor constraintEqualToAnchor:modalVC.view.leadingAnchor] setActive:YES];
    [[self.endCardView.trailingAnchor constraintEqualToAnchor:modalVC.view.trailingAnchor] setActive:YES];
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
    
    [[HyBidInterruptionHandler shared] deactivateContext:HyBidAdContextMraidView];

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
    
    if (state != PNLiteMRAIDStateExpanded) {
        [currentWebView stopLoading];
        [currentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [currentWebView removeFromSuperview];
        currentWebView.navigationDelegate = nil;
        currentWebView.UIDelegate = nil;
        currentWebView = nil;
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
    [HyBidVASTTracker cleanTriggeredTrackersList];
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
        [self decideMRAIDExpand:HyBidConstants.mraidExpand withURL:urlString supportVerve:supportVerve];
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
        if ([NSThread isMainThread]) {
            webViewPart2 = [[WKWebView alloc] initWithFrame:frame configuration:[self createConfiguration]];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                webViewPart2 = [[WKWebView alloc] initWithFrame:frame configuration:[self createConfiguration]];
            });
        }
        [self initWebView:webViewPart2];
        currentWebView = webViewPart2;
        [navigatorGeolocation assignWebView:webViewPart2];
        bonafideTapObserved = YES; // by definition for 2 part expand a valid tap has occurred
        
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
                isExpanded = true;
                [webViewPart2 loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]]];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rootViewController presentViewController:modalVC animated:NO completion:nil];
        });
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
    
    if (self.shouldHandleInterruptions) {
        [[HyBidInterruptionHandler shared] activateContext:HyBidAdContextMraidView with:self];
    }
    
    if(state == PNLiteMRAIDStateExpanded){
        [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
    }
    
    [self fireSizeChangeEvent];
    self.isViewable = YES;
    
    [self setAutoStoreKitViewTimer];
}

- (void)addSkipOverlay
{
    if (modalVC && modalVC.view ) {
        self.skipOverlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:self->_skipOffset
                                                     withCountdownStyle:HyBidCountdownPieChart
                                         withContentInfoPositionTopLeft:[self isContentInfoInTopLeftPosition]
                                               withShouldShowSkipButton:[self isValidToCreateCustomEndCardForAd:self.ad] ? YES : NO
                                                                     ad:self.ad];
        [self.skipOverlay addSkipOverlayViewIn:modalVC.view delegate:self];
        if (hideCountdownForLandingPage) { [self.skipOverlay setHidden:YES]; }
    }
}

- (void)setWebViewConstraintsInRelationWithView:(UIView *)view
{
    [currentWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (@available(iOS 11.0, *)) {
        
        UILayoutGuide *safeArea = view.safeAreaLayoutGuide;
        [currentWebView.topAnchor constraintEqualToAnchor:safeArea.topAnchor].active = YES;
        [currentWebView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor].active = YES;
        [currentWebView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor].active = YES;
        [currentWebView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor].active = YES;
    } else {
        [currentWebView.topAnchor constraintEqualToAnchor:view.topAnchor].active = YES;
        [currentWebView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor].active = YES;
        [currentWebView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor].active = YES;
        [currentWebView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor].active = YES;
    }

    [currentWebView layoutIfNeeded];
}

- (void)openBrowserForUserClick:(NSString *)urlString {
    [self openBrowserWithURLString:urlString];
}

- (void)open:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.open() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];

    if (!isEndcard) {
        urlFromMraidOpen = urlString;
        [self openBrowserForUserClick:urlString];
        return;
    }
    
    if (!self.creativeAutoStorekitEnabled && !startedFromTap) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to auto click while feature is disabled"];
        return;
    }
    
    // Avoid opening multiple Store ViewControllers
    if ([HyBidSKAdNetworkViewController.shared isSKProductViewControllerPresented]) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to manual/auto click when task is not finished yet"];
        return;
    }
    
    if(tapObserved) {
        HyBidURLRedirector *redirector = [[HyBidURLRedirector alloc] init];
        redirector.delegate = self;
        HyBidSkAdNetworkModel* skanModel = nil;
        if (self.ad && [self.ad getSkAdNetworkModel]) {
            skanModel = [self.ad getSkAdNetworkModel];
        }
        [redirector drillWithUrl:urlString skanModel:skanModel];
        
        // Report Endcard click (DEFAULT_ENDCARD_CLICK)
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK adFormat:isInterstitial ? HyBidReportingAdFormat.FULLSCREEN : HyBidReportingAdFormat.REWARDED properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK
                                                                    ad:self.ad];
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
        [self openBrowserForUserClick:urlString];
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
    if (self.landingpageBehaviour != HyBidLandingBehaviourTypeUnknown && landingPageFlowActive) { return; }
    BOOL isCustomClose = [isCustomCloseString boolValue];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), (isCustomClose ? @"YES" : @"NO")]];
    useCustomClose = isCustomClose;
    obtainedUseCustomCloseValue = YES;
}

- (void)setcustomisation:(NSString *)text {
    if (!self.ad.landingPage) { return; }
    NSString *templateScript = [self convertBase64ToStringWith:text];
    if (!templateScript) { return; }
    self.landingPageTemplateScript = templateScript;
    landingPageFlowActive = YES;
    
    [self playLandingpageTimer];
    useCustomClose = NO;
    hideCountdownForLandingPage = YES;
    self.nativeCloseButtonDelay = [[HyBidSkipOffset alloc] initWithOffset:[[NSNumber alloc] initWithFloat:self.landingpageCloseDelay] isCustom:YES];
    self->_skipOffset = [[NSNumber numberWithFloat:self.landingpageCloseDelay] integerValue];
    [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
}

- (void)landingbehaviour:(NSString *)text {
    
    if (!self.ad.landingPage) { return; }
    NSString *templateLandingBehaviour = [self convertBase64ToStringWith:text];
    if (!templateLandingBehaviour) {
        self.landingpageBehaviour = HyBidLandingBehaviourTypeCountdown;
        return;
    }
    
    hideCountdownForLandingPage = YES;
    HyBidLandingBehaviourType behaviourType = [[[HyBidLandingBehaviour alloc] init] convertStringWithValue:templateLandingBehaviour];
    self.landingpageBehaviour = behaviourType;
    switch (behaviourType) {
        case HyBidLandingBehaviourTypeInstantCloseButton:
            useCustomClose = NO;
            obtainedUseCustomCloseValue = YES;
            [self invalidateCloseButtonOffsetTimer];
            [self pauseLandingpageTimer];
            break;
        case HyBidLandingBehaviourTypeCountdown: {
            useCustomClose = NO;
            obtainedUseCustomCloseValue = YES;
            self.landingpageCloseDelay = self.landingpageCloseDelay ? self.landingpageCloseDelay : landingPageSecondsToCloseAdDelay;
            self->_skipOffset = self.landingpageCloseDelay - self.landingpageTimeElapsed;
            self.landingpageTimeElapsed = 0;
            HyBidSkipOffset *remainingSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:[[NSNumber alloc] initWithFloat:self->_skipOffset] isCustom:YES];
            [self invalidateCloseButtonOffsetTimer];
            [self determineUseCustomCloseBehaviourWith:remainingSkipOffset showSkipOverlay:YES];
            break;
        }
        case HyBidLandingBehaviourTypeNoCountdown:{
            useCustomClose = YES;
            obtainedUseCustomCloseValue = YES;
            break;
        }
        default:
            break;
    }
}

- (void)closedelay:(NSString *)text {
    if (!self.ad.landingPage || self.landingpageBehaviour == HyBidLandingBehaviourTypeInstantCloseButton) { return; }
    NSString *templateDelay = [self convertBase64ToStringWith:text];
    if (!templateDelay) { return; }
    
    hideCountdownForLandingPage = YES;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *milliseconds = [numberFormatter numberFromString:templateDelay];
    float delaySeconds = [milliseconds floatValue] / 1000;
    if (delaySeconds < 0.0) { return; }
    delaySeconds = delaySeconds <= landingPageSecondsToCloseAdDelay ? delaySeconds : landingPageSecondsToCloseAdDelay;
    self.landingpageCloseDelay = delaySeconds;
    
    float remaningSeconds = self.landingpageCloseDelay - self.landingpageTimeElapsed;
    self.landingpageTimeElapsed = 0;
    if (self.landingpageBehaviour == HyBidLandingBehaviourTypeCountdown) {
        self->_skipOffset = [[NSNumber numberWithFloat:remaningSeconds] integerValue];
    } else {
        self.nativeCloseButtonDelay = [[HyBidSkipOffset alloc] initWithOffset:[[NSNumber alloc] initWithFloat:remaningSeconds] isCustom:YES];
        self.closeButtonTimeElapsed = 0;
    }
    [self invalidateCloseButtonOffsetTimer];
    [self.skipOverlay removeFromSuperview];
    self.skipOverlay = nil;
    [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
}

- (void)setFinalPage {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        switch (self.landingpageBehaviour) {
            case HyBidLandingBehaviourTypeInstantCloseButton:
                [self showCloseButtonForLandingPage];
                break;
            case HyBidLandingBehaviourTypeCountdown:{
                float remaningSeconds = self.landingpageCloseDelay - self.landingpageTimeElapsed;
                self.landingpageTimeElapsed = 0;
                self->_skipOffset = [[NSNumber numberWithFloat:remaningSeconds] integerValue];
                [self invalidateCloseButtonOffsetTimer];
                [self.skipOverlay removeFromSuperview];
                self.skipOverlay = nil;
                hideCountdownForLandingPage = NO;
                [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:YES];
                break;
            }
            default:
                break;
        }
    });
}

- (void)showCloseButtonForLandingPage {
    if (!self.ad.landingPage) { return; }
    self.nativeCloseButtonDelay = [[HyBidSkipOffset alloc] initWithOffset:[[NSNumber alloc] initWithInt:0] isCustom:YES];
    [self determineUseCustomCloseBehaviourWith:self.nativeCloseButtonDelay showSkipOverlay:NO];
}

- (NSString *)convertBase64ToStringWith:(NSString *)text {
    if (text == nil || text.length == 0 || [text isEqualToString:@""]) { return nil; }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:text options:0];
    if(data == nil) { return nil; }
    
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(stringData == nil || stringData.length == 0 || [stringData isEqualToString:@""]){ return nil; }
    
    return stringData;
}

- (void)playLandingpageTimer {
    if (!self.landingpageTimer) {
        self.landingpageTimer = [NSTimer scheduledTimerWithTimeInterval: 1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            self.landingpageTimeElapsed += 1;
        }];
    }
}

- (void)pauseLandingpageTimer {
    if (self.landingpageTimer && [self.landingpageTimer isValid]) {
        [self.landingpageTimer invalidate];
        self.landingpageTimer = nil;
    }
}

- (void)setRedirectionUrl:(NSString *)text {
    if ([self hasValidSkanObject] || self.clickThrough) { return; }
    NSString *urlString = [self convertBase64ToStringWith:text];
    if (!urlString || urlString.length == 0) { return; }
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    if (!url || isSkipTimerCompleted) { return; }
    self.clickThrough = url;
    if ([self isValidToCreateCustomEndCardForAd:self.ad]) {
        // Show the skip button only when a valid custom end card is created.
        // This ensures the skip button is displayed appropriately during the redirection flow.
        [self.skipOverlay setShouldShowSkipButton: YES];
    }
}

#pragma mark - JavaScript --> native support helpers

// These methods are helper methods for the ones above.
- (void)addContentInfoViewToView:(UIView *)view {
    
    if (!view || !contentInfoView) { return; }
    
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
        closeButton = [[HyBidCloseButton alloc] initWithRootView:modalVC.view action:@selector(close) target:self ad:self.ad];
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
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:buttonSize.width],
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:buttonSize.height], nil];
    
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
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:modalVC.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]
                ]];
            } else {
                [constraints addObjectsFromArray: @[
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:modalVC.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:modalVC.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]]];
            }
        }
    }
    [NSLayoutConstraint activateConstraints: constraints];
}

- (void)showResizeCloseRegion {
    if (!resizeCloseRegion) {
        resizeCloseRegion = [UIButton buttonWithType:UIButtonTypeCustom];
        resizeCloseRegion.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
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
        if (landingPageFlowActive && [self.closeButtonOffsetTimer isValid]) { return; }
        
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

- (BOOL)isValidToCreateCustomEndCardForAd:(HyBidAd *)ad {
    BOOL hasValidClickThrough = ((self.clickThrough != nil) || [self hasValidSkanObject]);
    if (!isInterstitial ||
        ad.customEndcardEnabled == nil ||
        ad.customEndcardEnabled.boolValue != YES ||
        ad.customEndCardData == nil ||
        ad.customEndCardData.length == 0 ||
        !hasValidClickThrough ||
        ad.landingPage == YES ||
        landingPageFlowActive == YES) {
        return NO;
    }
    return YES;
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
    [self fireExposureChange];
}

- (void)fireExposureChange {
    
    CGFloat updatedExposedPercentage = [self exposedPercent];
    CGRect updatedVisibleRectangle = [self visibleRect];
    
    // Send exposureChange Event only when there is an update from the previous.
    if(exposedPercentage != updatedExposedPercentage || !CGRectEqualToRect(visibleRect,updatedVisibleRectangle)) {
        exposedPercentage = updatedExposedPercentage;
        visibleRect = updatedVisibleRectangle;
        
        NSString* jsonExposureChange = @"";
        if (exposedPercentage <= 0) {
            // If exposure percentage is 0 then send visibleRectangle as null.
            exposedPercentage = 0;
            jsonExposureChange = [NSString stringWithFormat:@"null"];
        } else {
            int offsetX = (visibleRect.origin.x > 0) ? floorf(visibleRect.origin.x) : ceilf(visibleRect.origin.x);
            int offsetY = (visibleRect.origin.y > 0) ? floorf(visibleRect.origin.y) : ceilf(visibleRect.origin.y);
            int width = floorf(visibleRect.size.width);
            int height = floorf(visibleRect.size.height);
            
            jsonExposureChange = [NSString stringWithFormat:@"{\"x\":%i,\"y\":%i,\"width\":%i,\"height\":%i}",offsetX,offsetY,width,height];
        }

        [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireExposureChangeEvent(%0.1f,%@,null);", exposedPercentage, jsonExposureChange]];
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
    CGSize screenSize = self.bounds.size;

    UIWindow *win = self.window ?: UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
    CGFloat topInset = 0, bottomInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = win.safeAreaInsets.top;
        bottomInset = win.safeAreaInsets.bottom;
    }

    // Height that matches visualViewport.height
    CGFloat usableH = screenSize.height - topInset - bottomInset;

    if (!CGSizeEqualToSize(CGSizeMake(screenSize.width, usableH), previousScreenSize)) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setScreenSize(%d,%d);",
                                (int)screenSize.width, (int)usableH]];
        previousScreenSize = CGSizeMake(screenSize.width, usableH);

        if (isInterstitial) {
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setMaxSize(%d,%d);",(int)screenSize.width,(int)usableH]];
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(0,0,%d,%d);",(int)screenSize.width,(int)usableH]];
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
            NSString* formattedLatitude = [[NSString alloc] initWithFormat:@"%.2f", location.coordinate.latitude];
            NSString* formattedLongitude = [[NSString alloc] initWithFormat:@"%.2f", location.coordinate.longitude];
            
            NSArray *objects = [[NSArray alloc] initWithObjects:
                                [NSNumber numberWithDouble:[formattedLatitude floatValue]],
                                [NSNumber numberWithDouble:[formattedLongitude floatValue]],
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
    
    if (landingPageFlowActive && self.landingPageTemplateScript) { [self injectJavaScript:self.landingPageTemplateScript]; }
    
    HyBidMRAIDCommandType command = [[HyBidMRAIDCommand alloc] commandTypeWithText:scheme];
    switch(command){
        case HyBidMRAIDCommandTypeMraid:
            [self parseCommandUrl:absUrlString prefixToRemove:@"mraid://"];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        case HyBidMRAIDCommandTypeVerveAdExperience:
            [self parseCommandUrl:absUrlString prefixToRemove:@"verveadexperience://"];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        case HyBidMRAIDCommandTypeConsoleLog:
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS console: %@",
                                                                                                                              [[absUrlString substringFromIndex:14] stringByRemovingPercentEncoding ]]];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        case HyBidMRAIDCommandTypeUnknown:
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Found URL %@ with type %@", absUrlString, @(navigationAction.navigationType)]];
            
            // Links, Form submissions
            if (navigationAction.navigationType == WKNavigationTypeLinkActivated
                || (navigationAction.navigationType == WKNavigationTypeOther && tapObserved)) {
                tapObserved = NO;
                // For banner views
                if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
                    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS webview load: %@",
                                                                                                                                      [absUrlString stringByRemovingPercentEncoding]]];
                    if ([absUrlString containsString:@"vrvm.com"]
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
                        if (landingPageFlowActive && navigationAction.navigationType == WKNavigationTypeLinkActivated) {
                            if (!firstLinkActiveRedirected) {
                                firstLinkActiveRedirected = YES;
                                if (self.landingPageTemplateScript) {[self injectJavaScript:self.landingPageTemplateScript];}
                                [self setFinalPage];
                                decisionHandler(WKNavigationActionPolicyAllow);
                                return;
                            } else {
                                landingPageFlowActive = NO;
                                self.landingPageTemplateScript = nil;
                                
                                __weak typeof(self) weakSelf = self;
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    [weakSelf showCloseButtonForLandingPage];
                                });
                            }
                        }
                        
                        if (urlFromMraidOpen && [urlFromMraidOpen isEqualToString:absUrlString]) {
                            urlFromMraidOpen = nil;
                        } else {
                            if(!isInterstitial && !bonafideTapObserved){
                                decisionHandler(WKNavigationActionPolicyCancel);
                                return;
                            }
                            
                            if (isExpanded) {
                                isExpanded = NO;
                                decisionHandler(WKNavigationActionPolicyAllow);
                                return;
                            } else {
                                [self.delegate mraidViewNavigate:self withURL:url];
                                decisionHandler(WKNavigationActionPolicyCancel);
                                return;
                            }
                        }
                    }
                }
                // Allow external links
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
                
            } else {
                // Need to let browser to handle rendering and other things
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }
            break;
    }
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

- (BOOL)hasValidSkanObject {
    HyBidSkAdNetworkModel *skanModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    return (skanModel.productParameters[HyBidSKAdNetworkParameter.itunesitem] != nil && [skanModel.productParameters[HyBidSKAdNetworkParameter.itunesitem] isKindOfClass:[NSString class]]);
}

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
    
#if DEBUG
    if (@available(iOS 16.4, *)) {
        [wv setInspectable: YES];
    }
#endif
    
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

- (void)parseCommandUrl:(NSString *)commandUrlString prefixToRemove:(NSString *)prefixToRemove {
    NSDictionary *commandDict = [mraidParser parseCommandUrl:commandUrlString prefixToRemove:prefixToRemove];
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
    bonafideTapObserved = YES;
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

#pragma mark Handling Auto/Manual taps

- (void)doTrackingEndcardWithUrlString:(NSString *)urlString {
    if (self.serviceDelegate != nil && [self.serviceDelegate respondsToSelector:@selector(mraidServiceTrackingEndcardWithUrlString:)]){
        [self.serviceDelegate mraidServiceTrackingEndcardWithUrlString:urlString];
    }
}

- (void)openAppStoreWithAppID:(NSString *)urlString {
    if ([HyBidSKAdNetworkViewController.shared isSKProductViewControllerPresented]) {
        return; // Return early if the Store VC is already being presented
    }
    if ([self.ad.sdkAutoStorekitEnabled boolValue]){
        [self doTrackingEndcardWithUrlString:urlString];
        return;
    }
    
    NSString* appID = [self extractAppIDFromAppStoreURL:urlString];
    if (appID) {
        NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: appID};
        self.isAutoStoreKit = NO;
        [HyBidSKAdNetworkViewController.shared presentStoreKitViewWithProductParameters:parameters adFormat:isInterstitial ? HyBidReportingAdFormat.FULLSCREEN : HyBidReportingAdFormat.BANNER isAutoStoreKitView:self.isAutoStoreKit ad:self.ad];
        self.urlStringForEndCardTracking = urlString;
    } else {
        [self openBrowserWithURLString:urlString];
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

- (void)setAutoStoreKitViewTimer {
    
    if (![HyBidSKAdNetworkViewController isAutoStorekitEnabledForAd:self.ad]) { return; }
    
    if (self.autoStoreKitDelayTimer && [self.autoStoreKitDelayTimer isValid]) {
        [self.autoStoreKitDelayTimer invalidate];
        self.autoStoreKitDelayTimer = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger delay = [HyBidSKAdNetworkViewController getStorekitAutoCloseDelayWithAd:self.ad];
        self.autoStoreKitDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                                       target:self
                                                                     selector:@selector(triggerAutoStorekitView)
                                                                     userInfo:nil
                                                                      repeats:NO];
    });
    self.storekitDelayTimerStartDate = [NSDate date];
    self.storekitDelayTimeElapsed = 0.0;
}

- (void)resumeAutoStorekitViewTimer {
    if (!isInterstitial) { return; }
    
    if (self.storekitDelayTimeElapsed > 0 && self.isTimerPaused) {
        NSTimeInterval remainingTime = [HyBidSKAdNetworkViewController getStorekitAutoCloseDelayWithAd:self.ad] - self.storekitDelayTimeElapsed;
        if (remainingTime > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.autoStoreKitDelayTimer = [NSTimer scheduledTimerWithTimeInterval:remainingTime
                                                                               target:self
                                                                             selector:@selector(triggerAutoStorekitView)
                                                                             userInfo:nil
                                                                              repeats:NO];
            });
            self.storekitDelayTimerStartDate = [NSDate date];
        }
        self.isTimerPaused = NO;
    }
}

- (void)pauseAutoStorekitViewTimer {
    if ([self.autoStoreKitDelayTimer isValid] && !self.isTimerPaused) {
        [self.autoStoreKitDelayTimer invalidate];
        self.autoStoreKitDelayTimer = nil;
        self.storekitDelayTimeElapsed += [[NSDate date] timeIntervalSinceDate:self.storekitDelayTimerStartDate];
        self.isTimerPaused = YES;
    }
}

- (void)triggerAutoStorekitView {
    HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
    
    if (productParams.count == 0) { return; }
    [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
    
    if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
        productParams = [[HyBidStoreKitUtils cleanUpProductParams:productParams] mutableCopy];
        NSLog(@"HyBid SKAN params dictionary: %@", productParams);
        self.isAutoStoreKit = YES;
        [HyBidSKAdNetworkViewController.shared presentStoreKitViewWithProductParameters: productParams
                                                                               adFormat: isInterstitial
                                                                                       ? HyBidReportingAdFormat.FULLSCREEN
                                                                                       : HyBidReportingAdFormat.REWARDED
                                                                     isAutoStoreKitView: self.isAutoStoreKit
                                                                                     ad: self.ad];
    }
}

- (void)removingAutoStoreKitViewTimer {
    if ([self.autoStoreKitDelayTimer isValid]) {
        [self.autoStoreKitDelayTimer invalidate];
    }
    self.autoStoreKitDelayTimer = nil;
}

- (void)trackClickForAutoStoreKitViewWith:(HyBidStorekitAutomaticClickType)clickType {
    HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB
    ? [self.ad getOpenRTBSkAdNetworkModel]
    : [self.ad getSkAdNetworkModel];
    
    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] != [NSNull null] && [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] boolValue]) {
        [self invokeDidClickForAutoStorekit:clickType];
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
        
        NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:self.clickThrough.absoluteString];
        if (!customUrl && skAdNetworkModel) {
            NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
            [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
            if (self.clickThrough.absoluteString && [productParams count] > 0) {
                [[HyBidURLDriller alloc] startDrillWithURLString:self.clickThrough.absoluteString delegate:self];
            }
        }
    }
}

- (void)trackClickForSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType isFirstPresentation:(BOOL)isFirstPresentation {
    HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB
    ? [self.ad getOpenRTBSkAdNetworkModel]
    : [self.ad getSkAdNetworkModel];
    
    [self invokeDidClickForSKOverlayWithClickType:clickType];
    if (isFirstPresentation) {
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    }
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:self.clickThrough.absoluteString];
    if (!customUrl && skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        if (self.clickThrough.absoluteString && [productParams count] > 0) {
            [[HyBidURLDriller alloc] startDrillWithURLString:self.clickThrough.absoluteString delegate:self];
        }
    }
}

- (void)openBrowserWithURLString:(NSString *)urlString {
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) {
        [self.serviceDelegate mraidServiceOpenBrowserWithUrlString:urlString];
    }
}

- (void)invokeDidClickForAutoStorekit:(HyBidStorekitAutomaticClickType)clickType {
    if ([self.delegate respondsToSelector:@selector(mraidViewAutoStoreKitDidShowWithClickType:)]) {
        [self.delegate mraidViewAutoStoreKitDidShowWithClickType:clickType];
    }
}

- (void)invokeDidPresentCustomEndCard {
    if ([self.delegate respondsToSelector:@selector(mraidViewDidPresentCustomEndCard:)]) {
        [self.delegate mraidViewDidPresentCustomEndCard:self];
    }
}

- (void)invokeDidClickForSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType {
    if ([self.delegate respondsToSelector:@selector(mraidViewDidShowSKOverlayWithClickType:)]) {
        [self.delegate mraidViewDidShowSKOverlayWithClickType:clickType];
    }
}

#pragma mark HyBidURLRedirectorDelegate

- (void)onURLRedirectorFailWithUrl:(NSString * _Nonnull)url withError:(NSError * _Nonnull)error {
    tapObserved = NO;
    startedFromTap = NO;
    [self openBrowserWithURLString:url];
}

- (void)onURLRedirectorFinishWithUrl:(NSString * _Nonnull)url {
    tapObserved = NO;
    [self open:url];
}

- (void)onURLRedirectorRedirectWithUrl:(NSString * _Nonnull)url {
    
}

- (void)onURLRedirectorStartWithUrl:(NSString * _Nonnull)url {
    
}

#pragma mark HyBidInterruptionDelegate

- (void)adHasFocus {
    if (modalVC != nil) {
        [self playCountdownView];
        [self playCloseButtonDelay];
        [self resumeAutoStorekitViewTimer];
    }
}

- (void)adHasNoFocus {
    if (modalVC != nil) {
        [self pauseCountdownView];
        [self pauseCloseButtonDelay];
        [self pauseAutoStorekitViewTimer];
    }
}

- (void)feedbackViewWillShow {
    self.willShowFeedbackScreen = YES;
}

- (void)productViewControllerDidShow {
    [self doTrackingEndcardWithUrlString:self.urlStringForEndCardTracking];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"StoreKit from CREATIVE is presented"]];
    
    if (self.isAutoStoreKit) {
        [self trackClickForAutoStoreKitViewWith:HyBidStorekitAutomaticClickVideo];
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.AUTO_STORE_KIT_IMPRESSION
                                                                    ad:self.ad
                                                               onTopOf:HyBidOnTopOfTypeDISPLAY];
    }
}

- (void)productViewControllerDidFailWithError:(NSError *)error {
    if (self.isAutoStoreKit) {
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.AUTO_STORE_KIT_IMPRESSION_ERROR ad:self.ad onTopOf:HyBidOnTopOfTypeDISPLAY errorCode: error.code];
    }
}

#pragma mark HyBidEndCardViewDelegate

- (void)endCardViewDidDisplay {
    [self invokeDidPresentCustomEndCard];
    [self removingAutoStoreKitViewTimer];
}
- (void)endCardViewCloseButtonTapped {
    [self close];
}

- (void)endCardViewFailedToLoad {
    [contentInfoViewContainer setHidden: NO];
    if(self.endCardView != nil) {
        [self.endCardView removeFromSuperview];
    }
    [self addCloseEventRegion];
}

- (void)endCardViewClicked:(BOOL)triggerAdClick aakCustomClickAd:(HyBidAdAttributionCustomClickAdsWrapper *)aakCustomClickAd {
    if(triggerAdClick){
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    }
    
    [self openBrowserForUserClick:self.clickThrough.absoluteString];
}
- (void)endCardViewSKOverlayClicked:(BOOL)triggerAdClick
                              clickType:(HyBidSKOverlayAutomaticCLickType)clickType
                    isFirstPresentation:(BOOL)isFirstPresentation {
    if (triggerAdClick) {
        [self trackClickForSKOverlayWithClickType:clickType isFirstPresentation:isFirstPresentation];
    } else {
        [self invokeDidClickForSKOverlayWithClickType:clickType];
    }
}

- (void)endCardViewAutoStorekitClicked:(BOOL)triggerAdClick clickType:(HyBidStorekitAutomaticClickType)clickType {
    if(triggerAdClick){
        [self trackClickForAutoStoreKitViewWith:clickType];
    } else {
        [self invokeDidClickForAutoStorekit:clickType];
    }
}

- (void)endCardViewRedirectedWithSuccess:(BOOL)success {}

#pragma mark - HyBidSKOverlayDelegate

- (void)skOverlayDidShowOnCreative:(BOOL)isFirstPresentation {
    HyBidSkAdNetworkModel* skAdNetworkModel = [self.ad getSkAdNetworkModel];
    if (!isInterstitial || [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] == [NSNull null] || ![[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] boolValue]) { return; }
    
    [self trackClickForSKOverlayWithClickType: HyBidSKOverlayAutomaticCLickVideo isFirstPresentation:isFirstPresentation];
}

@end
