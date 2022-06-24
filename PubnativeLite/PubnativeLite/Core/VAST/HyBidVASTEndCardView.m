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
#import <WebKit/WebKit.h>

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#define kCloseButtonSize 26
#define kContentInfoContainerTag 2343

@interface HyBidVASTEndCardView () <HyBidMRAIDViewDelegate, HyBidMRAIDServiceDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *endCardImageView;

@property (nonatomic, strong) HyBidMRAIDView *mraidView;

@property (nonatomic, strong) HyBidMRAIDServiceProvider *serviceProvider;

@property (nonatomic, weak) NSObject<HyBidVASTEndCardViewControllerDelegate> *delegate;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) HyBidVASTEndCard *endCard;

@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;

@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, assign) BOOL isInterstitial;

@end

@implementation HyBidVASTEndCardView

- (instancetype)initWithDelegate:(NSObject<HyBidVASTEndCardViewControllerDelegate> *)delegate withViewController: (UIViewController*) viewController isInterstitial: (BOOL) isInterstitial
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.rootViewController = viewController;
        self.isInterstitial = isInterstitial;
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
        [self setFrame: self.rootViewController.view.bounds];
    }
    return self;
}

- (void)setupUI
{
    if (!self.isInterstitial) {return;}
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [[HyBidSettings sharedInstance].endCardCloseOffset integerValue] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addCloseButton];
    });
}

- (void)addCloseButton {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.backgroundColor = [UIColor clearColor];
    [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
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
}

- (void)close
{
    [self.rootViewController dismissViewControllerAnimated:NO completion:^{
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_close];
        [self.delegate vastEndCardCloseButtonTapped];
    }];
}

- (void)displayEndCard:(HyBidVASTEndCard *)endCard withViewController:(UIViewController*) viewController
{
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

- (void)displayContentInfoContainer
{
    for (UIView* subview in self.rootViewController.view.subviews) {
        if (subview.tag == kContentInfoContainerTag) {
            [self.rootViewController.view bringSubviewToFront:subview];
        }
    }
}

- (void)displayMRAIDWithContent:(NSString *)content withBaseURL:(NSURL *)baseURL
{
    [self.endCardImageView removeFromSuperview];
    self.endCardImageView = nil;
    self.serviceProvider = [[HyBidMRAIDServiceProvider alloc] init];
    
    self.mraidView = [[HyBidMRAIDView alloc]
            initWithFrame:CGRectMake(0, 0, self.rootViewController.view.frame.size.width +1, self.rootViewController.view.frame.size.height +1)
            withHtmlData:content
            withBaseURL:baseURL
            supportedFeatures:@[PNLiteMRAIDSupportsSMS, PNLiteMRAIDSupportsTel, PNLiteMRAIDSupportsStorePicture, PNLiteMRAIDSupportsInlineVideo, PNLiteMRAIDSupportsLocation]
            isInterstital:NO
            delegate:self
            serviceDelegate:self
            rootViewController:self.rootViewController
            contentInfo:nil
            skipOffset:[HyBidSettings sharedInstance].endCardCloseOffset.integerValue];
    
    for (UIView *view in [self.mraidView subviews]) {
        if ([view isKindOfClass:[WKWebView self]]) {
            [self addTapRecognizerToView:view];
        }
    }
}

- (void)displayImageViewWithURL:(NSString *)url withView:(UIView *)view
{
    [self.mraidView removeFromSuperview];
    self.mraidView = nil;
    
    [self downloadImageWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded && image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.endCardImageView = [[UIImageView alloc] initWithFrame: self.bounds];
                self.endCardImageView.backgroundColor = UIColor.blackColor;
                [self.endCardImageView setUserInteractionEnabled: YES];
                [self addTapRecognizerToView:self.endCardImageView];
                [self.endCardImageView setImage:image];
                [self.endCardImageView setContentMode:UIViewContentModeScaleAspectFit];
                [view addSubview:self.endCardImageView];
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_creativeView];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayContentInfoContainer];
        });
    }];
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
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
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
    self.mraidView.center = CGPointMake(self.frame.size.width  / 2,
                                self.frame.size.height / 2);
    self.mraidView = mraidView;
    [self addSubview:mraidView];
    [self displayContentInfoContainer];

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
