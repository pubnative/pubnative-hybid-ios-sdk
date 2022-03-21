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
#import "HyBidLogger.h"
#import "HyBidViewabilityNativeVideoAdSession.h"
#import <OMSDK_Pubnativenet/OMIDAdSession.h>
#import "HyBidAd.h"
#import "HyBidSKAdNetworkViewController.h"
#import "HyBidSettings.h"
#import "HyBidURLDriller.h"
#import "HyBidError.h"
#import "HyBid.h"
#import "HyBidVASTIconUtils.h"

NSString * const PNLiteVASTPlayerStatusKeyPath         = @"status";
NSString * const PNLiteVASTPlayerBundleName            = @"player.resources";
NSString * const PNLiteVASTPlayerMuteImageName         = @"PNLiteMute";
NSString * const PNLiteVASTPlayerUnMuteImageName       = @"PNLiteUnmute";
NSString * const PNLiteVASTPlayerFullScreenImageName   = @"PNLiteFullScreen";
NSString * const PNLiteVASTPlayerOpenImageName         = @"PNLiteExternalLink1";
NSString * const PNLiteVASTPlayerCloseImageName        = @"PNLiteClose";


NSTimeInterval const PNLiteVASTPlayerDefaultLoadTimeout        = 20.0f;
NSTimeInterval const PNLiteVASTPlayerDefaultPlaybackInterval   = 0.25f;
CGFloat const PNLiteVASTPlayerViewSkipTopConstant       = 10.0f;
CGFloat const PNLiteVASTPlayerViewSkipTrailingConstant      = 10.0f;
CGFloat const PNLiteVASTPlayerViewProgressBottomConstant       = 0.0f;
CGFloat const PNLiteVASTPlayerViewProgressTrailingConstant      = 0.0f;
CGFloat const PNLiteVASTPlayerViewProgressLeadingConstant       = 0.0f;

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

@interface PNLiteVASTPlayerViewController ()<HyBidVASTEventProcessorDelegate, HyBidContentInfoViewDelegate, HyBidURLDrillerDelegate>

@property (nonatomic, assign) BOOL shown;
@property (nonatomic, assign) BOOL wantsToPlay;
@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL isInterstitial;
@property (nonatomic, assign) BOOL isAdSessionCreated;
@property (nonatomic, assign) PNLiteVASTPlayerState currentState;
@property (nonatomic, assign) PNLiteVASTPlaybackState playback;
@property (nonatomic, strong) NSURL *vastUrl;
@property (nonatomic, strong) NSString *vastString;

@property (nonatomic, strong) HyBidVASTModel *hyBidVastModel;
@property (nonatomic, strong) HyBidVASTParser *vastParser;
@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;
@property (nonatomic, strong)NSArray *vastDocumentArray;

@property (nonatomic, strong) HyBidContentInfoView *contentInfoView;
@property (nonatomic, strong) HyBidVASTIcon *icon;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) HyBidSkAdNetworkModel *skAdModel;
@property (nonatomic, strong) OMIDPubnativenetAdSession *adSession;

@property (nonatomic, strong) NSTimer *loadTimer;
@property (nonatomic, strong) id playbackToken;
// Fullscreen
@property (nonatomic, strong) UIView *viewContainer;
// Player
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *layer;
@property (nonatomic, strong) PNLiteProgressLabel *progressLabel;
// IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenOffer;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *viewSkip;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpin;
@property (weak, nonatomic) IBOutlet UIView *contentInfoViewContainer;
@property (weak, nonatomic) IBOutlet UIProgressView *viewProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOpenOfferBottomConstraint;
 @property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOpenOfferLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSkipTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSkipTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnMuteTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnMuteLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentInfoViewContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewProgressTrailingConstraint;

@end

@implementation PNLiteVASTPlayerViewController

#pragma mark NSObject

- (instancetype)initPlayerWithAdModel:(HyBidAd *)adModel
                            isInterstital:(BOOL)isInterstitial {
    self.isInterstitial = isInterstitial;
    self = [self init];
    if (self) {
        self.ad = adModel;
        [[[HyBidVASTIconUtils alloc] init] getVASTIconFrom:adModel.vast completion:^(HyBidVASTIcon *icon, NSError *error) {
            self.icon = icon;
        }];
        self.skAdModel = adModel.isUsingOpenRTB ? adModel.getOpenRTBSkAdNetworkModel : adModel.getSkAdNetworkModel;
    }
    return self;
}

- (instancetype)init {
    if (self.isInterstitial) {
        self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerFullScreenViewController": @"nib"] bundle:[self getBundle]];
    } else {
        self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerViewController": @"nib"] bundle:[self getBundle]];
    }
    if (self) {
        self.state = PNLiteVASTPlayerState_IDLE;
        self.playback = PNLiteVASTPlaybackState_FirstQuartile;
        self.muted = [self setAdAudioStatus:[HyBidSettings sharedInstance].audioStatus];
        [self setAdAudioMuted:self.muted];
        self.canResize = YES;
    }
    return self;
}

- (void)dealloc {
    [self close];
}

#pragma mark UIViewController

- (void)viewWillLayoutSubviews {
    if(self.layer) {
        self.layer.frame = self.view.bounds;
    }
}

- (void)viewDidLoad {
    [self setAdAudioMuted:self.muted];
    
    if ([HyBidSettings sharedInstance].interstitialActionBehaviour == HB_ACTION_BUTTON) {
        [self.btnOpenOffer setImage:[self bundledImageNamed:PNLiteVASTPlayerOpenImageName] forState:UIControlStateNormal];
    } else {
        self.btnOpenOffer.hidden = YES;
    }
    
    [self.btnClose setImage:[self bundledImageNamed:PNLiteVASTPlayerCloseImageName] forState:UIControlStateNormal];
    
    if (self.icon != nil) {
        [self setupContentInfoView:self.icon];
    } else {
        [self setupContentInfoView];
    }
    self.contentInfoView.delegate = self;
    
    self.btnClose.hidden = YES;
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
            [self.contentInfoViewContainer addSubview:contentInfoView];
            contentInfoView.delegate = self;
            
            if (contentInfoViewFromIcon != nil && contentInfoViewFromIcon.viewTrackers != nil && [contentInfoViewFromIcon.viewTrackers count] > 0) {
                [[[HyBidVASTEventProcessor alloc] init] sendVASTUrls:contentInfoViewFromIcon.viewTrackers];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.shown = YES;
    if(self.wantsToPlay) {
        [self setState:PNLiteVASTPlayerState_PLAY];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    self.shown = NO;
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
        [self startAdSession];
        [self setState:PNLiteVASTPlayerState_PLAY];
    }
}

- (void)pause {
    @synchronized (self) {
        [self setState:PNLiteVASTPlayerState_PAUSE];
    }
}

- (void)stop {
    @synchronized (self) {
        [self stopAdSession];
        [self setState:PNLiteVASTPlayerState_IDLE];
    }
}

#pragma mark - PRIVATE -

- (IBAction)videoTapped:(UITapGestureRecognizer *)sender {
    if ([HyBidSettings sharedInstance].interstitialActionBehaviour == HB_CREATIVE) {
        [self btnOpenOfferPush:nil];
    }
}

- (void)startAdSession {
    if (!self.isAdSessionCreated) {
        NSMutableArray<OMIDPubnativenetVerificationScriptResource *> *scriptResources = [[NSMutableArray alloc] init];
        HyBidVASTAd *firstAd = [[self.hyBidVastModel ads] firstObject];
        
        NSArray<HyBidVASTVerification *> * adVerifications = [firstAd adVerifications];
        if (adVerifications) {
            for (HyBidVASTVerification *verification in adVerifications) {
                if (verification) {
                    for (HyBidVASTJavaScriptResource *res in [verification javaScriptResource]) {
                        NSString* urlString = [res url];
                        NSString* vendor = [verification vendor];
                        NSString* params = [verification verificationParameters];
                        
                        if (urlString && [urlString length] != 0 && vendor && [vendor length] != 0) {
                            
                            [scriptResources addObject: [[OMIDPubnativenetVerificationScriptResource alloc] initWithURL:[NSURL URLWithString:urlString] vendorKey:vendor parameters:params]];
                        }
                    }
                }
            }
        }
        
        
        self.adSession = [[HyBidViewabilityNativeVideoAdSession sharedInstance] createOMIDAdSessionforNativeVideo:self.view withScript:scriptResources];
        
        if (self.contentInfoView) {
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.contentInfoView toOMIDAdSession:self.adSession withReason:@"This view is related to Content Info" isInterstitial:self.isInterstitial];
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.contentInfoViewContainer toOMIDAdSession:self.adSession withReason:@"This view is related to Content Info" isInterstitial:self.isInterstitial];
        }
        if (self.isInterstitial) {
            [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.btnClose toOMIDAdSession:self.adSession withReason:@"" isInterstitial:self.isInterstitial];
        }
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.btnMute toOMIDAdSession:self.adSession withReason:@"This view is related to mute button" isInterstitial:self.isInterstitial];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] addFriendlyObstruction:self.btnOpenOffer toOMIDAdSession:self.adSession withReason:@"This view is related to open offer" isInterstitial:self.isInterstitial];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] startOMIDAdSession:self.adSession];
        self.isAdSessionCreated = YES;
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDAdLoadEvent:self.adSession];
    }
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
        [self.progressLabel removeFromSuperview];
        self.progressLabel = nil;
        self.layer = nil;
        self.playerItem = nil;
        self.player = nil;
        self.vastUrl = nil;
        self.vastString = nil;
        self.hyBidVastModel = nil;
        self.vastParser = nil;
        self.vastEventProcessor = nil;
        self.viewContainer = nil;
        self.contentInfoView = nil;
        self.videoAdCacheItem = nil;
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
    
    self.player.volume = 0;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    __weak typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(PNLiteVASTPlayerDefaultPlaybackInterval, NSEC_PER_SEC);
    self.playbackToken = [self.player addPeriodicTimeObserverForInterval:interval
                                                                   queue:nil
                                                              usingBlock:^(CMTime time) {
                                                                  [weakSelf onPlaybackProgressTick];
                                                              }];
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
                [self setState:PNLiteVASTPlayerState_IDLE];
                if (self.playerItem.error) {
                    [self invokeDidFailLoadingWithError:self.playerItem.error];
                } else {
                    [self invokeDidFailLoadingWithError:[NSError errorWithDomain:@"Something went wrong with the AVPlayerItem." code:0 userInfo:nil]];
                }
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
    Float64 currentSkippablePlayedPercent = 0;
    
    if (self.skipOffset > 0 && self.skipOffset < currentDuration) {
        currentSkippablePlayedPercent = currentPlaybackTime / self.skipOffset;

        if (currentPlaybackTime >= self.skipOffset - 0.5) { // -0.5 for more smooth transition between circular progress view and close button
            self.btnClose.hidden = NO;
            [self.viewSkip removeFromSuperview];
        } else {
            self.viewSkip.hidden = NO;
        }
        
        if (self.skipOffset - currentPlaybackTime > 1) { // to prevent displaying 0 inside of the circle
            self.progressLabel.text = [NSString stringWithFormat:@"%.f", self.skipOffset - currentPlaybackTime];
        }
        
        if (currentSkippablePlayedPercent > 0) {
            [self startCircularProgressBarAnimationWithProgress:currentSkippablePlayedPercent];
        }

    }
    
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
}

- (void)startBottomProgressBarAnimationWithProgress:(Float64)progress
{
    [UIView animateWithDuration:progress delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.viewProgress setProgress:progress animated:YES];
    } completion:nil];
}

- (void)startCircularProgressBarAnimationWithProgress:(Float64)progress
{
    [self.progressLabel setProgress:progress];
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

#pragma mark IBActions

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
    [self invokeDidClose];
}

- (IBAction)btnOpenOfferPush:(id)sender {
    if (self.isRewarded && [self currentPlaybackTime] != 0) {
        if (self.player.rate != 0 && self.player.error == nil) { // isPlaying
            [self.viewProgress setProgress:[self currentPlaybackTime] / [self duration]];
            for (CALayer *layer in self.viewProgress.layer.sublayers) {
                [layer removeAllAnimations];
            }
            [self setPauseState];
        } else {
            [self setPlayState];
        }
        return;
    }
    
    HyBidVASTVideoClicks *videoClicks = [[HyBidVASTVideoClicks alloc] initWithDocumentArray:self.vastDocumentArray];
    NSArray<HyBidVASTVideoClick *> *trackingClicks = [videoClicks trackingClicks];
    NSArray<HyBidVASTVideoClick *> *throughClicks = [videoClicks throughClicks];
    
    NSMutableArray<NSString *> *trackingClickURLs = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *throughClickURLs = [[NSMutableArray alloc] init];
    
    if (trackingClicks != nil) {
        for (HyBidVASTVideoClick *click in trackingClicks) {
            [trackingClickURLs addObject:[click url]];
        }
    }
    if (throughClicks != nil) {
        for (HyBidVASTVideoClick *click in throughClicks) {
            [throughClickURLs addObject:[click url]];
        }
    }
    
    if ([trackingClickURLs count] > 0) {
        [self.vastEventProcessor sendVASTUrls:trackingClickURLs];
    }
    
    [self invokeDidClickOffer];
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_click];
    
    if (self.skAdModel) {
        NSDictionary* productParams = [self.skAdModel getStoreKitParameters];
        if ([productParams count] > 0) {
            if (throughClicks != nil && [throughClicks count] > 0) {
                [[HyBidURLDriller alloc] startDrillWithURLString:[[throughClicks firstObject] url] delegate:self];
            }
                        
            dispatch_async(dispatch_get_main_queue(), ^{
                HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters:productParams];

                [[UIApplication sharedApplication].topViewController presentViewController:skAdnetworkViewController animated:true completion:nil];
            });
        } else {
            if (throughClicks != nil && [throughClicks count] > 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[throughClicks firstObject] url]]];
            }
        }
    } else {
        if (throughClicks != nil && [throughClicks count] > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[throughClicks firstObject] url]]];
        }
    }
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
            self.btnMuteTopConstraint.constant = -topPadding;
            self.btnMuteLeadingConstraint.constant = leadingPadding;
            self.contentInfoViewContainerTopConstraint.constant = -topPadding;
            self.contentInfoViewContainerLeadingConstraint.constant = leadingPadding;
            self.viewSkipTopConstraint.constant = topPadding + PNLiteVASTPlayerViewSkipTopConstant;
            self.viewSkipTrailingConstraint.constant = trailingPadding + PNLiteVASTPlayerViewSkipTrailingConstant;
            self.viewProgressBottomConstraint.constant = -bottomPadding;
            self.viewProgressLeadingConstraint.constant = leadingPadding;
            self.viewProgressTrailingConstraint.constant = trailingPadding;
        } else {
            self.btnOpenOfferBottomConstraint.constant = 0;
            self.btnOpenOfferLeadingConstraint.constant = 0;
            self.btnMuteTopConstraint.constant = 0;
            self.btnMuteLeadingConstraint.constant = 0;
            self.contentInfoViewContainerTopConstraint.constant = 0;
            self.contentInfoViewContainerLeadingConstraint.constant = 0;
            self.viewSkipTopConstraint.constant = PNLiteVASTPlayerViewSkipTopConstant;
            self.viewSkipTrailingConstraint.constant = PNLiteVASTPlayerViewSkipTrailingConstant;
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
        [self.player removeTimeObserver:self.playbackToken];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    if(self.currentState == PNLiteVASTPlayerState_PLAY) {
        [self setPauseState];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification {
    if(self.currentState == PNLiteVASTPlayerState_PLAY ||
       self.currentState == PNLiteVASTPlayerState_PAUSE) {
        [self setPlayState];
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification {
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_complete];
    [self.player pause];
    [self.playerItem seekToTime:kCMTimeZero];
    [self setState:PNLiteVASTPlayerState_READY];
    [self invokeDidComplete];
    self.btnClose.hidden = NO;
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
    self.btnClose.hidden = self.isInterstitial;
    self.btnOpenOffer.hidden = YES;
    self.viewSkip.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];
    
    [self close];
}

- (void)setLoadState {
    self.loadingSpin.hidden = NO;
    self.btnMute.hidden = YES;
    self.btnClose.hidden = self.isInterstitial;
    self.btnOpenOffer.hidden = YES;
    self.viewSkip.hidden = YES;
    self.viewProgress.hidden = YES;
    self.wantsToPlay = NO;
    [self.loadingSpin startAnimating];
    
    if (self.videoAdCacheItem.vastModel) {
        HyBidVASTAd *firstCachedAd = [[self.videoAdCacheItem.vastModel ads] firstObject];
        HyBidVASTCreative *firstCachedCreative = [[firstCachedAd creatives] firstObject];
        HyBidVASTLinear *cachedLinear = [firstCachedCreative linear];
        NSArray<HyBidVASTTrackingEvent *> *cachedTrackingEvents = [cachedLinear trackingEvents];
        
        HyBidVASTMediaFiles *cachedMediaFiles = [cachedLinear mediaFiles];
        NSString *mediaUrl = [HyBidVASTMediaFilePicker pick:[cachedMediaFiles mediaFiles]].url;
        
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEvents:cachedTrackingEvents delegate:self];
        if ([self.videoAdCacheItem.vastModel ads].count > 0) {
            if(!mediaUrl) {
                [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Did not find a compatible media file."];
                NSError *mediaNotFoundError = [NSError errorWithDomain:@"Not found compatible media with this device." code:HyBidErrorCodeInternal userInfo:nil];
                [self invokeDidFailLoadingWithError:mediaNotFoundError];
            } else {
                self.hyBidVastModel = self.videoAdCacheItem.vastModel;
                
                HyBidVASTAd *firstAd = [[self.hyBidVastModel ads] firstObject];
                HyBidVASTCreative *firstCreative = [[firstAd creatives] firstObject];
                HyBidVASTLinear *linear = [firstCreative linear];
                if ([[linear skipOffset] integerValue] != -1 && self.skipOffset <= 0) {
                    self.skipOffset = [[linear skipOffset] integerValue];
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
                NSArray<HyBidVASTTrackingEvent *> *events = [[[HyBidVASTTrackingEvents alloc] initWithDocumentArray:self.vastDocumentArray] trackingEvents];
                weakSelf.vastEventProcessor = [[HyBidVASTEventProcessor alloc] initWithEvents:events delegate:self];
                
                HyBidVASTMediaFiles *mediaFiles = [[HyBidVASTMediaFiles alloc] initWithDocumentArray:self.vastDocumentArray];
                NSString *mediaUrl = [HyBidVASTMediaFilePicker pick:[mediaFiles mediaFiles]].url;
                weakSelf.hyBidVastModel = model;
                if (weakSelf.hyBidVastModel.ads.count > 0) {
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
    self.viewSkip.hidden = YES;
    self.viewProgress.hidden = YES;
    self.loadingSpin.hidden = YES;
    
    if(!self.layer) {
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.layer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.layer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.layer atIndex:0];
    }
    
    if(!self.progressLabel) {
        self.progressLabel = [[PNLiteProgressLabel alloc] initWithFrame:self.viewSkip.bounds];
        self.progressLabel.frame = self.viewSkip.bounds;
        self.progressLabel.borderWidth = 3.0;
        self.progressLabel.colorTable = @{
                                          NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelTrackColor):[UIColor clearColor],
                                          NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelProgressColor):[UIColor whiteColor],
                                          NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelFillColor):[UIColor clearColor]
                                          };
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.shadowColor = [UIColor darkGrayColor];
        self.progressLabel.shadowOffset = CGSizeMake(1, 1);
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        
        [self.progressLabel setProgress:0.0f];
        [self.viewSkip addSubview:self.progressLabel];
    }
    self.progressLabel.text = [NSString stringWithFormat:@"%ld", (long)self.skipOffset];
}

- (void)setPlayState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    
    if ([HyBidSettings sharedInstance].interstitialActionBehaviour == HB_ACTION_BUTTON) {
        self.btnOpenOffer.hidden = NO;
    }
    self.viewSkip.hidden = YES;
    self.viewProgress.hidden = NO;
    self.wantsToPlay = NO;
    [self.loadingSpin stopAnimating];
    
    // Start playback
    [self.player play];
    if([self currentPlaybackTime]  > 0) {
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_resume];
    } else {
        if (self.hyBidVastModel.ads.count >0 && self.hyBidVastModel.ads.firstObject.impressions.count > 0) {
            [self.vastEventProcessor trackImpression: [[self.hyBidVastModel.ads firstObject].impressions firstObject]];
        }
        [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_start];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDStartEventWithDuration:[self duration] withVolume:self.player.volume];
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDImpressionOccuredEvent:self.adSession];
    }
    if (self.isInterstitial) {
        [[HyBidViewabilityNativeVideoAdSession sharedInstance] fireOMIDPlayerStateEventWithFullscreenInfo:YES];
    }
    [self invokeDidStartPlaying];
}

- (void)setPauseState {
    self.loadingSpin.hidden = YES;
    self.btnMute.hidden = NO;
    
    if ([HyBidSettings sharedInstance].interstitialActionBehaviour == HB_ACTION_BUTTON) {
        self.btnOpenOffer.hidden = NO;
    }
    
    if (self.isInterstitial) {
        if (!self.isRewarded) {
            self.viewSkip.hidden = NO;
        }
    }
    
    self.viewProgress.hidden = NO;
    [self.loadingSpin stopAnimating];
    
    [self.player pause];
    [self.vastEventProcessor trackEventWithType:HyBidVASTAdTrackingEventType_pause];
    [self invokeDidPause];
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
