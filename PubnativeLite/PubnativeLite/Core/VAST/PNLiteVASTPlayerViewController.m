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

#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVASTParser.h"
#import "HyBidVASTTrackingEvents.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTMediaFilePicker.h"
#import "PNLiteProgressLabel.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidViewabilityNativeVideoAdSession.h"
#import <OMSDK_Pubnativenet/OMIDAdSession.h>
#import "HyBidAd.h"
#import "HyBidSKAdNetworkViewController.h"
#import "HyBidURLDriller.h"
#import "HyBidError.h"
#import "HyBid.h"
#import "HyBidVASTIconUtils.h"
#import "HyBidVASTEndCard.h"
#import "HyBidVASTEndCardManager.h"
#import "HyBidVASTEndCardView.h"
#import "UIApplication+PNLiteTopViewController.h"
#import <StoreKit/SKOverlay.h>
#import "StoreKit/StoreKit.h"
#import <QuartzCore/QuartzCore.h>
#import "HyBidSkipOverlay.h"
#import "HyBidCloseButton.h"
#import "PNLiteOrientationManager.h"

#define kContentInfoContainerTag 2343

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString * const PNLiteVASTPlayerStatusKeyPath         = @"status";
NSString * const PNLiteVASTPlayerBundleName            = @"player.resources";
NSString * const PNLiteVASTPlayerMuteImageName         = @"sound-off";
NSString * const PNLiteVASTPlayerUnMuteImageName       = @"sound-on";
NSString * const PNLiteVASTPlayerFullScreenImageName   = @"PNLiteFullScreen";
NSString * const PNLiteVASTPlayerOpenImageName         = @"PNLiteExternalLink1";

NSTimeInterval const PNLiteVASTPlayerDefaultLoadTimeout        = 20.0f;
NSTimeInterval const PNLiteVASTPlayerDefaultPlaybackInterval   = 0.25f;
CGFloat const PNLiteVASTPlayerViewProgressBottomConstant       = 0.0f;
CGFloat const PNLiteVASTPlayerViewProgressTrailingConstant      = 0.0f;
CGFloat const PNLiteVASTPlayerViewProgressLeadingConstant       = 0.0f;
CGFloat const PNLiteContentViewDefaultSize = 15.0f;
CGFloat const PNLiteMaxContentInfoHeight = 20.0f;

typedef enum : NSUInteger {
    PNLiteVASTPlayerState_IDLE = 1 << 0,
    PNLiteVASTPlayerState_LOAD = 1 << 1,
    PNLiteVASTPlayerState_READY = 1 << 2,
    PNLiteVASTPlayerState_PLAY = 1 << 3,
    PNLiteVASTPlayerState_PAUSE = 1 << 4
}PNLiteVASTPlayerState;

typedef enum : NSUInteger {
    PNLiteVASTPlaybackState_FirstQuartile = 1 << 0,
    PNLiteVASTPlaybackState_SecondQuartile = 1 << 1,
    PNLiteVASTPlaybackState_ThirdQuartile = 1 << 2,
    PNLiteVASTPlaybackState_FourthQuartile = 1 << 3
}PNLiteVASTPlaybackState;

HyBidCloseButton *closeButton;

#define HYBID_PNLiteVAST_CLOSE_BUTTON_TAG 1001
#define kOverlayViewSize 50
#define kAudioMuteSize 30

@interface PNLiteVASTPlayerViewController ()<HyBidVASTEventProcessorDelegate, HyBidContentInfoViewDelegate, HyBidURLDrillerDelegate, SKStoreProductViewControllerDelegate, HyBidVASTEndCardViewDelegate, HyBidSkipOverlayDelegate, PNLiteOrientationManagerDelegate>

@property (nonatomic, assign) BOOL shown;
@property (nonatomic, assign) BOOL wantsToPlay;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL isAdSessionCreated;
@property (nonatomic, assign) BOOL endCardShown;
@property (nonatomic, assign) BOOL isAdFeedbackViewReady;
@property (nonatomic, assign) BOOL isMoviePlaybackFinished;
@property (nonatomic, assign) bool isCountdownTimerStarted;
@property (nonatomic, assign) PNLiteVASTPlayerState currentState;
@property (nonatomic, assign) PNLiteVASTPlaybackState playback;
@property (nonatomic, strong) NSURL *vastUrl;
@property (nonatomic, strong) NSString *vastString;
@property (nonatomic) HyBidAdFormatForVASTPlayer adFormat;

@property (nonatomic, strong) HyBidVASTModel *hyBidVastModel;
@property (nonatomic, strong) HyBidVASTParser *vastParser;
@property (nonatomic, strong) HyBidVASTAd *vastAd;
@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;
@property (nonatomic, strong)NSArray *vastDocumentArray;

@property (nonatomic, strong) HyBidContentInfoView *contentInfoView;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) HyBidSkAdNetworkModel *skAdModel;
@property (nonatomic, strong) OMIDPubnativenetAdSession *adSession;

@property (nonatomic, strong) NSTimer *loadTimer;
@property (nonatomic, strong) id playbackObserverToken;
// Fullscreen
@property (nonatomic, strong) UIView *viewContainer;
// Player
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *layer;

// Player buttons
@property (nonatomic, strong) UIButton *btnMute;

// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *btnOpenOffer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpin;
@property (weak, nonatomic) IBOutlet UIView *contentInfoViewContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOpenOfferBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOpenOfferLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSkipTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSkipTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressTrailingConstraint;

@property (nonatomic, strong) NSArray<HyBidVASTEndCard *> *endCards;
@property (nonatomic, strong) HyBidVASTEndCardManager *endCardManager;
@property (nonatomic) HyBidInterstitialActionBehaviour fullscreenClickabilityBehaviour;
@property (nonatomic, assign) HyBidCountdownStyle countdownStyle;
@property (nonatomic, strong) HyBidSkipOverlay *skipOverlay;
@property (nonatomic, assign) BOOL isFeedbackScreenShown;
@property (nonatomic, assign) BOOL isSkAdnetworkViewControllerIsShown;
@property (nonatomic, strong) NSString *iconPositionX;
@property (nonatomic, strong) NSString *iconPositionY;
@property (nonatomic, strong) HyBidSkipOffset *rewardedVideoSkipOffset;
@property (nonatomic, assign) BOOL skipOverlayConstraintsAdded;

@end

@implementation PNLiteVASTPlayerViewController

#pragma mark NSObject

- (instancetype)initPlayerWithAdModel:(HyBidAd *)adModel withAdFormat:(HyBidAdFormatForVASTPlayer)adFormat {
    self.adFormat = adFormat;
    self.ad = adModel;
    self.skAdModel = adModel.isUsingOpenRTB ? adModel.getOpenRTBSkAdNetworkModel : adModel.getSkAdNetworkModel;
    self = [self init];
    return self;
}

- (instancetype)init {
    if (self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded) {
        self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerFullScreenViewController": @"nib"] bundle:[self getBundle]];
    } else {
        self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerViewController": @"nib"] bundle:[self getBundle]];
    }
    if (self) {
        self.state = PNLiteVASTPlayerState_IDLE;
        [self determineFullscreenClickabilityBehaviourForAd:self.ad];
        [self determineRewardedSkipOffsetForAd:self.ad];
        self.playback = PNLiteVASTPlaybackState_FirstQuartile;
        if (self.ad.audioState) {
            self.muted = [self setAdAudioStatus:[self audioStatusFromString:self.ad.audioState]];
        } else {
            self.muted = [self setAdAudioStatus:[HyBidRenderingConfig sharedConfig].audioStatus];
        }
        [self setAdAudioMuted:self.muted];
        self.canResize = YES;
        self.endCardManager = [[HyBidVASTEndCardManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preparePlayerForAdFeedbackView)
                                                     name:@"adFeedbackViewIsReady"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(feedbackScreenDidShow:)
                                                     name: @"adFeedbackViewDidShow"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(feedbackScreenIsDismissed:)
                                                     name: @"adFeedbackViewIsDismissed"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(skAdnetworkViewControllerIsShown:)
                                                     name: @"adSkAdnetworkViewControllerIsShown"
                                                   object: nil];
    }
    return self;
}

- (void)dealloc {
    [self close];
}

#pragma mark UIViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.layer && self.player.currentItem.presentationSize.width > 0 && self.player.currentItem.presentationSize.height > 0) {
        CGSize videoSize = self.player.currentItem.presentationSize;
        CGFloat aspectRatio = videoSize.width / videoSize.height;
        CGRect layerFrame = CGRectZero;
        layerFrame.size.width = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * aspectRatio);
        layerFrame.size.height = layerFrame.size.width / aspectRatio;
        layerFrame.origin.x = (CGRectGetWidth(self.view.bounds) - layerFrame.size.width) / 2.0;
        layerFrame.origin.y = (CGRectGetHeight(self.view.bounds) - layerFrame.size.height) / 2.0;
        self.layer.frame = layerFrame;
        if (self.btnMute) {
            self.btnMute.frame = CGRectMake(layerFrame.origin.x, layerFrame.origin.y, kAudioMuteSize, kAudioMuteSize);
        }
        
        if (self.skipOverlay && !self.skipOverlay.isCloseButtonShown) {
            CGFloat skipOverlayX = CGRectGetMaxX(layerFrame) - kOverlayViewSize;
            self.skipOverlay.frame = CGRectMake(skipOverlayX, layerFrame.origin.y, kOverlayViewSize, kOverlayViewSize);
            if (!self.skipOverlayConstraintsAdded) {
                [self updateSkipOverlayConstraintsWithLayerFrame:layerFrame];
                self.skipOverlayConstraintsAdded = YES;
            }
        }
    }
}

- (void)updateSkipOverlayConstraintsWithLayerFrame:(CGRect)layerFrame {
    CGFloat skipOverlayY = CGRectGetMinY(layerFrame);
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.skipOverlay attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.skipOverlay attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:skipOverlayY];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSLayoutConstraint activateConstraints:@[trailingConstraint, topConstraint]];
    });
}

- (void)viewDidLoad {
    self.btnMute = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.btnMute addTarget:self action:@selector(btnMutePush:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.btnMute];
    [self setAdAudioMuted:self.muted];
    if (self.fullscreenClickabilityBehaviour == HB_ACTION_BUTTON) {
        [self.btnOpenOffer setImage:[self bundledImageNamed:PNLiteVASTPlayerOpenImageName] forState:UIControlStateNormal];
    } else {
        self.btnOpenOffer.hidden = YES;
    }
    NSOrderedSet *vastSet = [[NSOrderedSet alloc] initWithArray:self.vastParser.vastArray];
    NSMutableArray *vastArray = [[NSMutableArray alloc] initWithArray:[vastSet array]];

    NSString *vast = self.ad.isUsingOpenRTB
    ? self.ad.openRtbVast
    : [[NSString alloc] initWithData:vastArray.firstObject encoding:NSUTF8StringEncoding];
    
    [[[HyBidVASTIconUtils alloc] init] getVASTIconFrom:vast completion:^(NSArray<HyBidVASTIcon *> *icons, NSError *error) {
        HyBidVASTIcon *icon = [self getIconFromArray:icons];
        if (icon != nil) {
            [self setupContentInfoView:icon];
        } else {
            [self setupContentInfoView];
        }
    }];
    
    self.vastString = vast;
    self.contentInfoView.delegate = self;
    self.endCardShown = NO;
    self.isCountdownTimerStarted = NO;
}

- (HyBidVASTIcon *)getIconFromArray:(NSArray<HyBidVASTIcon *> *)icons
{
    for(HyBidVASTIcon *icon in icons) {
        if(icon != nil &&
           [icon.staticResources count] > 0 &&
           ![icon.staticResources.firstObject.content isEqualToString:@""]) {
            return icon;
        } else {
            continue;
        }
    }
    return nil;
}

- (HyBidContentInfoView *)getContentInfoView:(HyBidAd *)ad fromContentInfoView:(HyBidContentInfoView *)contentInfoView
{
    return contentInfoView == nil ? [ad getContentInfoView] : [ad getContentInfoViewFrom:contentInfoView];
}

- (void)setupContentInfoView
{
    [self setupContentInfoView:nil];
}

- (void)setupContentInfoView:(HyBidVASTIcon *)icon
{
    if (self.ad != nil && self.contentInfoViewContainer != nil) {
        HyBidVASTIconUtils *utils = [[HyBidVASTIconUtils alloc] init];
        HyBidContentInfoView *contentInfoViewFromIcon = [utils parseContentInfo:icon];
        HyBidContentInfoView *contentInfoView = [self getContentInfoView:self.ad fromContentInfoView:contentInfoViewFromIcon];

        if (contentInfoView != nil) {
            [contentInfoView setIconSize: CGSizeMake([icon.width doubleValue], [icon.height doubleValue])];
            [self addContentInfoInContainer:self.contentInfoViewContainer withIcon:icon withSize: contentInfoView.frame.size];
            self.contentInfoViewContainer.tag = kContentInfoContainerTag;
            contentInfoView.delegate = self;
            
            [self.contentInfoViewContainer setIsAccessibilityElement:NO];
            [self.contentInfoViewContainer addSubview:contentInfoView];

            if (contentInfoViewFromIcon != nil && contentInfoViewFromIcon.viewTrackers != nil && [contentInfoViewFromIcon.viewTrackers count] > 0) {
                NSMutableArray *stringViewTrackers = [NSMutableArray new];
                for (HyBidVASTIconViewTracking *viewTracking in contentInfoViewFromIcon.viewTrackers) {
                    [stringViewTrackers addObject:[viewTracking content]];
                }
                [[[HyBidVASTEventProcessor alloc] init] sendVASTUrls:stringViewTrackers];
            }
        }
    }
}

- (void)addContentInfoInContainer:(UIView*) containerView withIcon:(HyBidVASTIcon *) icon withSize:(CGSize) iconSize {

    containerView.translatesAutoresizingMaskIntoConstraints = false;

    [containerView.widthAnchor constraintGreaterThanOrEqualToConstant: iconSize.width].active = YES;
    [containerView.heightAnchor constraintEqualToConstant: iconSize.height].active = YES;

    [self addingConstrainstForDynamicPosition:containerView icon:icon];
    
}

- (void)addingConstrainstForDynamicPosition:(UIView *) contentInfoViewContainer icon:(HyBidVASTIcon *) icon {
    
    contentInfoViewContainer.translatesAutoresizingMaskIntoConstraints = false;
    NSString *xPosition;
    xPosition = @"left";
    // ContentInfo: Hardcoding xPosition to left and yPosition to bottom
//    if (icon.xPosition){
//        xPosition = icon.xPosition;
//    } else {
//        xPosition = @"left";
//    }

    NSString *yPosition;
    yPosition = @"bottom";
//    if (icon.yPosition){
//        yPosition = icon.yPosition;
//    } else {
//        yPosition = @"bottom";
//    }

    if([xPosition isEqualToString: @"right"]){
        if (@available(iOS 11.0, *)) {
            [contentInfoViewContainer.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        } else {
            [contentInfoViewContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        }
    } else {
        if (@available(iOS 11.0, *)) {
            [contentInfoViewContainer.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        } else {
            [contentInfoViewContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        }
    }

    if([yPosition isEqualToString: @"bottom"]){
        [contentInfoViewContainer.bottomAnchor constraintEqualToAnchor:self.viewProgress.topAnchor].active = YES;
    } else {
        if (@available(iOS 11.0, *)) {
            [contentInfoViewContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        } else {
            [contentInfoViewContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        }
    }
    
    self.iconPositionX = xPosition;
    self.iconPositionY = yPosition;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isMoviePlaybackFinished) {return;}
    self.shown = YES;
    if(self.wantsToPlay) {
        [self setState:PNLiteVASTPlayerState_PLAY];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.adFormat == HyBidAdFormatBanner) {
        [self stop];
    }
    self.shown = NO;
}

- (void)preparePlayerForAdFeedbackView {
    self.isAdFeedbackViewReady = YES;
}

#pragma mark - PUBLIC -

- (void)loadWithVastUrl:(NSURL*)url {
    @synchronized (self) {
        self.vastUrl = url;
        [self setState:PNLiteVASTPlayerState_LOAD];
    }
}

- (void)loadWithVastString:(NSString *)vast {
    @synchronized (self) {
        self.vastString = vast;
        
        NSData *vastData = [self.vastString dataUsingEncoding:NSUTF8StringEncoding];
        self.vastDocumentArray = [[NSArray alloc] initWithObjects:vastData, nil];
        
        [self setState:PNLiteVASTPlayerState_LOAD];
    }
}

- (void)loadWithVideoAdCacheItem:(HyBidVideoAdCacheItem *)videoAdCacheItem {
    @synchronized (self) {
        self.videoAdCacheItem = videoAdCacheItem;
        
        if (self.videoAdCacheItem.vastModel && self.vastString == nil) {
            self.vastString = [self.videoAdCacheItem.vastModel vastString];
        }
        
        NSData *vastData = [self.vastString dataUsingEncoding:NSUTF8StringEncoding];
        self.vastDocumentArray = [[NSArray alloc] initWithObjects:vastData, nil];
        
        [self setState:PNLiteVASTPlayerState_LOAD];
    }
}

- (void)play {
    @synchronized (self) {
        if (!self.isMoviePlaybackFinished) {
            [self startAdSession];
            [self setState:PNLiteVASTPlayerState_PLAY];
        }
    }
}

- (void)pause {
    @synchronized (self) {
        [self setState:PNLiteVASTPlayerState_PAUSE];
    }
}

- (void)stop {
    @synchronized (self) {
        if (self.isAdFeedbackViewReady) {
            if (!self.isMoviePlaybackFinished) {
                [self setState:PNLiteVASTPlayerState_PAUSE];
                if(self.adFormat == HyBidAdFormatBanner) {
                    self.shown = NO;
                }
            }
            self.isAdFeedbackViewReady = NO;
        } else {
            [self stopAdSession];
            [self setState:PNLiteVASTPlayerState_IDLE];
        }
    }
}

#pragma mark - PRIVATE -

- (void)determineFullscreenClickabilityBehaviourForAd:(HyBidAd *)ad {
    if (ad.fullscreenClickability) {
        if ([ad.fullscreenClickability boolValue]) {
            self.fullscreenClickabilityBehaviour = HB_CREATIVE;
        } else {
            self.fullscreenClickabilityBehaviour = HB_ACTION_BUTTON;
        }
    } else {
        self.fullscreenClickabilityBehaviour = [HyBidRenderingConfig sharedConfig].interstitialActionBehaviour;
    }
}

- (IBAction)videoTapped:(UITapGestureRecognizer *)sender {
    if (self.fullscreenClickabilityBehaviour == HB_CREATIVE && !self.endCardShown) {
        [self btnOpenOfferPush:nil];
    }
}

- (void)startAdSession {
    if (!self.isAdSessionCreated) {
        NSMutableArray<OMIDPubnativenetVerificationScriptResource *> *scriptResources = [[NSMutableArray alloc] init];
        NSArray<HyBidVASTAd *> *ads = [self.hyBidVastModel ads];
        
        if ([ads count] > 0) {
            HyBidVASTAd *firstAd = [ads firstObject];
            
            NSArray<HyBidVASTVerification *> * adVerifications = [[firstAd inLine] adVerifications];
            if (adVerifications) {
                for (HyBidVASTVerification *verification in adVerifications) {
                    if (verification) {
                        for (HyBidVASTJavaScriptResource *res in [verification javaScriptResource]) {
                            NSString* urlString = [res url];
                            NSString* vendor = [verification vendor];
                            NSString* params = [[verification verificationParameters] content];

                        if (urlString && [urlString length] != 0 && vendor && [vendor length] != 0 && params && [params length] != 0) {
                                [scriptResources addObject: [[OMIDPubnativenetVerificationScriptResource alloc] initWithURL:[NSURL URLWithString:urlString] vendorKey:vendor parameters:params]];
                            }
                        }
                    }
                }
            }
        }
        
        self.adSession = [[HyBidViewabilityNativeVideoAdSession sharedInstance] createOMIDAdSessionforNativeVideo:self.view withScript:scriptResources];
        
        if (self.contentInfoView) {
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.contentInfoView toOMIDAdSession:self.adSession withReason:@"This view is related to Content Info" isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)];
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.contentInfoViewContainer toOMIDAdSession:self.adSession withReason:@"This view is related to Content Info" isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)];
        }
        if (self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded) {
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction: self.skipOverlay toOMIDAdSession:self.adSession withReason:@"" isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)];
        }
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.btnMute toOMIDAdSession:self.adSession withReason:@"This view is related to mute button" isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.btnOpenOffer toOMIDAdSession:self.adSession withReason:@"This view is related to open offer" isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] startOMIDAdSession:self.adSession];
        self.isAdSessionCreated = YES;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDAdLoadEvent:self.adSession];
    }
}

- (void)setCustomCountdown
{
    if(self.skipOffset > [self duration]){
        return;
    }
    
    self.skipOverlay = [[HyBidSkipOverlay alloc] initWithSkipOffset:self.skipOffset withCountdownStyle:HyBidCountdownPieChart withContentInfoPositionTopRight:[self isContentInfoInTopRightPosition] withShouldShowSkipButton:self.ad.hasEndCard && !self.closeOnFinish];
    [self.skipOverlay addSkipOverlayViewIn:self.view delegate:self withIsMRAID:NO];
}

#pragma mark - SkipOverlay Delegate helpers

- (void)skipButtonTapped
{
    if (self.ad.hasEndCard && !self.closeOnFinish) { // Skipped to end card
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_skip];
        [self removePeriodicTimeObserver];
        [self showEndCard];
    } else if (!self.isMoviePlaybackFinished) {
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_skip];
        [self invokeDidClose];
    } else {
        [self invokeDidClose];
    }
}

- (void)skipTimerCompleted {
    if(self.countdownStyle == HyBidCountdownPieChart && self.skipOverlay.isCloseButtonShown){
        [self setCloseButtonPositionConstraints: self.skipOverlay];
    }
    [self.view layoutIfNeeded];
}

- (void)setCloseButtonPositionConstraints:(UIView *) closeButtonView {
    
    BOOL isCloseViewShown = NO;
    for (UIView *view in self.view.subviews) {
        if([view isEqual: closeButtonView]){
            isCloseViewShown = YES;
            break;
        }
    }
    
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
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kOverlayViewSize],
                                                         [NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kOverlayViewSize], nil];
    if([self isContentInfoInTopRightPosition]){
        if (@available(iOS 11.0, *)) {
            [constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]]];
        } else {
            [constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]]];
        }
    } else {
        if (@available(iOS 11.0, *)) {
            [constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]]];
        } else {
            [constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],[NSLayoutConstraint constraintWithItem:closeButtonView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]]];
        }
    }
    [NSLayoutConstraint activateConstraints: constraints];
}

- (void)stopAdSession {
    if (self.isAdSessionCreated) {
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] stopOMIDAdSession:self.adSession];
        self.isAdSessionCreated = NO;
    }
}

- (void)close {
    @synchronized (self) {
        [self removeObservers];
        [self stopLoadTimeoutTimer];
        if(self.shown) {
            [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_close];
        }
        [self.player pause];
        [self.layer removeFromSuperlayer];

        self.layer = nil;
        self.playerItem = nil;
        self.player = nil;
        self.vastUrl = nil;
        self.vastString = nil;
        self.hyBidVastModel = nil;
        [self.vastParser.vastArray removeAllObjects];
        self.vastParser = nil;
        self.vastEventProcessor = nil;
        self.viewContainer = nil;
        self.contentInfoView = nil;
        self.videoAdCacheItem = nil;
        self.skipOverlay = nil;
        self.isCountdownTimerStarted = nil;
        self.rewardedVideoSkipOffset = nil;
        closeButton = nil;
    }
}

- (UIImage*)bundledImageNamed:(NSString*)name {
    NSBundle *bundle = [self getBundle];
    // Try getting the regular PNG
    NSString *imagePath = [bundle pathForResource:[self nameForResource:name :@"png"] ofType:@"png"];
    // If nil, let's try to get the combined TIFF, JIC it's enabled
    if(!imagePath) {
        imagePath = [bundle pathForResource:[self nameForResource:name :@"tiff"] ofType:@"tiff"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSBundle*)getBundle {
    return [NSBundle bundleForClass:[self class]];
}

- (void)createVideoPlayerWithVideoUrl:(NSURL*)url {
    [self addObservers];
    // Create asset to be played
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *assetKeys = @[@"playable"];
    
    // Create a new AVPlayerItem with the asset and an
    // array of asset keys to be automatically loaded
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];
    
    // Register as an observer of the player item's status property
    [self.playerItem addObserver:self
                      forKeyPath:PNLiteVASTPlayerStatusKeyPath
                         options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                         context:&_playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    self.isMoviePlaybackFinished = NO;
    self.player.volume = 0;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    __weak typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(PNLiteVASTPlayerDefaultPlaybackInterval, NSEC_PER_SEC);
    self.playbackObserverToken = [self.player addPeriodicTimeObserverForInterval:interval
                                                                           queue:nil
                                                                      usingBlock:^(CMTime time) {
        [weakSelf onPlaybackProgressTick];
    }];
}

- (void)removePeriodicTimeObserver {
    if (self.playbackObserverToken) {
        [self.player removeTimeObserver:self.playbackObserverToken];
        self.playbackObserverToken = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    // Only handle observations for the PlayerItemContext
    
    if (context != &_playerItem) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else if ([keyPath isEqualToString:PNLiteVASTPlayerStatusKeyPath]
               && self.currentState == PNLiteVASTPlayerState_LOAD) {
        
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                [self setState:PNLiteVASTPlayerState_READY];
                [self invokeDidFinishLoading];
                break;
            case AVPlayerItemStatusFailed:
                if (self.playerItem.error) {
                    [self invokeDidFailLoadingWithError:self.playerItem.error];
                } else {
                    [self invokeDidFailLoadingWithError:[NSError errorWithDomain:@"Something went wrong with the AVPlayerItem." code:0 userInfo:nil]];
                }
                
                [self setState:PNLiteVASTPlayerState_IDLE];
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

- (void)onPlaybackProgressTick {
    Float64 currentDuration = [self duration];
    Float64 currentPlaybackTime = [self currentPlaybackTime];
    Float64 currentPlayedPercent = currentPlaybackTime / currentDuration;
    
    [self startBottomProgressBarAnimationWithProgress:currentPlayedPercent];
    
    switch (self.playback) {
        case PNLiteVASTPlaybackState_FirstQuartile:
        {
            if (currentPlayedPercent>0.25f) {
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_firstQuartile];
                self.playback = PNLiteVASTPlaybackState_SecondQuartile;
            }
        }
            break;
        case PNLiteVASTPlaybackState_SecondQuartile:
        {
            if (currentPlayedPercent>0.50f) {
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_midpoint];
                self.playback = PNLiteVASTPlaybackState_ThirdQuartile;
            }
        }
            break;
        case PNLiteVASTPlaybackState_ThirdQuartile:
        {
            if (currentPlayedPercent>0.75f) {
                [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_thirdQuartile];
                self.playback = PNLiteVASTPlaybackState_FourthQuartile;
            }
        }
            break;
        default: break;
    }
    
    if(self.adFormat == HyBidAdFormatInterstitial && !self.skipOverlay){
        [self setCustomCountdown];
    }
   
    if(self.adFormat == HyBidAdFormatRewarded && !self.skipOverlay) {
        [self skipRewardedAfterSelectedTime:[self.rewardedVideoSkipOffset.offset integerValue]];
    }
}

- (void)determineRewardedSkipOffsetForAd:(HyBidAd *)ad {
    if (self.ad.rewardedVideoSkipOffset) {
        self.rewardedVideoSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:self.ad.rewardedVideoSkipOffset isCustom:YES];
    } else {
        self.rewardedVideoSkipOffset = [HyBidRenderingConfig sharedConfig].rewardedVideoSkipOffset;
    }
}

- (void)skipRewardedAfterSelectedTime:(NSInteger)secondsToSkip {
    if ([self duration] >= secondsToSkip) {
        if (!self.isCountdownTimerStarted) {
            self.skipOffset = secondsToSkip;
            [self.skipOverlay updateTimerStateWithRemainingSeconds:self.skipOffset withTimerState:HyBidTimerState_Start];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *playbackTime = @([self currentPlaybackTime]).stringValue;
                NSString *currentPlaybackTime = [[playbackTime componentsSeparatedByString:@"."] objectAtIndex:0];
                [self setCustomCountdown];
                if (currentPlaybackTime.intValue == secondsToSkip && self.skipOffset != 0) {
                    if (self.ad.hasEndCard){
                        [self showEndCard];
                    } else {
                        [self addCloseButton];
                    }
                }
            });
            self.isCountdownTimerStarted = YES;
        }
    }
}

- (void)startBottomProgressBarAnimationWithProgress:(Float64)progress
{
    [UIView animateWithDuration:progress delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.viewProgress setProgress:progress animated:YES];
    } completion:nil];
}

- (Float64)duration {
    AVPlayerItem *currentItem = self.player.currentItem;
    return CMTimeGetSeconds([currentItem duration]);
}

- (Float64)currentPlaybackTime {
    AVPlayerItem *currentItem = self.player.currentItem;
    return CMTimeGetSeconds([currentItem currentTime]);
}

- (void)trackError {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Sending Error requests."];
    
    if (self.hyBidVastModel && [self.hyBidVastModel errors] != nil) {
        [self.vastEventProcessor sendVASTUrls:[self.hyBidVastModel errors]];
    }
}

- (HyBidAudioStatus)audioStatusFromString:(NSString *)audioState {
    if ([audioState isEqualToString:@"muted"]) {
        return HyBidAudioStatusMuted;
    } else if ([audioState isEqualToString:@"on"]) {
        return HyBidAudioStatusON;
    } else {
        return HyBidAudioStatusDefault;
    }
}

- (void)setAdAudioMuted:(BOOL)muted {
    NSString *newImageName = muted ? PNLiteVASTPlayerMuteImageName : PNLiteVASTPlayerUnMuteImageName;
    UIImage *newImage = [self bundledImageNamed:newImageName];
    [self.btnMute setImage:newImage forState:UIControlStateNormal];
    CGFloat newVolume = muted ? 0.0f : 1.0f;
    self.player.volume = newVolume;
    [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDVolumeChangeEventWithVolume:newVolume];
}

- (BOOL)setAdAudioStatus:(HyBidAudioStatus)status {
    switch (status) {
        case HyBidAudioStatusDefault:
        case HyBidAudioStatusMuted:
            return YES;
            break;
        case HyBidAudioStatusON:
            return NO;
        default:
            return [[HyBidSettings sharedInstance].deviceSound isEqual: @"0"];
            break;
    }
}

#pragma mark IBActions

- (IBAction)btnMutePush:(id)sender {
    self.muted = !self.muted;
    [self setAdAudioMuted:self.muted];
    if (self.muted) {
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_MUTE];
    } else {
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_UNMUTE];
    }
}

- (IBAction)btnClosePush:(id)sender {
    if (self.ad.hasEndCard && !self.closeOnFinish) { // Skipped to end card
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_skip];
        [self removePeriodicTimeObserver];
        [self showEndCard];
    } else if (!self.isMoviePlaybackFinished) {
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_skip];
        [self invokeDidClose];
    } else {
        [self invokeDidClose];
    }
}

- (IBAction)btnOpenOfferPush:(id)sender {
    Float64 duration = floor([self duration] * 4) / 4;
    if ([self currentPlaybackTime] != duration) {
        if (self.player.rate != 0 && self.player.error == nil) { // isPlaying
            [self.viewProgress setProgress:[self currentPlaybackTime] / [self duration]];
            for (CALayer *layer in self.viewProgress.layer.sublayers) {
                [layer removeAllAnimations];
            }
        }
    }
    [self trackClick];
}

- (void)trackClick {
    HyBidVASTAd *ad = [self getVastAd];
    
    if (ad == nil) {
        return;
    }
    
    NSArray<HyBidVASTCreative *> *creatives = [[ad inLine] creatives];
    NSMutableArray<HyBidVASTVideoClicks *> *videoClicks = [NSMutableArray new];
    
    for (HyBidVASTCreative *creative in creatives) {
        if ([creative linear] != nil) {
            [videoClicks addObject:[[creative linear] videoClicks]];
            break;
        }
    }
    
    NSMutableArray<NSString *> *trackingClickURLs = [[NSMutableArray alloc] init];
    NSString *throughClickURL;
    
    for (HyBidVASTVideoClicks *videoClick in videoClicks) {
        if (throughClickURL == nil) {
            throughClickURL = [[videoClick clickThrough] content];
        }
    }
    
    for (HyBidVASTVideoClicks *videoClick in videoClicks) {
        for (HyBidVASTClickTracking *tracking in [videoClick clickTrackings]) {
            [trackingClickURLs addObject:[tracking content]];
        }
    }
    
    if ([trackingClickURLs count] > 0) {
        [self.vastEventProcessor sendVASTUrls:trackingClickURLs];
    }
    
    [self invokeDidClickOffer];
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    
    if (self.skAdModel) {
        NSMutableDictionary* productParams = [[self.skAdModel getStoreKitParameters] mutableCopy];
        
        [self insertFidelitiesIntoDictionaryIfNeeded:productParams];
        
        if ([productParams count] > 0) {
            if (throughClickURL != nil) {
                [[HyBidURLDriller alloc] startDrillWithURLString:throughClickURL delegate:self];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [productParams removeObjectForKey:@"fidelity-type"];
                
                HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParams];
                skAdnetworkViewController.delegate = self;
                [[UIApplication sharedApplication].topViewController presentViewController:skAdnetworkViewController animated:true completion:nil];
            });
        } else {
            if (throughClickURL != nil) {
                BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:throughClickURL]];
                if(!canOpenURL){
                    throughClickURL = [throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:throughClickURL] options:@{} completionHandler:^(BOOL success) {
                    [self togglePlaybackStateOnSuccess: success];
                }];
            }
        }
    } else {
        if (throughClickURL != nil) {
            BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:throughClickURL]];
            if(!canOpenURL){
                throughClickURL = [throughClickURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:throughClickURL] options:@{} completionHandler:^(BOOL success) {
                [self togglePlaybackStateOnSuccess: success];
            }];
        }
    }
}

- (NSMutableDictionary *)insertFidelitiesIntoDictionaryIfNeeded:(NSMutableDictionary *)dictionary {
    double skanVersion = [dictionary[@"adNetworkPayloadVersion"] doubleValue];
    if ([[HyBidSettings sharedInstance] supportMultipleFidelities] && skanVersion >= 2.2 && [dictionary[@"fidelities"] count] > 0) {
        NSArray<NSData *> *fidelitiesDataArray = dictionary[@"fidelities"];
        
        if ([fidelitiesDataArray count] > 0) {
            for (NSData *fidelity in fidelitiesDataArray) {
                SKANObject skanObject;
                [fidelity getBytes:&skanObject length:sizeof(skanObject)];
                
                if (skanObject.fidelity == 1) {
                    if (@available(iOS 11.3, *)) {
                        [dictionary setObject:[NSString stringWithUTF8String:skanObject.timestamp] forKey:SKStoreProductParameterAdNetworkTimestamp];
                        
                        NSString *nonce = [NSString stringWithUTF8String:skanObject.nonce];
                        [dictionary setObject:[[NSUUID alloc] initWithUUIDString:nonce] forKey:SKStoreProductParameterAdNetworkNonce];
                    }
                    
                    if (@available(iOS 13.0, *)) {
                        NSString *signature = [NSString stringWithUTF8String:skanObject.signature];
                        
                        [dictionary setObject:signature forKey:SKStoreProductParameterAdNetworkAttributionSignature];
                        
                        NSString *fidelity = [NSString stringWithFormat:@"%d", skanObject.fidelity];
                        [dictionary setObject:fidelity forKey:@"fidelity-type"];
                    }
                    
                    dictionary[@"fidelities"] = nil;
                    
                    break; // Currently we support only 1 fidelity for each kind
                }
            }
        }
    }
    
    return dictionary;
}

- (void)setConstraintsForPlayerElementsInFullscreen:(BOOL)isFullscreen {
    if (@available(iOS 11.0, *)) {
        if (isFullscreen) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            CGFloat topPadding = window.safeAreaInsets.top;
            CGFloat bottomPadding = window.safeAreaInsets.bottom;
            CGFloat leadingPadding = window.safeAreaInsets.left;
            CGFloat trailingPadding = window.safeAreaInsets.right;
            self.btnOpenOfferBottomConstraint.constant = -bottomPadding;
            self.btnOpenOfferLeadingConstraint.constant = leadingPadding;
            self.contentInfoViewContainerTopConstraint.constant = -topPadding;
            self.contentInfoViewContainerLeadingConstraint.constant = leadingPadding;
            self.viewProgressBottomConstraint.constant = -bottomPadding;
            self.viewProgressLeadingConstraint.constant = leadingPadding;
            self.viewProgressTrailingConstraint.constant = trailingPadding;
        } else {
            self.btnOpenOfferBottomConstraint.constant = 0;
            self.btnOpenOfferLeadingConstraint.constant = 0;
            self.contentInfoViewContainerTopConstraint.constant = 0;
            self.contentInfoViewContainerLeadingConstraint.constant = 0;
            self.viewProgressTrailingConstraint.constant = PNLiteVASTPlayerViewProgressTrailingConstant;
            self.viewProgressLeadingConstraint.constant = PNLiteVASTPlayerViewProgressLeadingConstant;
            self.viewProgressBottomConstraint.constant = PNLiteVASTPlayerViewProgressBottomConstant;
        }
        
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Delegate helpers

- (void)invokeDidClickOffer {
    if ([self.delegate respondsToSelector:@selector(vastPlayerDidOpenOffer:)]) {
        [self.delegate vastPlayerDidOpenOffer:self];
    }
}

- (void)invokeDidFinishLoading {
    [self stopLoadTimeoutTimer];
    if([self.delegate respondsToSelector:@selector(vastPlayerDidFinishLoading:)]) {
        [self.delegate vastPlayerDidFinishLoading:self];
    }
}

- (void)invokeDidFailLoadingWithError:(NSError*)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if([self.delegate respondsToSelector:@selector(vastPlayer:didFailLoadingWithError:)]) {
        [self.delegate vastPlayer:self didFailLoadingWithError:error];
    }
    [self trackError];
    [self close];
}

- (void)invokeDidStartPlaying {
    if([self.delegate respondsToSelector:@selector(vastPlayerDidStartPlaying:)]) {
        [self.delegate vastPlayerDidStartPlaying:self];
    }
}

- (void)invokeDidPause {
    if([self.delegate respondsToSelector:@selector(vastPlayerDidPause:)]) {
        [self.delegate vastPlayerDidPause:self];
    }
}

- (void)invokeDidComplete {
    if([self.delegate respondsToSelector:@selector(vastPlayerDidComplete:)]) {
        [self.delegate vastPlayerDidComplete:self];
    }

    if (self.ad.hasEndCard && !self.closeOnFinish) {
        [self showEndCard];
    } else {
        if (self.closeOnFinish) {
            [self invokeDidClose];
        }
    }
    
    if(self.adFormat != HyBidAdFormatBanner && !self.ad.hasEndCard && !self.closeOnFinish){
        [self addCloseButton];
    }
}

- (void)invokeDidClose {
    if ([self.delegate respondsToSelector:@selector(vastPlayerDidClose:)]) {
        [self.delegate vastPlayerDidClose:self];
    }
}

#pragma mark - AVPlayer notifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)removeObservers {
    if(self.player != nil) {
        [self.playerItem removeObserver:self forKeyPath:PNLiteVASTPlayerStatusKeyPath];
        [self.player removeTimeObserver:self.playbackObserverToken];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    if(self.currentState == PNLiteVASTPlayerState_PLAY) {
        [self setState:PNLiteVASTPlayerState_PAUSE];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if(self.currentState == PNLiteVASTPlayerState_PLAY ||
       self.currentState == PNLiteVASTPlayerState_PAUSE) {
        if(!self.isFeedbackScreenShown && !self.isSkAdnetworkViewControllerIsShown){
            [self setState:PNLiteVASTPlayerState_PLAY];
        }
    }
}

- (void)feedbackScreenDidShow:(NSNotification*)notification {
    self.isFeedbackScreenShown = YES;
    [self setState:PNLiteVASTPlayerState_PAUSE];
}

- (void)feedbackScreenIsDismissed:(NSNotification*)notification {
    self.isFeedbackScreenShown = NO;
    [self setState:PNLiteVASTPlayerState_PLAY];
}

- (void)playCountdownView {
    NSInteger remainingSeconds = self.skipOffset - [self currentPlaybackTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds: remainingSeconds withTimerState:HyBidTimerState_Start];
}

- (void)pauseCountdownView {
    NSInteger remainingSeconds = self.skipOffset - [self currentPlaybackTime];
    [self.skipOverlay updateTimerStateWithRemainingSeconds:(remainingSeconds) withTimerState:HyBidTimerState_Pause];
}

- (void)skAdnetworkViewControllerIsShown:(NSNotification*)notification {
    self.isSkAdnetworkViewControllerIsShown = YES;
    [self setState:PNLiteVASTPlayerState_PAUSE];
}

- (void)skAdnetworkViewControllerIsDismissed:(NSNotification*)notification {
    self.isSkAdnetworkViewControllerIsShown = NO;
    [self setState:PNLiteVASTPlayerState_PLAY];
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    // when endcard is presented the play already will seek to end to complete the video. Then this callback will be called. so intercept here
    if (self.endCardShown || self.isMoviePlaybackFinished) {return;}
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_complete];
    [self.player pause];
    
    Float64 duration = floor([self duration] * 4) / 4;
    CMTime lastFrameSecond = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
    [self.playerItem seekToTime:lastFrameSecond toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self setState:PNLiteVASTPlayerState_READY];
    [self invokeDidComplete];
    self.isMoviePlaybackFinished = YES;
}

- (BOOL)isContentInfoInTopRightPosition {    
    BOOL isRightPosition = [self.iconPositionX isEqualToString: @"right"] ? YES : NO;
    BOOL isTopPosition = [self.iconPositionY isEqualToString:@"top"] ? YES : NO;
    
    return isRightPosition && isTopPosition ? YES : NO;
}

- (void)addCloseButton {
    [self.skipOverlay removeFromSuperview];
    if (closeButton) {
        return;
    }
    closeButton = [[HyBidCloseButton alloc] initWithRootView:self.view action:@selector(invokeDidClose) target:self];
}

#pragma mark - State Machine

- (BOOL)canGoToState:(PNLiteVASTPlayerState)state {
    BOOL result = NO;
    
    switch (state) {
        case PNLiteVASTPlayerState_IDLE:    result = YES; break;
        case PNLiteVASTPlayerState_LOAD:    result = self.currentState & PNLiteVASTPlayerState_IDLE; break;
        case PNLiteVASTPlayerState_READY:   result = self.currentState & (PNLiteVASTPlayerState_PLAY|PNLiteVASTPlayerState_LOAD); break;
        case PNLiteVASTPlayerState_PLAY:
        {
            if ((self.currentState & PNLiteVASTPlayerState_READY) && !self.shown) {
                self.wantsToPlay = YES;
                [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"You're trying to play when the view is not add to the screen, it will be played as soon as the view is add to the screen."];
            }
            result = (self.currentState & (PNLiteVASTPlayerState_READY|PNLiteVASTPlayerState_PAUSE)) && self.shown;
        }
            break;
        case PNLiteVASTPlayerState_PAUSE:   result = (self.currentState & PNLiteVASTPlayerState_PLAY) && self.shown; break;
        default: break;
    }
    
    return result;
}

- (void)setState:(PNLiteVASTPlayerState)state {
    if ([self canGoToState:state]) {
        self.currentState = state;
        switch (self.currentState) {
            case PNLiteVASTPlayerState_IDLE:    [self setIdleState];    break;
            case PNLiteVASTPlayerState_LOAD:    [self setLoadState];    break;
            case PNLiteVASTPlayerState_READY:   [self setReadyState];   break;
            case PNLiteVASTPlayerState_PLAY:    [self setPlayState];    break;
            case PNLiteVASTPlayerState_PAUSE:   [self setPauseState];   break;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Cannot go to state %lu, invalid previous state.", (unsigned long)state]];
    }
}

- (void)setIdleState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = YES;
    self.btnOpenOffer.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];
    
    [self close];
}

- (void)setLoadState {
    self.loadingSpin.hidden = NO;
    self.btnMute.hidden = YES;
    self.btnOpenOffer.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin startAnimating];
    
    if (self.videoAdCacheItem.vastModel) {
        self.hyBidVastModel = self.videoAdCacheItem.vastModel;
        [self fetchEndCards];
        
        HyBidVASTAd *firstCachedAd = [[self.hyBidVastModel ads] firstObject];
        HyBidVASTCreative *cachedCreative;

        for (HyBidVASTCreative *creative in [[firstCachedAd inLine] creatives]) {
            if ([creative linear] != nil) {
                cachedCreative = creative;
                break;
            }
        }

        if ([[self.hyBidVastModel ads] count] > 0) {
            HyBidVASTAd *firstCachedAd = [[self.hyBidVastModel ads] firstObject];
            HyBidVASTCreative *cachedCreative;
            
            for (HyBidVASTCreative *creative in [[firstCachedAd inLine] creatives]) {
                if ([creative linear] != nil) {
                    cachedCreative = creative;
                    break;
                }
            }
            
            HyBidVASTLinear *cachedLinear = [cachedCreative linear];
            NSArray<HyBidVASTTracking *> *cachedTrackingEvents = [[cachedLinear trackingEvents] events];
            
            HyBidVASTMediaFiles *cachedMediaFiles = [cachedLinear mediaFiles];
            NSString *mediaUrl = [HyBidVASTMediaFilePicker pick:[cachedMediaFiles mediaFiles]].url;
            
            self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEvents:cachedTrackingEvents delegate:self];
            if ([self.videoAdCacheItem.vastModel ads].count > 0) {
                if(!mediaUrl) {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Did not find a compatible media file."];
                    NSError *mediaNotFoundError = [NSError errorWithDomain:@"Not found compatible media with this device." code:HyBidErrorCodeInternal userInfo:nil];
                    [self invokeDidFailLoadingWithError:mediaNotFoundError];
                } else {
                    if ([[cachedLinear skipOffset] integerValue] != -1 && self.skipOffset <= 0) {
                        self.skipOffset = [[cachedLinear skipOffset] integerValue];
                    }
                    
                    if (mediaUrl != nil && ![mediaUrl isEqualToString:@""]) {
                        [self createVideoPlayerWithVideoUrl:[[NSURL alloc] initWithString: mediaUrl]];
                    }
                }
            } else {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"VAST does not contain any ads."];
                NSError *noAdFoundError = [NSError errorWithDomain:@"VAST does not contain any ads." code:HyBidErrorCodeNullAd userInfo:nil];
                [self invokeDidFailLoadingWithError:noAdFoundError];
            }
        }
    } else if (self.vastUrl || self.vastString) {
        if (!self.vastParser) {
            self.vastParser = [[HyBidVASTParser alloc] init];
        }
        [self startLoadTimeoutTimer];
        __weak PNLiteVASTPlayerViewController *weakSelf = self;
        
        HyBidVastParserCompletionBlock completion = ^(HyBidVASTModel *model, HyBidVASTParserError error) {
            if (!model) {
                NSError *parseError = [NSError errorWithDomain:[NSString stringWithFormat:@"%ld", (long)error]
                                                          code:HyBidErrorCodeInternal
                                                      userInfo:nil];
                [weakSelf invokeDidFailLoadingWithError:parseError];
            } else {
                if ([[model ads] count] > 0) {
                    HyBidVASTAd *firstAd = [[model ads] firstObject];
                    HyBidVASTCreative *adCreative;
                    
                    for (HyBidVASTCreative *creative in [[firstAd inLine] creatives]) {
                        if ([creative linear] != nil) {
                            adCreative = creative;
                            break;
                        }
                    }
                    
                    HyBidVASTLinear *linear = [adCreative linear];
                    NSArray<HyBidVASTTracking *> *events = [[linear trackingEvents] events];
                    
                    weakSelf.vastEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEvents:events delegate:self];
                    
                    HyBidVASTMediaFiles *mediaFiles = [linear mediaFiles];
                    
                    NSString *mediaUrl = [HyBidVASTMediaFilePicker pick:[mediaFiles mediaFiles]].url;
                    weakSelf.hyBidVastModel = model;
                    [self fetchEndCards];
                        
                    if(!mediaUrl) {
                        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Did not find a compatible media file."];
                        NSError *mediaNotFoundError = [NSError errorWithDomain:@"Not found compatible media with this device." code:HyBidErrorCodeInternal userInfo:nil];
                        [weakSelf invokeDidFailLoadingWithError:mediaNotFoundError];
                    } else {
                        NSURL *url = [[NSURL alloc] initWithString:mediaUrl];
                        [weakSelf createVideoPlayerWithVideoUrl:url];
                    }
                } else {
                    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"VAST does not contain any ads."];
                    NSError *noAdFoundError = [NSError errorWithDomain:@"VAST does not contain any ads." code:HyBidErrorCodeNullAd userInfo:nil];
                    [weakSelf invokeDidFailLoadingWithError:noAdFoundError];
                }
            }
        };
        
        if (self.vastUrl != nil) {
            [self.vastParser parseWithUrl:self.vastUrl
                               completion:completion];
        } else if (self.vastString != nil) {
            [self.vastParser parseWithData:[self.vastString dataUsingEncoding:NSUTF8StringEncoding] completion:completion];
        } else {
            NSError *unexpectedError = [NSError errorWithDomain:@"Unexpected Error." code:HyBidErrorCodeInternal userInfo:nil];
            [self invokeDidFailLoadingWithError:unexpectedError];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"VAST is nil and required."];
        [self setState:PNLiteVASTPlayerState_IDLE];
    }
}

- (void)setReadyState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = YES;
    self.viewProgress.hidden = YES;
    self.loadingSpin.hidden = YES;
    
    if(!self.layer) {
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.layer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.layer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
    }
}

- (void)setPlayState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    
    self.btnMute.backgroundColor = UIColor.clearColor;
    [self.btnMute setClipsToBounds: YES];
    self.btnMute.layer.cornerRadius = self.btnMute.layer.frame.size.width / 2;
    [self.view bringSubviewToFront: self.btnMute];
    [self.view bringSubviewToFront: self.contentInfoViewContainer];
    
    if (self.fullscreenClickabilityBehaviour == HB_ACTION_BUTTON) {
        self.btnOpenOffer.hidden = NO;
    }
    self.viewProgress.hidden = NO;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];
    
    // Start playback
    if(!self.isFeedbackScreenShown && !self.isSkAdnetworkViewControllerIsShown){
        [self.player play];
        if(self.skipOverlay){
            [self playCountdownView];
        }
    }
    if([self currentPlaybackTime]  > 0) {
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_resume];
    } else {
        if ([self.hyBidVastModel.ads count] > 0) {
            NSArray<HyBidVASTImpression *> *impressions = self.hyBidVastModel.ads.firstObject.inLine.impressions;
            
            if (self.hyBidVastModel.ads.count > 0 && impressions.count > 0) {
                for (HyBidVASTImpression *impression in impressions)
                    [self.vastEventProcessor trackImpression: impression];
            }
        }
        
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_start];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDStartEventWithDuration:[self duration] withVolume:self.player.volume];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDImpressionOccuredEvent:self.adSession];
    }
    if (self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded) {
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPlayerStateEventWithFullscreenInfo:YES];
    }

    [self invokeDidStartPlaying];
}

- (void)setPauseState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    
    if (self.fullscreenClickabilityBehaviour == HB_ACTION_BUTTON) {
        self.btnOpenOffer.hidden = NO;
    }
    
    self.viewProgress.hidden = NO;
    if(self.adFormat == HyBidAdFormatBanner){
        self.wantsToPlay = YES;
    }
    [self.loadingSpin stopAnimating];
    
    [self.player pause];
    if(self.skipOverlay){
        [self pauseCountdownView];
    }
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_pause];
    [self invokeDidPause];
}

- (void)togglePlaybackStateOnSuccess:(BOOL)success
{
    if(!success){
        if(self.currentState == PNLiteVASTPlayerState_PAUSE){
            [self setState:PNLiteVASTPlayerState_PLAY];
        }
    } else {
        if(self.currentState == PNLiteVASTPlayerState_PLAY){
            [self setState:PNLiteVASTPlayerState_PAUSE];
        }
    }
}

- (HyBidVASTAd *)getVastAd
{
    if (self.videoAdCacheItem.vastModel) {
        return self.vastAd = [[self.videoAdCacheItem.vastModel ads] firstObject];
    } else if ([[self.hyBidVastModel ads] count] > 0) {
        return self.vastAd = [[self.hyBidVastModel ads] firstObject];
    } else {
        return nil;
    }
}

- (void)fetchEndCards
{
    HyBidVASTAd *ad = [self getVastAd];
    
    if (ad == nil) {
        return;
    }

    NSArray<HyBidVASTCreative *> *creatives = [[ad inLine] creatives];
    HyBidVASTCompanionAds *companionAds;
    
    for (HyBidVASTCreative *creative in creatives) {
        if ([creative companionAds] != nil) {
            companionAds = [creative companionAds];
            break;
        }
    }
    
    for (HyBidVASTCompanion *companion in [companionAds companions]) {
        [self.endCardManager addCompanion:companion];
    }
    
    self.endCards = [[NSArray alloc] initWithArray:[self.endCardManager endCards]];
}

- (void)showEndCard
{
    if (@available(iOS 14.0, *)) {
        [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
    } else {
        // Fallback on earlier versions
    }
    
    if(self.skipOverlay){
        [self.skipOverlay removeFromSuperview];
    }
    
    [self.btnMute removeFromSuperview];
    [self.btnOpenOffer removeFromSuperview];
    [self.viewProgress removeFromSuperview];
    self.endCardShown = YES;
    self.isMoviePlaybackFinished = YES;
    [self.player seekToTime:self.player.currentItem.duration
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimePositiveInfinity];
    [self setState:PNLiteVASTPlayerState_READY];
    [self.layer removeFromSuperlayer];
    HyBidVASTEndCard *firstEndCard = [self.endCards firstObject];
    HyBidVASTEndCardView *endCardView = [[HyBidVASTEndCardView alloc] initWithDelegate:self
                                                                    withViewController:self
                                                                                withAd:self.ad
                                                                            withVASTAd:[self getVastAd]
                                                                        isInterstitial:(self.adFormat == HyBidAdFormatInterstitial || self.adFormat == HyBidAdFormatRewarded)
                                                                         iconXposition:self.iconPositionX
                                                                         iconYposition:self.iconPositionY];
    endCardView.frame = self.view.frame;
    [endCardView setupUI];
    
    HyBidVASTCTAButton *ctaButton = [[self.vastAd inLine] ctaButton];
    [endCardView displayEndCard:firstEndCard withCTAButton:ctaButton withViewController:self];
    [self.view addSubview:endCardView];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.COMPANION_VIEW];
}

// MARK: - HyBidVASTEndCardViewDelegate

- (void)vastEndCardViewCloseButtonTapped {
    [self invokeDidClose];
}

- (void)vastEndCardViewClicked {
    [self invokeDidClickOffer];
}

- (void)vastEndCardViewRedirectedWithSuccess:(BOOL)success {
    [self togglePlaybackStateOnSuccess:success];
}

#pragma mark - TIMERS -
#pragma mark Load timer

- (void)startLoadTimeoutTimer {
    @synchronized (self) {
        [self stopLoadTimeoutTimer];
        if(self.loadTimeout == 0) {
            self.loadTimeout = PNLiteVASTPlayerDefaultLoadTimeout;
        }
        
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:self.loadTimeout
                                                          target:self
                                                        selector:@selector(loadTimeoutFired)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)stopLoadTimeoutTimer {
    [self.loadTimer invalidate];
    self.loadTimer = nil;
}

- (void)loadTimeoutFired {
    [self close];
    NSError *error = [NSError errorWithDomain:@"Video load timeout." code:HyBidErrorCodeInternal userInfo:nil];
    [self invokeDidFailLoadingWithError:error];
}

#pragma mark - CALLBACKS -
#pragma mark HyBidVASTEventProcessorDelegate

- (void)eventProcessorDidTrackEventType:(HyBidVASTAdTrackingEventType)event {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Event tracked: %ld", (long)event]];
}

#pragma mark - HyBidContentInfoViewDelegate

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width {
    self.contentInfoViewWidthConstraint.constant = [width floatValue];
    [self setConstraintsForPlayerElementsInFullscreen:self.fullScreen];
    [self.view layoutIfNeeded];
}

#pragma mark SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self.delegate vastPlayerDidCloseOffer:self];
    if((self.currentState == PNLiteVASTPlayerState_PLAY ||
       self.currentState == PNLiteVASTPlayerState_PAUSE)) {
        self.isSkAdnetworkViewControllerIsShown = NO;
        [self setState:PNLiteVASTPlayerState_PLAY];
    }
}

#pragma mark PNLiteOrientationManagerDelegate

- (void)orientationManagerDidChangeOrientation {
    [self.view layoutIfNeeded];
}

#pragma mark - Utils: check for bundle resource existance.

- (NSString*)nameForResource:(NSString*)name :(NSString*)type {
    NSString* resourceName = [NSString stringWithFormat:@"iqv.bundle/%@", name];
    NSString *path = [[self getBundle]pathForResource:resourceName ofType:type];
    if (!path) {
        resourceName = name;
    }
    return resourceName;
}

@end
