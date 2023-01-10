//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "PNLiteMRAIDUtil.h"
#import "HyBidVASTEndCardView.h"
#import "HyBidMRAIDServiceProvider.h"
#import "HyBid.h"
#import "HyBidVASTEndCardCloseIcon.h"

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kCloseButtonSize 26
#define kContentInfoContainerTag 2343

@interface HyBidVASTEndCardView () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, UIGestureRecognizerDelegate, WKNavigationDelegate, HyBidVASTEventProcessorDelegate>

@property (nonatomic, strong) UIImageView *endCardImageView;

@property (nonatomic, strong) HyBidMRAIDView *mraidView;

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;

@property (nonatomic, weak) NSObject<HyBidVASTEndCardViewControllerDelegate> *delegate;

@property (nonatomic, strong) UIButton *closeButton;

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

@end

@implementation HyBidVASTEndCardView

- (instancetype)initWithDelegate:(NSObject<HyBidVASTEndCardViewControllerDelegate> *)delegate withViewController:(UIViewController *)viewController withAd:(HyBidAd *)ad isInterstitial:(BOOL)isInterstitial {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.rootViewController = viewController;
        [self determineEndCardCloseDelayForAd:ad];
        self.isInterstitial = isInterstitial;
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
        [self setFrame: self.rootViewController.view.bounds];
        
        self.horizontalConstraints = [NSMutableArray new];
        self.verticalConstraints = [NSMutableArray new];
        
        [self addObservers];
    }
    return self;
}

- (void)determineEndCardCloseDelayForAd:(HyBidAd *)ad {
    if (ad.endcardCloseDelay) {
        self.endCardCloseDelay = [[HyBidSkipOffset alloc] initWithOffset:ad.endcardCloseDelay isCustom:YES];
    } else {
        self.endCardCloseDelay = [HyBidRenderingConfig sharedConfig].endCardCloseOffset;
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
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    if (self.ctaButton != nil) {
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:0.7 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    } else {
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    }
}

- (void)addVerticalConstraintsInRelationToView:(UIView *)view
{
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    if (self.ctaButton != nil) {
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.mainView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:0.2 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.companionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:0.8 constant:0]];
    } else {
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.verticalConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
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
                                             selector: @selector(applicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeCloseButtonTimer)
                                                 name:@"adFeedbackViewIsDismissed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseCloseButtonTimer)
                                                 name:@"adFeedbackViewIsShown"
                                               object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    [self resumeCloseButtonTimer];
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

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    [self pauseCloseButtonTimer];
}

- (void)pauseCloseButtonTimer {
    if ([self.closeButtonTimer isValid]) {
        [self.closeButtonTimer invalidate];
        self.closeButtonTimer = nil;
        self.closeButtonTimeElapsed = [[NSDate date] timeIntervalSinceDate:self.closeButtonTimerStartDate];
    }
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

- (void)addCloseButton {
    [self.closeButtonTimer invalidate];
    self.closeButtonTimer = nil;
    self.closeButtonTimeElapsed = -1;
        
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.backgroundColor = [UIColor clearColor];
        [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setAccessibilityIdentifier:@"closeButton"];
        [self.closeButton setAccessibilityLabel:@"Close Button"];
        
        // get button image from header file
        NSData* buttonData = [NSData dataWithBytesNoCopy:__HyBidVASTEndCard_CloseButton_png
                                                  length:__HyBidVASTEndCard_CloseButton_png_len
                                            freeWhenDone:NO];
        UIImage *closeButtonImage = [UIImage imageWithData:buttonData];
        [self.closeButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
        [self.rootViewController.view addSubview:self.closeButton];
        
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseButtonSize],
            [NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseButtonSize]
        ]];
        
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
        [self.rootViewController.view bringSubviewToFront:self.closeButton];
    });
}

- (void)close
{
    [self.rootViewController dismissViewControllerAnimated:NO completion:^{
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_close];
        [self.delegate vastEndCardCloseButtonTapped];
    }];
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
    self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.mainView];
    [self addTapRecognizerToView:self.mainView];
    
    if (self.ctaButton != nil) {
        self.companionView = [[UIView alloc] init];
        self.companionView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:self.companionView];
    }
    
    [self addVerticalConstraintsInRelationToView:contentView];
    [self addHorizontalConstraintsInRelationToView:contentView];
        
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [self setHorizontalConstraints];
    } else {
        [self setVerticalConstraints];
    }
    
    self.endCard = endCard;
    [self.vastEventProcessor setCustomEvents:[[endCard events] events]];
    if ([endCard type] == HyBidEndCardType_STATIC) {
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
    for (UIView* subview in self.rootViewController.view.subviews) {
        if (subview.tag == kContentInfoContainerTag) {
            [self.rootViewController.view bringSubviewToFront:subview];
        }
    }
}

- (void)setViewsOrderRelativeToView:(UIView *)view
{
    [view bringSubviewToFront:self.mainView];
    [view bringSubviewToFront:self.companionView];
    [view bringSubviewToFront:self.closeButton];
    [self displayContentInfoContainer];
}

- (void)displayMRAIDWithContent:(NSString *)content withBaseURL:(NSURL *)baseURL
{
    [self.endCardImageView removeFromSuperview];
    self.endCardImageView = nil;
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    
    self.mraidView = [[HyBidMRAIDView alloc]
            initWithFrame:self.mainView.frame
            withHtmlData:content
            withBaseURL:baseURL
            supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
            isInterstital:NO
            isScrollable:NO
            delegate:self
            serviceDelegate:self
            rootViewController:self.rootViewController
            contentInfo:nil
            skipOffset:self.endCardCloseDelay.offset.integerValue];
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
                [self setViewsOrderRelativeToView:view];
                                
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
            });
        }
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
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vastEndCardTapped)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    
    [view addGestureRecognizer:tapRecognizer];
}

- (void)vastEndCardTapped
{
    if ([[self.endCard clickTrackings] count] > 0) {
        [self.vastEventProcessor sendVASTUrls:[self.endCard clickTrackings]];
    }
    [self.delegate vastEndCardTapped];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)dealloc
{
    self.endCardImageView = nil;
    self.mraidView = nil;
    self.serviceProvider = nil;
    self.delegate = nil;
    self.closeButton = nil;
    self.endCard = nil;
    self.vastEventProcessor = nil;
    self.rootViewController = nil;
    self.endCardCloseDelay = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.mainView addSubview:mraidView];
    [self setMRAIDConstraints];
    [self.companionView addSubview:self.ctaWebView];
    
    [self setViewsOrderRelativeToView:self.rootViewController.view];

    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
}

- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID View failed."];
}

- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID will expand."];
}

- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"MRAID did close."];

    if (self.mraidView) {
        [self.mraidView stopAdSession];
    }
    
    [self close];
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
    [self.serviceProvider openBrowser:urlString];
}

- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString {
    [self.serviceProvider playVideo:urlString];
}

- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString {
    [self.serviceProvider storePicture:urlString];
}

@end
