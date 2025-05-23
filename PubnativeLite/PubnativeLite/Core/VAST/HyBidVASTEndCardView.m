// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteMRAIDUtil.h"
#import "HyBidVASTEndCardView.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBid.h"
#import "HyBidVASTEndCardCloseIcon.h"
#import "HyBidURLDriller.h"
#import "HyBidSKAdNetworkViewController.h"
#import "UIApplication+PNLiteTopViewController.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HyBidCloseButton.h"
#import "HyBidSKAdNetworkParameter.h"
#import "HyBidCustomClickUtil.h"
#import "HyBidStoreKitUtils.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kContentInfoContainerTag 2343
#define STOREKIT_DELAY_MAXIMUM_VALUE 10
#define STOREKIT_DELAY_MINIMUM_VALUE 0
#define STOREKIT_DELAY_DEFAULT_VALUE 2

@interface HyBidVASTEndCardView () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, UIGestureRecognizerDelegate, WKNavigationDelegate, HyBidVASTEventProcessorDelegate, HyBidURLDrillerDelegate, SKStoreProductViewControllerDelegate, HyBidInternalWebBrowserDelegate>

@property (nonatomic, strong) UIImageView *endCardImageView;

@property (nonatomic, strong) HyBidMRAIDView *mraidView;

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;

@property (nonatomic, weak) NSObject<HyBidVASTEndCardViewDelegate> *delegate;

@property (nonatomic, strong) HyBidCloseButton *closeButton;

@property (nonatomic, strong) HyBidVASTEndCard *endCard;

@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;

@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, assign) BOOL isInterstitial;

@property (nonatomic, strong) NSTimer *closeButtonTimer;
@property (nonatomic, strong) NSDate *closeButtonTimerStartDate;
@property (nonatomic, assign) NSTimeInterval closeButtonTimeElapsed;

@property (nonatomic, strong) WKWebView *ctaWebView;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *companionView;
@property (nonatomic, strong) HyBidVASTCTAButton *ctaButton;

@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *verticalConstraints;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *horizontalConstraints;

@property (nonatomic, strong) HyBidSkipOffset *endCardCloseDelay;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) HyBidVASTAd *vastAd;

@property (nonatomic, assign) NSString * iconXposition;
@property (nonatomic, assign) NSString * iconYposition;

@property (nonatomic, assign) BOOL shouldTriggerAdClick;

@property (nonatomic, assign) BOOL withSkipButton;
@property (nonatomic, strong) NSString *throughClickURL;
@property (nonatomic, strong) NSString *appID;
@property (nonatomic, assign) BOOL showStorekitEnabled;
@property (nonatomic, assign) BOOL sdkAutoStorekitEnabled;
@property (nonatomic, assign) NSInteger sdkAutoStorekitDelay;
@property (nonatomic, assign) BOOL isFallbackDisplay;
@property (nonatomic, assign) BOOL isExtensionDisplay;
@property (nonatomic, assign) BOOL shouldOpenBrowser;
@property (nonatomic, assign) BOOL shouldResumeTimer;
@property (nonatomic, assign) BOOL isTimerPaused;

@property (nonatomic, assign) NSInteger delayTimeRemaining;
@property (nonatomic, assign) BOOL storekitPageIsPresented;
@property (nonatomic, assign) BOOL storekitPageIsBeingPresented;
@property (nonatomic, assign) BOOL isFeedbackScreenPresented;
@property (nonatomic, assign) BOOL isInternalWebBrowserVisible;
@property (nonatomic, strong) NSTimer *delayTimer;
@property (nonatomic, strong) NSDate *storekitDelayTimerStartDate;
@property (nonatomic, assign) NSTimeInterval storekitDelayTimeElapsed;
@property (nonatomic, strong) NSArray<NSString *> *vastCompanionsClicksThrough;
@property (nonatomic, strong) NSArray<NSString *> *vastCompanionsClicksTracking;
@property (nonatomic, strong) NSArray<NSString *> *vastVideoClicksTracking;
@property (nonatomic, assign) BOOL isAutoStoreKit;
@end

@implementation HyBidVASTEndCardView

NSString * adClickTriggerFlag = @"https://customendcard.verve.com/click";

- (instancetype)initWithDelegate:(NSObject<HyBidVASTEndCardViewDelegate> *)delegate
              withViewController:(UIViewController *)viewController
                          withAd:(HyBidAd *)ad
                      withVASTAd:(HyBidVASTAd *)vastAd
                  isInterstitial:(BOOL)isInterstitial
                   iconXposition:(NSString *)iconXposition
                   iconYposition:(NSString *)iconYposition
                  withSkipButton:(BOOL)withSkipButton
     vastCompanionsClicksThrough:(NSArray<NSString *>*)vastCompanionsClicksThrough
    vastCompanionsClicksTracking:(NSArray<NSString *>*)vastCompanionsClicksTracking
         vastVideoClicksTracking:(NSArray<NSString *>*)vastVideoClicksTracking {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.rootViewController = viewController;
        [self determineEndCardCloseDelayForAd:ad];
        self.ad = ad;
        self.ad.isEndcard = YES;
        self.vastAd = vastAd;
        self.iconXposition = iconXposition;
        self.iconYposition = iconYposition;
        self.isInterstitial = isInterstitial;
        self.withSkipButton = withSkipButton;
        self.vastCompanionsClicksThrough = vastCompanionsClicksThrough;
        self.vastCompanionsClicksTracking = vastCompanionsClicksTracking;
        self.vastVideoClicksTracking = vastVideoClicksTracking;
        self.shouldOpenBrowser = NO;
        self.storekitPageIsPresented = NO;
        self.storekitPageIsBeingPresented = NO;
        [self determineSdkAutoStorekitEnabledForAd:ad];
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
        [self setFrame: self.rootViewController.view.bounds];
        
        self.horizontalConstraints = [NSMutableArray new];
        self.verticalConstraints = [NSMutableArray new];
                
        [self obtainContentInfoFromSuperView:self.rootViewController.view completionHandler:^(UIView * _Nullable contentInfoView) {
            if (contentInfoView) {
                [contentInfoView setHidden:YES];
            }
        }];

        [self addObservers];
    }
    return self;
}

- (void)determineEndCardCloseDelayForAd:(HyBidAd *)ad {
    NSNumber *skipOffset = ad.endcardCloseDelay;
    if (skipOffset && [skipOffset doubleValue] >= 0) {
        self.endCardCloseDelay = [[HyBidSkipOffset alloc] initWithOffset:skipOffset isCustom:YES];
    } else {
        self.endCardCloseDelay = HyBidConstants.endCardCloseOffset;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self setHorizontalConstraints];
    } else {
        [self setVerticalConstraints];
    }
}

- (void)addHorizontalConstraintsInRelationToView:(UIView *)view
{
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    if (self.ctaButton != nil) {
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeWidth multiplier:0.7 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    } else {
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    }
}

- (void)addVerticalConstraintsInRelationToView:(UIView *)view
{
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    if (self.ctaButton != nil) {
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0]];
    } else {
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
}

- (void)setVerticalConstraints
{
    [NSLayoutConstraint deactivateConstraints:self.horizontalConstraints];
    [NSLayoutConstraint activateConstraints:self.verticalConstraints];
    
    [self.mainView layoutIfNeeded];
    [self.companionView layoutIfNeeded];
}

- (void)setHorizontalConstraints
{
    [NSLayoutConstraint deactivateConstraints:self.verticalConstraints];
    [NSLayoutConstraint activateConstraints:self.horizontalConstraints];
    
    [self.mainView layoutSubviews];
    [self.companionView layoutSubviews];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationWillResignActive:)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(feedbackScreenDidShow)
                               notificationType:HyBidNotificationTypeAdFeedbackViewDidShow
                                         object:nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(feedbackScreenIsDismissed)
                               notificationType:HyBidNotificationTypeAdFeedbackViewIsDismissed
                                         object:nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(skStoreProductViewIsPresented)
                               notificationType:HyBidNotificationTypeSKStoreProductViewIsShown
                                         object:nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(skStoreProductViewIsDismissed)
                               notificationType:HyBidNotificationTypeSKStoreProductViewIsDismissed
                                         object:nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(handleSKStoreProductViewIsShown:)
                               notificationType:HyBidNotificationTypeSKStoreProductViewIsShown
                                         object:nil];
    
    [HyBidNotificationCenter.shared addObserver:self
                                       selector:@selector(handleSKStoreProductViewIsDismissed:)
                               notificationType:HyBidNotificationTypeSKStoreProductViewIsDismissedFromVideo
                                         object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!self.isFeedbackScreenPresented && !self.isInternalWebBrowserVisible && !self.storekitPageIsBeingPresented) {
        [self resumeCloseButtonTimer];
    }
    
    if (self.shouldResumeTimer && self.storekitPageIsBeingPresented == NO &&
        !self.isFeedbackScreenPresented && !self.isInternalWebBrowserVisible) {
        [self resumeStorekitDelayTimer];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self pauseCloseButtonTimer];
    [self pauseStorekitDelayTimer];
}

- (void)resumeCloseButtonTimer {
    if (!self.isInterstitial) { return; }
    
    if (self.closeButtonTimeElapsed != -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.closeButtonTimer = [NSTimer scheduledTimerWithTimeInterval:([self.endCardCloseDelay.offset integerValue] - self.closeButtonTimeElapsed) target:self selector:@selector(addCloseButton) userInfo:nil repeats:NO];
        });
        
        self.closeButtonTimerStartDate = [NSDate date];
    }
}

- (void)resumeStorekitDelayTimer {
    if (!self.isInterstitial) { return; }

    if (self.storekitDelayTimeElapsed > 0 && self.isTimerPaused) {
        NSTimeInterval remainingTime = self.sdkAutoStorekitDelay - self.storekitDelayTimeElapsed;
        if (remainingTime > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:remainingTime target:self selector:@selector(triggerShowStorekitPage) userInfo:nil repeats:NO];
            });
            self.storekitDelayTimerStartDate = [NSDate date];
        }
        self.isTimerPaused = NO;
    }
}

- (void)pauseCloseButtonTimer {
    if ([self.closeButtonTimer isValid]) {
        [self.closeButtonTimer invalidate];
        self.closeButtonTimer = nil;
        self.closeButtonTimeElapsed = [[NSDate date] timeIntervalSinceDate:self.closeButtonTimerStartDate];
    }
}

- (void)pauseStorekitDelayTimer {
    if ([self.delayTimer isValid] && !self.isTimerPaused) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
        self.storekitDelayTimeElapsed += [[NSDate date] timeIntervalSinceDate:self.storekitDelayTimerStartDate];
        self.isTimerPaused = YES;
    }
}

- (void)handleSKStoreProductViewIsShown:(NSNotification *)notification {
    NSNumber *isShownNumber = notification.object;
    self.storekitPageIsBeingPresented = [isShownNumber boolValue];
}

- (void)handleSKStoreProductViewIsDismissed:(NSNotification *)notification {
    NSNumber *isDismissedNumber = notification.object;
    self.storekitPageIsBeingPresented = ![isDismissedNumber boolValue];
}

- (void)setupUI
{
    if (!self.isInterstitial) { return; }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButtonTimer = [NSTimer scheduledTimerWithTimeInterval:self.endCardCloseDelay.offset.integerValue target:self selector:@selector(addCloseButton) userInfo:nil repeats:NO];
    });
    
    self.closeButtonTimerStartDate = [NSDate date];
    self.closeButtonTimeElapsed = 0.0;
}

- (BOOL)isContentInfoInTopLeftPosition {
    BOOL isLeftPosition = [self.iconXposition isEqualToString: @"left"] ? YES : NO;
    BOOL isTopPosition = [self.iconYposition isEqualToString: @"top"] ? YES : NO;
    
    return isLeftPosition && isTopPosition ? YES : NO;
}

- (void)addCloseButton {
    [self.closeButtonTimer invalidate];
    self.closeButtonTimer = nil;
    self.closeButtonTimeElapsed = -1;
        
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton = [[HyBidCloseButton alloc] initWithRootView:self.rootViewController.view action:@selector(close) target:self showSkipButton:self.withSkipButton ad:self.ad];
        if([self isContentInfoInTopLeftPosition]){
            if (@available(iOS 11.0, *)) {
                [NSLayoutConstraint activateConstraints:@[
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]
                ]];
            } else {
                [NSLayoutConstraint activateConstraints:@[
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]
                ]];
            }
        } else {
            if (@available(iOS 11.0, *)) {
                [NSLayoutConstraint activateConstraints:@[
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]
                ]];
            } else {
                [NSLayoutConstraint activateConstraints:@[
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                    [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.rootViewController.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]
                ]];
            }
        }
        
        [self.rootViewController.view bringSubviewToFront:self.closeButton];
    });
}

- (void)close
{
    if (!self.withSkipButton) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.rootViewController dismissViewControllerAnimated:NO completion:^{
            [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_close];
            [self.delegate vastEndCardViewCloseButtonTapped];
            if (!self.endCard.isCustomEndCard) {
                if ([HyBidSDKConfig sharedConfig].reporting) {
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.DEFAULT_ENDCARD_CLOSE adFormat:nil properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
                }
                
                [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_CLOSE
                                                                            ad:self.ad];
            } else {
                if ([HyBidSDKConfig sharedConfig].reporting) {
                    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CUSTOM_ENDCARD_CLOSE adFormat:nil properties:nil];
                    [[HyBid reportingManager] reportEventFor:reportingEvent];
                }
                
                [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.CUSTOM_ENDCARD_CLOSE
                                                                            ad:self.ad];
            }
        }];
    } else {
        if (self.closeButton != nil) {
            [self.closeButton removeFromSuperview];
        }
        if (!self.endCard.isCustomEndCard) {
            if ([HyBidSDKConfig sharedConfig].reporting) {
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.DEFAULT_ENDCARD_SKIP adFormat:nil properties:nil];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
            }
            
            [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_SKIP
                                                                        ad:self.ad];
        }
        [self.delegate vastEndCardViewSkipButtonTapped];
    }
    if (self.delayTimer) {
        self.storekitDelayTimeElapsed = 0;
        self.shouldResumeTimer = NO;
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }
}

- (void)displayEndCard:(HyBidVASTEndCard *)endCard withCTAButton:(HyBidVASTCTAButton *)ctaButton withViewController:(UIViewController*) viewController
{
    self.ctaButton = ctaButton;
    [self displayEndCard:endCard withViewController:viewController];
    
    if (ctaButton != nil) {
        [self configureCTAWebViewWith:ctaButton];
    }
}

- (void)displayEndCard:(HyBidVASTEndCard *)endCard withViewController:(UIViewController*) viewController
{
    UIView *contentView = viewController.view;
    [contentView layoutIfNeeded];
    
    self.mainView = [[UIView alloc] init];
    self.mainView.backgroundColor = endCard.isCustomEndCard ? [UIColor clearColor] : [UIColor blackColor];
    self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.mainView];
    
    if (self.ctaButton != nil) {
        self.companionView = [[UIView alloc] init];
        self.companionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.companionView];
    }
    
    [self addVerticalConstraintsInRelationToView:self];
    [self addHorizontalConstraintsInRelationToView:self];
        
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [self setHorizontalConstraints];
    } else {
        [self setVerticalConstraints];
    }
    self.endCard = endCard;
    if (self.endCard.events == nil) {
        [self.vastEventProcessor setCustomEvents:[[endCard events] events]];
    }
    if (self.sdkAutoStorekitEnabled) {
        [self determineSdkAutoStorekitBehaviourForAd:self.ad];
        [self setStorekitAutoCloseDelay:self.ad];
    }
    if ([endCard type] == HyBidEndCardType_STATIC) {
        [self addTapRecognizerToView:self.mainView];
        [self displayImageViewWithURL:[endCard content] withView:viewController.view];
    } else if ([endCard type] == HyBidEndCardType_IFRAME) {
        [self displayMRAIDWithContent:@"" withBaseURL:[[NSURL alloc] initWithString:[endCard content]]];
    } else if ([endCard type] == HyBidEndCardType_HTML) {
        [self displayMRAIDWithContent:[endCard content] withBaseURL:nil];
    }
    // Start monitoring device orientation so we can reset max Size and screenSize if needed.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self trackEndCardImpression];
    [self.delegate vastEndCardViewDidDisplay];
}

- (void)configureCTAWebViewWith:(HyBidVASTCTAButton *)ctaButton
{
    if (ctaButton != nil) {
        self.ctaWebView = [[WKWebView alloc] init];
        [self.ctaWebView setOpaque:NO];
        [self.ctaWebView setBackgroundColor:[UIColor clearColor]];
        [self.ctaWebView.scrollView setBackgroundColor:[UIColor clearColor]];
        
        [self.ctaWebView setNavigationDelegate:self];
        [self.ctaWebView loadHTMLString:[ctaButton htmlData] baseURL:nil];
        
        if ([self.ctaWebView respondsToSelector:@selector(scrollView)]) {
            UIScrollView *scrollView = [self.ctaWebView scrollView];
            scrollView.scrollEnabled = NO;
        }
        
        NSString *js = @"var metaTag=document.createElement('meta');"
        "metaTag.name = \"viewport\";"
        "metaTag.content = \"user-scalable=0\";"
        "document.getElementsByTagName('head')[0].appendChild(metaTag);";
        
        NSString *css = @"var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);";
        
        NSString *source = [[NSString alloc] initWithFormat:@"%@%@", js, css];
        
        WKUserScript *userScript = [[WKUserScript alloc]
                                    initWithSource:source
                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                    forMainFrameOnly:YES];
        [self.ctaWebView.configuration.userContentController addUserScript:userScript];
        
        [self.companionView addSubview:self.ctaWebView];
        [self setCtaWebViewConstraints];
    }
}

- (void)displayContentInfoContainer
{
    [self obtainContentInfoFromSuperView:self.rootViewController.view completionHandler:^(UIView * _Nullable contentInfoView) {
        if (contentInfoView) {
            [self addingConstrainstForDynamicPosition: contentInfoView iconXposition: self.iconXposition iconYposition: self.iconYposition];
            [contentInfoView setHidden: NO];
        }
    }];
}

- (void)obtainContentInfoFromSuperView:(UIView *) superview completionHandler:(void (^)(UIView * _Nullable contentInfoView)) completionHandler {
    if (self.endCard.isCustomEndCard) {
        return completionHandler(nil);
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %d", kContentInfoContainerTag];
    NSArray<UIView *> *subviews = [superview.subviews filteredArrayUsingPredicate:predicate];
    completionHandler(subviews.firstObject);
}

- (void)setViewsOrderRelativeToView:(UIView *)view
{
    [view bringSubviewToFront:self.mainView];
    [view bringSubviewToFront:self.companionView];
    [view bringSubviewToFront:self.closeButton];
    [self displayContentInfoContainer];
}

- (void)addingConstrainstForDynamicPosition:(UIView *) contentInfoViewContainer iconXposition:(NSString *) iconXposition iconYposition:(NSString *) iconYposition {
    
    if (!contentInfoViewContainer) { return; }
    [contentInfoViewContainer removeFromSuperview];
    [self addSubview:contentInfoViewContainer];
    
    contentInfoViewContainer.translatesAutoresizingMaskIntoConstraints = false;
    
    [[contentInfoViewContainer.widthAnchor constraintEqualToConstant: contentInfoViewContainer.frame.size.width] setActive: YES];
    [[contentInfoViewContainer.heightAnchor constraintEqualToConstant: contentInfoViewContainer.frame.size.height] setActive: YES];
    
    if([iconXposition isEqualToString: @"right"]){
        if (@available(iOS 11.0, *)) {
            [[contentInfoViewContainer.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor] setActive: YES];
        } else {
            [[contentInfoViewContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive: YES];
        }
    } else {
        if (@available(iOS 11.0, *)) {
            [[contentInfoViewContainer.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor] setActive: YES];
        } else {
            [[contentInfoViewContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive: YES];
        }
    }

    if([iconYposition isEqualToString: @"bottom"]){
        if (@available(iOS 11.0, *)) {
            [[contentInfoViewContainer.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor] setActive: YES];
        } else {
            [[contentInfoViewContainer.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive: YES];
        }
    } else {
        if (@available(iOS 11.0, *)) {
            [[contentInfoViewContainer.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor] setActive: YES];
        } else {
            [[contentInfoViewContainer.topAnchor constraintEqualToAnchor:self.topAnchor] setActive: YES];
        }
    }
}

- (void)displayMRAIDWithContent:(NSString *)content withBaseURL:(NSURL *)baseURL
{
    [self.endCardImageView removeFromSuperview];
    self.endCardImageView = nil;
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    
    self.mraidView = [[HyBidMRAIDView alloc] initWithFrame:self.mainView.frame
                                              withHtmlData:content
                                               withBaseURL:baseURL
                                                    withAd:self.ad
                                         supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
                                             isInterstital:self.isInterstitial
                                              isScrollable:NO
                                                  delegate:self
                                           serviceDelegate:self
                                        rootViewController:self.rootViewController
                                               contentInfo:nil
                                                skipOffset:self.endCardCloseDelay.offset.integerValue
                                                 isEndcard:YES];
}

- (void)displayImageViewWithURL:(NSString *)url withView:(UIView *)view
{
    [self.mraidView removeFromSuperview];
    self.mraidView = nil;
    
    [self downloadImageWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded && image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.endCardImageView = [[UIImageView alloc] init];
                [self.endCardImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
                
                self.endCardImageView.backgroundColor = UIColor.blackColor;
                [self.endCardImageView setImage:image];
                [self.endCardImageView setContentMode:UIViewContentModeScaleAspectFit];
                [self.mainView addSubview:self.endCardImageView];
                
                [self setImageViewConstraints];
                [self presentSdkAutoStorekitPage];
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
            });
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setupUI];
            [weakSelf setViewsOrderRelativeToView:view];
        });
    }];
}

- (void)setMRAIDConstraints
{
    [self.mraidView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.mraidView.topAnchor constraintEqualToAnchor:self.mainView.topAnchor] setActive:YES];
    [[self.mraidView.bottomAnchor constraintEqualToAnchor:self.mainView.bottomAnchor] setActive:YES];
    [[self.mraidView.leadingAnchor constraintEqualToAnchor:self.mainView.leadingAnchor] setActive:YES];
    [[self.mraidView.trailingAnchor constraintEqualToAnchor:self.mainView.trailingAnchor] setActive:YES];
}

- (void)setImageViewConstraints
{
    [self.endCardImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.endCardImageView.topAnchor constraintEqualToAnchor:self.mainView.topAnchor] setActive:YES];
    [[self.endCardImageView.bottomAnchor constraintEqualToAnchor:self.mainView.bottomAnchor] setActive:YES];
    [[self.endCardImageView.leadingAnchor constraintEqualToAnchor:self.mainView.leadingAnchor] setActive:YES];
    [[self.endCardImageView.trailingAnchor constraintEqualToAnchor:self.mainView.trailingAnchor] setActive:YES];
}

- (void)setCtaWebViewConstraints
{
    [self.ctaWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self.ctaWebView.topAnchor constraintEqualToAnchor:self.companionView.topAnchor] setActive:YES];
    [[self.ctaWebView.bottomAnchor constraintEqualToAnchor:self.companionView.bottomAnchor] setActive:YES];
    [[self.ctaWebView.leadingAnchor constraintEqualToAnchor:self.companionView.leadingAnchor] setActive:YES];
    [[self.ctaWebView.trailingAnchor constraintEqualToAnchor:self.companionView.trailingAnchor] setActive:YES];
}

- (void)addTapRecognizerToView:(UIView *)view
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vastEndCardViewClicked)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    
    [view addGestureRecognizer:tapRecognizer];
}

- (void)vastEndCardViewClicked
{
    [self vastEndCardClickedWithType:[self.endCard type] withURL:nil withShouldOpenBrowser:YES];
    [self trackEndCardClick];
    [self.delegate vastEndCardViewClicked: self.shouldTriggerAdClick];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.endCardImageView = nil;
    self.mraidView = nil;
    self.serviceProvider = nil;
    self.delegate = nil;
    self.closeButton = nil;
    self.endCard = nil;
    self.vastEventProcessor = nil;
    self.rootViewController = nil;
    self.endCardCloseDelay = nil;
    self.showStorekitEnabled = nil;
    self.sdkAutoStorekitEnabled = nil;
    self.isFallbackDisplay = nil;
    self.isExtensionDisplay = nil;
    self.shouldOpenBrowser = nil;
    self.storekitDelayTimeElapsed = 0;
    self.vastCompanionsClicksThrough = nil;
    self.vastCompanionsClicksTracking = nil;
    self.vastVideoClicksTracking = nil;
}

// MARK: - Helper methods

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          if (!error) {
              UIImage *image = [[UIImage alloc] initWithData:data];
              completionBlock(YES,image);
          } else {
              if ([HyBidSDKConfig sharedConfig].reporting) {
                  HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                  [[HyBid reportingManager] reportEventFor:reportingEvent];
              }
              
              [[HyBidVASTEventBeaconsManager shared]
               reportVASTEventWithType: self.endCard.isCustomEndCard
               ? HyBidReportingEventType.CUSTOM_ENDCARD_IMPRESSION_ERROR
               : HyBidReportingEventType.DEFAULT_ENDCARD_IMPRESSION_ERROR
               ad:self.ad
               errorCode:error.code];
              completionBlock(NO,nil);
          }
      }] resume];
}

#pragma mark HyBidMRAIDViewDelegate

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    @synchronized (self) {
        if (!self.isInterstitial) {return;}
        CGSize screenSize = self.mainView.frame.size;
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
        if (self.mraidView != nil) {
            self.mraidView.center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        }
        if (self.endCardImageView != nil) {
            self.endCardImageView.frame = CGRectMake(self.endCardImageView.frame.origin.x, self.endCardImageView.frame.origin.y, screenSize.width, screenSize.height);
        }
    }
}

- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID did load."];
    self.mraidView.center = CGPointMake(self.mainView.frame.size.width  / 2,
                                self.mainView.frame.size.height / 2);
    self.mraidView = mraidView;
    [self.mainView addSubview:self.mraidView];
    [self setupUI];
    [self setMRAIDConstraints];
    [self.companionView addSubview:self.ctaWebView];
    
    [self setViewsOrderRelativeToView:self.rootViewController.view];

    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
    
    [self.mraidView setIsViewable:YES];
    [self presentSdkAutoStorekitPage];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView withError:(NSError *)error {
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType: self.endCard.isCustomEndCard
                                                                  ? HyBidReportingEventType.CUSTOM_ENDCARD_IMPRESSION_ERROR
                                                                  : HyBidReportingEventType.DEFAULT_ENDCARD_IMPRESSION_ERROR
                                                                ad:self.ad
                                                         errorCode:error.code];
    [self mraidViewAdFailed:mraidView];
}
- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID View failed."];
    [self.delegate vastEndCardViewFailedToLoad];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID will expand."];
}

- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID did close."];    
    [self close];
}

- (void)vastEndCardClickedWithType:(HyBidVASTEndCardType)endCardType withURL:(NSString *)url withShouldOpenBrowser:(BOOL)shouldOpenBrowser {
    if (self.vastAd == nil || self.shouldTriggerAdClick) {
        if ([[self.endCard clickTrackings] count] > 0) {
            [self.vastEventProcessor sendVASTUrls:[self.endCard clickTrackings] withType:HyBidVASTClickTrackingURL];
        }
        return;
    }
    
    if (self.sdkAutoStorekitEnabled && self.sdkAutoStorekitDelay > 0){
        [self pauseStorekitDelayTimer];
    }
    
    NSDictionary *trackersDictionary = [self gettingTrackingAndThroughClickURLWith:endCardType];
    NSMutableArray<NSString *> *trackingClickURLs = [trackersDictionary objectForKey: @"trackingClickURLs"];
    NSString *throughClickURL = [trackersDictionary objectForKey: @"throughClickURL"];
    
    if (trackingClickURLs && [trackingClickURLs count] > 0) {
        [self.vastEventProcessor sendVASTUrls:trackingClickURLs withType:HyBidVASTClickTrackingURL];
    }
    
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    
    HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:throughClickURL];
    if (customUrl != nil) {
        [self navigationToURL:customUrl shouldOpenBrowser:shouldOpenBrowser navigationType:HyBidWebBrowserNavigationExternalValue];
    } else if (skAdNetworkModel) {
        NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
        
        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            if(endCardType == HyBidEndCardType_STATIC) {
                if (throughClickURL != nil) {
                    [[HyBidURLDriller alloc] startDrillWithURLString:throughClickURL delegate:self];
                }
            } else {
                [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            }
            
            if(shouldOpenBrowser) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters: [HyBidStoreKitUtils cleanUpProductParams:productParams] delegate: self];
                    self.storekitPageIsBeingPresented = YES;
                    [skAdnetworkViewController presentSKStoreProductViewController:^(BOOL success) {
                        
                    }];
                });
            }

        } else {
            if(endCardType == HyBidEndCardType_STATIC) {
                if (throughClickURL != nil) {
                    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:throughClickURL]];
                    if(!canOpenURL){
                        throughClickURL = [throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
                    }
                    [self navigationToURL:throughClickURL shouldOpenBrowser:shouldOpenBrowser navigationType:self.ad.navigationMode];
                }
            } else {
                [self determineIfAdClickIsTriggeredWithURL:url withShouldOpenBrowser:shouldOpenBrowser];
            }
        }
    } else {
        if(endCardType == HyBidEndCardType_STATIC) {
            if (throughClickURL != nil) {
                BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:throughClickURL]];
                if(!canOpenURL){
                    throughClickURL = [throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
                }
                [self navigationToURL:throughClickURL shouldOpenBrowser:shouldOpenBrowser navigationType:self.ad.navigationMode];
            }
        } else {
            [self determineIfAdClickIsTriggeredWithURL:url withShouldOpenBrowser:shouldOpenBrowser];
        }
    }
}

- (void)navigationToURL:(NSString *)url shouldOpenBrowser:(BOOL)shouldOpenBrowser navigationType:(NSString *)navigationType {
    
    HyBidWebBrowserNavigation navigation = [HyBidInternalWebBrowserNavigationController.shared webBrowserNavigationBehaviourFromString: navigationType];
    
    if (navigation == HyBidWebBrowserNavigationInternal) {
        [HyBidInternalWebBrowserNavigationController.shared navigateToURL:url delegate:self];
    } else {
        if(shouldOpenBrowser) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                [self.delegate vastEndCardViewRedirectedWithSuccess:success];
            }];
        }
    }
}

- (NSDictionary*)gettingTrackingAndThroughClickURLWith:(HyBidVASTEndCardType)endCardType {
    NSArray<HyBidVASTCreative *> *creatives = [[self.vastAd inLine] creatives];
    NSMutableArray<HyBidVASTVideoClicks *> *videoClicks = [NSMutableArray new];
    HyBidVASTCompanionAds *companionAds;
    NSString *throughClickURL;
    
    if ([[self.endCard clickThrough] length] > 0) {
        throughClickURL = [self.endCard clickThrough];
    }
    
    NSMutableArray<NSString *> *trackingClickURLs = [[NSMutableArray alloc] init];
    
    for (HyBidVASTCreative *creative in creatives) {
        if ([creative companionAds] != nil) {
            companionAds = [creative companionAds];
            for (HyBidVASTCompanion *companion in [companionAds companions]) {
                NSString *clickThrough = [[companion companionClickThrough] content];
                if ([clickThrough length] != 0){
                    throughClickURL = [[companion companionClickThrough] content];
                }
            }
        }
        if ([creative linear] != nil && [[creative linear] videoClicks] != nil) {
            HyBidVASTLinear* linear = [creative linear];
            HyBidVASTVideoClicks* videoClicksObject = [linear videoClicks];
            [videoClicks addObject:[[creative linear] videoClicks]];
            
            if([[videoClicksObject clickThrough] content] != nil && [throughClickURL length] == 0) {
                throughClickURL = [[videoClicksObject clickThrough] content];
            }
        }
    }
    
    NSMutableArray<NSString*> *companionClicksThroughOfLastInline = [NSMutableArray new];
    for (HyBidVASTCreative *creative in creatives) {
        if ([creative companionAds] != nil) {
            companionAds = [creative companionAds];
            for (HyBidVASTCompanion *companion in [companionAds companions]) {
                NSString *clickThrough = [[companion companionClickThrough] content];
                if (clickThrough && [clickThrough length] != 0){
                    [companionClicksThroughOfLastInline addObject: clickThrough];
                }
            }
        }
    }
    
    
    NSString *lastCompanionClickThrough = companionClicksThroughOfLastInline.count == 0
                                        ? self.vastCompanionsClicksThrough.lastObject
                                        : companionClicksThroughOfLastInline.firstObject;
    if (lastCompanionClickThrough && lastCompanionClickThrough.length != 0) {
        throughClickURL = lastCompanionClickThrough;
    }
    
    if (self.vastVideoClicksTracking && self.vastVideoClicksTracking.count > 0) {
        [trackingClickURLs addObjectsFromArray: [[self.vastVideoClicksTracking reverseObjectEnumerator] allObjects]];
    }
    
    if (self.vastCompanionsClicksTracking && self.vastCompanionsClicksTracking.count > 0) {
        [trackingClickURLs addObjectsFromArray: [[self.vastCompanionsClicksTracking reverseObjectEnumerator] allObjects]];
    }
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    if (trackingClickURLs) { values[@"trackingClickURLs"] = trackingClickURLs; }
    if (throughClickURL) { values[@"throughClickURL"] = throughClickURL; }
    
    return values;
}

- (NSDictionary*)gettingTrackingAndThroughClickURLForAutoStorekit:(HyBidVASTEndCardType)endCardType {
    NSArray<HyBidVASTCreative *> *creatives = [[self.vastAd inLine] creatives];
    NSMutableArray<HyBidVASTVideoClicks *> *videoClicks = [NSMutableArray new];
    NSMutableArray<NSString *> *trackingClickURLs = [[NSMutableArray alloc] init];
    NSString *throughClickURL;
    
    for (HyBidVASTCreative *creative in creatives) {
        if ([creative linear] != nil && [[creative linear] videoClicks] != nil) {
            HyBidVASTLinear* linear = [creative linear];
            HyBidVASTVideoClicks* videoClicksObject = [linear videoClicks];
            [videoClicks addObject:[[creative linear] videoClicks]];
            
            if([[videoClicksObject clickThrough] content]) {
                throughClickURL = [[videoClicksObject clickThrough] content];
            }
        }
    }
    
    if (self.vastVideoClicksTracking && self.vastVideoClicksTracking.count > 0) {
        [trackingClickURLs addObjectsFromArray: [[self.vastVideoClicksTracking reverseObjectEnumerator] allObjects]];
    }
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    if (trackingClickURLs) { values[@"trackingClickURLs"] = trackingClickURLs; }
    if (throughClickURL) { values[@"throughClickURL"] = throughClickURL; }
    
    return values;
}

- (HyBidCustomEndcardDisplayBehaviour)customEndcardDisplayBehaviourFromString:(NSString *)customEndcardDisplayBehaviour {
    if([customEndcardDisplayBehaviour isKindOfClass:[NSString class]]) {
        if ([customEndcardDisplayBehaviour isEqualToString:HyBidCustomEndcardDisplayFallbackValue]) {
            return HyBidCustomEndcardDisplayFallback;
        } else if ([customEndcardDisplayBehaviour isEqualToString:HyBidCustomEndcardDisplayExtentionValue]) {
            return HyBidCustomEndcardDisplayExtention;
        } else {
            return HyBidCustomEndcardDisplayFallback;
        }
    } else {
        return HyBidCustomEndcardDisplayFallback;
    }
}

- (void)determineSdkAutoStorekitEnabledForAd:(HyBidAd *)ad {
    if (ad.sdkAutoStorekitEnabled != nil && [ad.sdkAutoStorekitEnabled integerValue] >= 0 && [ad.sdkAutoStorekitEnabled boolValue] == YES) {
        self.sdkAutoStorekitEnabled = YES;
    } else {
        self.sdkAutoStorekitEnabled = HyBidConstants.sdkAutoStorekitEnabled;
    }
}

- (void)determineSdkAutoStorekitBehaviourForAd:(HyBidAd *)ad {
    self.showStorekitEnabled = NO;
    ad.hasCustomEndCard = NO;

    self.isFallbackDisplay = ([self customEndcardDisplayBehaviourFromString:ad.customEndcardDisplay] == HyBidCustomEndcardDisplayFallback);
    self.isExtensionDisplay = ([self customEndcardDisplayBehaviourFromString:ad.customEndcardDisplay] == HyBidCustomEndcardDisplayExtention);
    BOOL isCustomEndcardEnabled = [ad.customEndcardEnabled boolValue] ? [ad.customEndcardEnabled boolValue] : HyBidConstants.showCustomEndCard;
    BOOL isEndcardEnabled = [ad.endcardEnabled boolValue] ? [ad.endcardEnabled boolValue] : HyBidConstants.showEndCard;

    if (isEndcardEnabled) {
        if ([ad.customEndcardEnabled boolValue] && self.isExtensionDisplay) {
            self.showStorekitEnabled = self.sdkAutoStorekitEnabled;
            ad.hasCustomEndCard = self.sdkAutoStorekitEnabled;
        } else if (!isCustomEndcardEnabled || self.isFallbackDisplay) {
            self.showStorekitEnabled = self.sdkAutoStorekitEnabled;
        }
    } else if (isCustomEndcardEnabled) {
        self.showStorekitEnabled = self.sdkAutoStorekitEnabled;
        ad.hasCustomEndCard = self.sdkAutoStorekitEnabled;
    }
}

- (void)determineStorekitDelayOffsetAndBehaviour {
    if (self.delayTimer && [self.delayTimer isValid]) {
        [self.delayTimer invalidate];
        self.delayTimer = nil;
    }
    
    if (self.sdkAutoStorekitDelay > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:self.sdkAutoStorekitDelay target:self selector:@selector(triggerShowStorekitPage) userInfo:nil repeats:NO];
        });
        self.storekitDelayTimerStartDate = [NSDate date];
        self.storekitDelayTimeElapsed = 0.0;
        self.shouldResumeTimer = YES;
    }
}

- (void)setStorekitAutoCloseDelay:(HyBidAd *)ad {
    id sdkAutoStorekitDelay = ad.sdkAutoStorekitDelay;
    if (sdkAutoStorekitDelay != nil && [sdkAutoStorekitDelay isKindOfClass:[NSString class]]) {
        NSString *delayString = (NSString *)sdkAutoStorekitDelay;

        NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

        if ([delayString rangeOfCharacterFromSet:nonDigitCharacterSet].location == NSNotFound) {
            self.sdkAutoStorekitDelay = [delayString integerValue];
        } else {
            self.sdkAutoStorekitDelay = STOREKIT_DELAY_DEFAULT_VALUE;
        }
    } else if ([sdkAutoStorekitDelay isKindOfClass:[NSNumber class]]) {
        self.sdkAutoStorekitDelay = [sdkAutoStorekitDelay integerValue];
        if (self.sdkAutoStorekitDelay > STOREKIT_DELAY_MAXIMUM_VALUE) {
            self.sdkAutoStorekitDelay = STOREKIT_DELAY_MAXIMUM_VALUE;
        } else if (self.sdkAutoStorekitDelay < STOREKIT_DELAY_MINIMUM_VALUE) {
            self.sdkAutoStorekitDelay = STOREKIT_DELAY_DEFAULT_VALUE;
        }
    } else {
        self.sdkAutoStorekitDelay = STOREKIT_DELAY_DEFAULT_VALUE;
    }
}

- (void)triggerShowStorekitPage {
    self.delayTimer = nil;
    self.storekitDelayTimeElapsed = 0;

    if (!self.storekitPageIsPresented) {
        [self showStorekitPage:[self.endCard type] withURL:nil withShouldOpenBrowser:YES];
        self.storekitPageIsPresented = YES;
    }
}

- (void)presentSdkAutoStorekitPage {
    if (self.showStorekitEnabled && self.isInterstitial) {
        if(self.endCard.isCustomEndCard && self.isExtensionDisplay) {
            self.shouldOpenBrowser = YES;
            if (self.sdkAutoStorekitDelay > 0) {
                [self determineStorekitDelayOffsetAndBehaviour];
            } else {
                [self showStorekitPage:[self.endCard type] withURL:nil withShouldOpenBrowser:YES];
            }
        } else if (![self.ad.customEndcardEnabled boolValue] || self.isFallbackDisplay) {
            self.shouldOpenBrowser = YES;
            if (self.sdkAutoStorekitDelay > 0) {
                [self determineStorekitDelayOffsetAndBehaviour];
            } else {
                [self showStorekitPage:[self.endCard type] withURL:nil withShouldOpenBrowser:YES];
            }
        }
        self.isAutoStoreKit = YES;
    }
}

- (void)showStorekitPage:(HyBidVASTEndCardType)endCardType withURL:(NSString *)url withShouldOpenBrowser:(BOOL)shouldOpenBrowser {
    HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
    NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
    NSString *throughClickURL;
    if ([[self.endCard clickThrough] length] > 0) {
        throughClickURL = [self.endCard clickThrough];
    }
    
    NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:self.throughClickURL];
    if (customUrl != nil) {
        [self navigationToURL:customUrl shouldOpenBrowser:shouldOpenBrowser navigationType:HyBidWebBrowserNavigationExternalValue];
    } else if (productParams.count != 0) {
        
        [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams]) {
            if(endCardType == HyBidEndCardType_STATIC) {
                if (self.throughClickURL != nil) {
                    [[HyBidURLDriller alloc] startDrillWithURLString:self.throughClickURL delegate:self];
                }
            } else {
                [[HyBidURLDriller alloc] startDrillWithURLString:url delegate:self];
            }
            
            if(shouldOpenBrowser) {
                if(!self.storekitPageIsBeingPresented) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters: [HyBidStoreKitUtils cleanUpProductParams:productParams] delegate: self];
                        self.storekitPageIsBeingPresented = YES;
                        [HyBidNotificationCenter.shared post: HyBidNotificationTypeSKStoreProductViewIsReadyToPresentForSDKStorekit object: nil userInfo: nil];
                        [skAdnetworkViewController presentSKStoreProductViewControllerWithBlock:^(BOOL success, NSError *error) {
                            if (success) {
                                if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] != [NSNull null] && [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] boolValue]){
                                    [self fireClicksForAutoStorekit];
                                }
                                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"StoreKit from SDK is presented"]];
                                
                                if (self.isAutoStoreKit) {
                                    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.AUTO_STORE_KIT_IMPRESSION
                                                                                                ad:self.ad
                                                                                           onTopOf:self.endCard.isCustomEndCard
                                                                                                  ? HyBidOnTopOfTypeCUSTOM_ENDCARD
                                                                                                  : HyBidOnTopOfTypeCOMPANION_AD];
                                    self.isAutoStoreKit = NO;
                                }
                            } else {
                                if (self.isAutoStoreKit) {
                                    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.AUTO_STORE_KIT_IMPRESSION_ERROR
                                                                                                ad:self.ad
                                                                                           onTopOf:self.endCard.isCustomEndCard
                                                                                                  ? HyBidOnTopOfTypeCUSTOM_ENDCARD
                                                                                                  : HyBidOnTopOfTypeCOMPANION_AD
                                                                                         errorCode:error.code];
                                    self.isAutoStoreKit = NO;
                                }
                            }
                        }];
                    });
                }
            }
        } else {
            if(endCardType == HyBidEndCardType_STATIC) {
                if (self.throughClickURL != nil) {
                    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.throughClickURL]];
                    if(!canOpenURL){
                        self.throughClickURL = [self.throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
                    }
                    [self navigationToURL:self.throughClickURL shouldOpenBrowser:shouldOpenBrowser navigationType:self.ad.navigationMode];
                }
            } else {
                [self determineIfAdClickIsTriggeredWithURL:url withShouldOpenBrowser:shouldOpenBrowser];
            }
        }
    } else {
        if(endCardType == HyBidEndCardType_STATIC) {
            if (self.throughClickURL != nil) {
                BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.throughClickURL]];
                if(!canOpenURL){
                    self.throughClickURL = [self.throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
                }
                [self navigationToURL:self.throughClickURL shouldOpenBrowser:shouldOpenBrowser navigationType:self.ad.navigationMode];
            }
        } else {
            [self determineIfAdClickIsTriggeredWithURL:url withShouldOpenBrowser:shouldOpenBrowser];
        }
    }
}

- (void)trackEndCardImpression {
    if (!self.endCard.isCustomEndCard && [HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.DEFAULT_ENDCARD_IMPRESSION adFormat: self.isInterstitial ? HyBidReportingAdFormat.FULLSCREEN : HyBidReportingAdFormat.REWARDED properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:self.endCard.isCustomEndCard
                                                                  ? HyBidReportingEventType.CUSTOM_ENDCARD_IMPRESSION
                                                                  : HyBidReportingEventType.DEFAULT_ENDCARD_IMPRESSION
                                                                ad:self.ad];
}

- (void)trackEndCardClick {
    if (!self.endCard.isCustomEndCard) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK adFormat:self.isInterstitial ? HyBidReportingAdFormat.FULLSCREEN : HyBidReportingAdFormat.REWARDED properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK
                                                                    ad:self.ad];
        return;
    }
}

- (void)fireClicksForAutoStorekit {
    HyBidSkAdNetworkModel* skAdNetworkModel = [self.ad getSkAdNetworkModel];
    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] != [NSNull null] && [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] boolValue]) {
        
        self.shouldTriggerAdClick = [self.endCard.content containsString: adClickTriggerFlag] ? YES : NO;
        if (self.vastAd == nil || self.shouldTriggerAdClick) {
            if ([[self.endCard clickTrackings] count] > 0) {
                [self.vastEventProcessor sendVASTUrls:[self.endCard clickTrackings] withType:HyBidVASTClickTrackingURL];
            }
        } else {
            HyBidVASTEndCardType endCardType = [self.endCard type];
            NSDictionary *trackersDictionary = [self gettingTrackingAndThroughClickURLForAutoStorekit:endCardType];
            NSMutableArray<NSString *> *trackingClickURLs = [trackersDictionary objectForKey: @"trackingClickURLs"];
            NSString *throughClickURL = [trackersDictionary objectForKey: @"throughClickURL"];
            
            if (trackingClickURLs && [trackingClickURLs count] > 0) {
                [self.vastEventProcessor sendVASTUrls:trackingClickURLs withType:HyBidVASTClickTrackingURL];
            }
            
            [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
            
            HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
            
            NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:throughClickURL];
            if (!customUrl && skAdNetworkModel) {
                NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
                
                [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
                if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams] && throughClickURL) {
                    [[HyBidURLDriller alloc] startDrillWithURLString:throughClickURL delegate:self];
                }
            }
        }
        [self.delegate vastEndCardViewAutoStorekitClicked: self.shouldTriggerAdClick clickType: self.endCard.isCustomEndCard
         ? HyBidStorekitAutomaticClickCustomEndCard : HyBidStorekitAutomaticClickDefaultEndCard ];
    }
}

- (void)determineIfAdClickIsTriggeredWithURL:(NSString *)url withShouldOpenBrowser:(BOOL)shouldOpenBrowser {
    if(!self.shouldTriggerAdClick){
        HyBidWebBrowserNavigation navigation = [HyBidInternalWebBrowserNavigationController.shared webBrowserNavigationBehaviourFromString: self.ad.navigationMode];
        
        if (navigation == HyBidWebBrowserNavigationInternal) {
            [HyBidInternalWebBrowserNavigationController.shared navigateToURL:url delegate:self];
        } else {
            if (shouldOpenBrowser) {
                [self.serviceProvider openBrowser:url];
            }
        }
    }
}

- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url {
    if([url.absoluteString containsString: adClickTriggerFlag]){
        self.shouldTriggerAdClick = YES;
    } else {
        self.shouldTriggerAdClick = NO;
    }
    [self vastEndCardClickedWithType:[self.endCard type] withURL:url.absoluteString withShouldOpenBrowser:YES];
    [self trackEndCardClick];
    [self.delegate vastEndCardViewClicked:self.shouldTriggerAdClick];
}

- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen {
    return allowOffscreen;
}

#pragma mark WkNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([navigationAction navigationType] == WKNavigationTypeLinkActivated) {        
        [webView evaluateJavaScript:@"document.getElementsByTagName('html')[0].innerHTML" completionHandler:^(id innerHTML, NSError *error) {
            NSString *regexExp = @"(?<=<a href=\").*?(?=\")";
            NSError *regexError = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexExp options:NSRegularExpressionCaseInsensitive error:&regexError];
            NSTextCheckingResult *match = [regex firstMatchInString:innerHTML options:0 range: NSMakeRange(0, [innerHTML length])];
            
            if ([match numberOfRanges] > 0) {
                NSString *foundUrlString = [innerHTML substringWithRange:[match rangeAtIndex:0]];
                
                if (foundUrlString != nil && webView == self.ctaWebView) {
                    if (self.ctaButton != nil && [[[self.ctaButton trackingEvents] events] count] > 0) {
                        HyBidVASTEventProcessor *ctaEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEvents:[[self.ctaButton trackingEvents] events] delegate:self];
                        [ctaEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_ctaClick];
                    }
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:foundUrlString] options:@{} completionHandler:nil];
                }

            }
        }];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

#pragma mark HyBidVASTEventProcessorDelegate

- (void)eventProcessorDidTrackEventType:(HyBidVASTAdTrackingEventType)event {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Event tracked: %ld", (long)event]];
}

#pragma mark HyBidMRAIDServiceDelegate

- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString {
    [self.serviceProvider callNumber:urlString];
}

- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString {
    [self.serviceProvider sendSMS:urlString];
}

- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString {
    [self vastEndCardClickedWithType:[self.endCard type] withURL:urlString withShouldOpenBrowser:YES];
    [self.delegate vastEndCardViewClicked: self.shouldTriggerAdClick];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

- (void)mraidServiceTrackingEndcardWithUrlString:(NSString *)urlString {
    [self vastEndCardClickedWithType:[self.endCard type] withURL:urlString withShouldOpenBrowser:self.shouldOpenBrowser];
    [self.delegate vastEndCardViewClicked: self.shouldTriggerAdClick];
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.STOREKIT_PRODUCT_VIEW_DISMISS adFormat:self.isInterstitial ? HyBidReportingAdFormat.FULLSCREEN : HyBidReportingAdFormat.REWARDED properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    [HyBidNotificationCenter.shared post: HyBidNotificationTypeSKStoreProductViewIsDismissed object: self.ad userInfo: nil];
    self.storekitPageIsBeingPresented = NO;
    if (!self.isFeedbackScreenPresented) {
        [self resumeStorekitDelayTimer];
    }
}

#pragma mark HyBidSKOverlayDelegate

- (void)skoverlayDidShowOnCreative {
    if (!self.storekitPageIsBeingPresented) {
    HyBidSkAdNetworkModel* skAdNetworkModel = [self.ad getSkAdNetworkModel];
        if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] != [NSNull null] && [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.click] boolValue]) {
            
            self.shouldTriggerAdClick = [self.endCard.content containsString: adClickTriggerFlag] ? YES : NO;
            if (self.vastAd == nil || self.shouldTriggerAdClick) {
                if ([[self.endCard clickTrackings] count] > 0) {
                    [self.vastEventProcessor sendVASTUrls:[self.endCard clickTrackings] withType:HyBidVASTClickTrackingURL];
                }
            } else {
                HyBidVASTEndCardType endCardType = [self.endCard type];
                NSDictionary *trackersDictionary = [self gettingTrackingAndThroughClickURLWith:endCardType];
                NSMutableArray<NSString *> *trackingClickURLs = [trackersDictionary objectForKey: @"trackingClickURLs"];
                NSString *throughClickURL = [trackersDictionary objectForKey: @"throughClickURL"];
                
                if (trackingClickURLs && [trackingClickURLs count] > 0) {
                    [self.vastEventProcessor sendVASTUrls:trackingClickURLs withType:HyBidVASTClickTrackingURL];
                }
                
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
                
                HyBidSkAdNetworkModel *skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
                
                NSString *customUrl = [HyBidCustomClickUtil extractPNClickUrl:throughClickURL];
                if (!customUrl && skAdNetworkModel) {
                    NSMutableDictionary* productParams = [[skAdNetworkModel getStoreKitParameters] mutableCopy];
                    
                    [HyBidStoreKitUtils insertFidelitiesIntoDictionaryIfNeeded:productParams];
                    if ([productParams count] > 0 && [skAdNetworkModel isSKAdNetworkIDVisible:productParams] && throughClickURL) {
                        [[HyBidURLDriller alloc] startDrillWithURLString:throughClickURL delegate:self];
                    }
                }
            }
            
            [self.delegate vastEndCardViewSKOverlayClicked: self.shouldTriggerAdClick
                                                 clickType: self.endCard.isCustomEndCard
             ? HyBidSKOverlayAutomaticCLickCustomEndCard
                                                          : HyBidSKOverlayAutomaticCLickDefaultEndCard];
        }
    }
}

#pragma mark - HyBidCustomCTAViewDelegate

- (void)customCTADidLoadWithSuccess:(BOOL)success{}

- (void)customCTADidShow {
    if ([self.delegate respondsToSelector:@selector(vastEndCardViewCustomCTAClicked)]) {
        [self.delegate vastEndCardViewCustomCTAPresented];
    }
}

- (void)customCTADidClick {
    if ([self.delegate respondsToSelector:@selector(vastEndCardViewCustomCTAClicked)]) {
        [self.delegate vastEndCardViewCustomCTAClicked];
    }
}

#pragma mark - HyBidSKAdNetworkViewController

- (void)skStoreProductViewIsPresented {
    [self pauseCloseButtonTimer];
    [self pauseStorekitDelayTimer];
}

- (void)skStoreProductViewIsDismissed {
    if (!self.isFeedbackScreenPresented) {
        [self resumeCloseButtonTimer];
    }
    
    if (self.shouldResumeTimer && self.storekitPageIsBeingPresented == NO && !self.isFeedbackScreenPresented) {
        [self resumeStorekitDelayTimer];
    }
}

#pragma mark - HyBidInternalWebBrowserDelegate

- (void)internalWebBrowserDidShow {
    [self setIsInternalWebBrowserVisible:YES];
    [self pauseCloseButtonTimer];
    [self pauseStorekitDelayTimer];
}

- (void)internalWebBrowserDidDismiss {
    [self setIsInternalWebBrowserVisible:NO];
    if (!self.isFeedbackScreenPresented) {
        [self resumeCloseButtonTimer];
    }
    
    if (self.shouldResumeTimer && self.storekitPageIsBeingPresented == NO && !self.isFeedbackScreenPresented) {
        [self resumeStorekitDelayTimer];
    }
}

- (void)internalWebBrowserDidFail {
    if (!self.isFeedbackScreenPresented) {
        [self resumeCloseButtonTimer];
    }
    
    if (self.shouldResumeTimer && self.storekitPageIsBeingPresented == NO && !self.isFeedbackScreenPresented) {
        [self resumeStorekitDelayTimer];
    }
}

#pragma mark - HyBidAdFeedbackView

- (void)feedbackScreenDidShow {
    self.isFeedbackScreenPresented = YES;
    [self pauseCloseButtonTimer];
    [self pauseStorekitDelayTimer];
}

- (void)feedbackScreenIsDismissed {
    self.isFeedbackScreenPresented = NO;
    if (!self.storekitPageIsBeingPresented && !self.isInternalWebBrowserVisible) {
        [self resumeCloseButtonTimer];
    }
    
    if (self.shouldResumeTimer && self.storekitPageIsBeingPresented == NO && !self.isInternalWebBrowserVisible) {
        [self resumeStorekitDelayTimer];
    }
}

@end
