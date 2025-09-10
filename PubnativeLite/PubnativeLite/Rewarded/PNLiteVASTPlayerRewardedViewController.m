// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteVASTPlayerRewardedViewController.h"
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVideoAdCache.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidSKAdNetworkParameter.h"

@interface PNLiteVASTPlayerRewardedViewController () <PNLiteVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;
@property (nonatomic, strong) HyBidRewardedPresenter *presenter;
@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) HyBidSkAdNetworkModel *skAdModel;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;

@end

@implementation PNLiteVASTPlayerRewardedViewController

- (void)dealloc {
    [self.player stop];
    self.player = nil;
    self.presenter = nil;
    self.adModel = nil;
    self.skAdModel = nil;
    self.videoAdCacheItem = nil;
}

- (instancetype)init {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerRewardedViewController": @"nib"] bundle:currentBundle];
    self.view = [currentBundle loadNibNamed:[self nameForResource:@"PNLiteVASTPlayerRewardedViewController":@"nib"]
                                      owner:self
                                    options:nil][0];;
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player stop];
}

- (void)loadFullScreenPlayerWithPresenter:(HyBidRewardedPresenter *)rewardedPresenter withAd:(HyBidAd *)ad {
    self.presenter = rewardedPresenter;
    self.presenter.customCTADelegate = self.player.customCTADelegate;
    self.presenter.skOverlayDelegate = self.player.skOverlayDelegate;
    self.adModel = ad;
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:self.adModel withAdFormat:HyBidAdFormatRewarded];
    self.player.delegate = self;
    self.player.closeOnFinish = self.closeOnFinish;
    NSString *vast = self.adModel.isUsingOpenRTB
    ? self.adModel.openRtbVast
    : self.adModel.vast;
    if (self.adModel.zoneID != nil && self.adModel.zoneID.length > 0) {
        self.videoAdCacheItem = [[HyBidVideoAdCache sharedInstance] retrieveVideoAdCacheItemFromCacheWithZoneID:self.adModel.zoneID];
        if (!self.videoAdCacheItem) {
            [self.player loadWithVastString:vast];
        } else {
            [self.player loadWithVideoAdCacheItem:self.videoAdCacheItem];
        }
    } else {
        [self.player loadWithVastString:vast];
    }
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer {
    self.player = vastPlayer;
    self.player.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:self.player.view];
    self.presenter.customCTADelegate = self.player.customCTADelegate;
    self.presenter.skOverlayDelegate = self.player.skOverlayDelegate;
    [self.presenter.delegate rewardedPresenterDidLoad:self.presenter viewController:self];
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error {
    [self.presenter.delegate rewardedPresenter:self.presenter didFailWithError:error];
}

- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate rewardedPresenterDidShow:self.presenter];
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer {
    if (self.closeOnFinish) {
        [self.presenter hideFromViewController:self];
    }
    [self.presenter.delegate rewardedPresenterDidFinish:self.presenter];
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate rewardedPresenterDidClick:self.presenter];
    [self.presenter.delegate rewardedPresenterDidDisappear:self.presenter];
}

- (void)vastPlayerDidShowSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType {
    [self.presenter.delegate rewardedPresenterDidSKOverlayAutomaticClick:self.presenter clickType:clickType];
}

- (void)vastPlayerDidShowStorekitWithClickType:(HyBidStorekitAutomaticClickType)clickType {
    [self.presenter.delegate rewardedPresenterDidStorekitAutomaticClick:self.presenter clickType:clickType];
}

- (void)vastPlayerDidShowAutoStorekit {
    [self.presenter.delegate rewardedPresenterDidClick:self.presenter];
}

- (void)vastPlayerDidClose:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter hideFromViewController:self];
    [self.presenter.delegate rewardedPresenterDidDismiss:self.presenter];
}

- (void)vastPlayerDidCloseOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate rewardedPresenterDidAppear:self.presenter];
}

- (void)vastPlayerWillShowEndCard:(PNLiteVASTPlayerViewController *)vastPlayer
                  isCustomEndCard:(BOOL)isCustomEndCard
                skOverlayDelegate:(id<HyBidSKOverlayDelegate>)skOverlayDelegate
                customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenteWillPresentEndCard:skOverlayDelegate:customCTADelegate:)]) {
        [self.presenter.delegate rewardedPresenteWillPresentEndCard:self.presenter
                                                  skOverlayDelegate:skOverlayDelegate
                                                  customCTADelegate:customCTADelegate];
    }
    
    self.skAdModel = self.adModel.isUsingOpenRTB ? self.adModel.getOpenRTBSkAdNetworkModel : self.adModel.getSkAdNetworkModel;
    if ([self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] != [NSNull null] && [self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] && [[self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] intValue] == -1) {
        if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDismissesSKOverlay:)]) {
            [self.presenter.delegate rewardedPresenterDismissesSKOverlay:self.presenter];
        }
    } else {        
        if (isCustomEndCard) {
            [HyBidInterruptionHandler.shared customEndCardWillShow];
        } else {
            [HyBidInterruptionHandler.shared endCardWillShow];
        }
    }
}

- (void)vastPlayerDidShowEndCard:(PNLiteVASTPlayerViewController *)vastPlayer endcard:(HyBidEndCard *)endcard {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDismissesCustomCTA:)] && endcard.isCustomEndCard) {
        [self.presenter.delegate rewardedPresenterDismissesCustomCTA:self.presenter];
    }
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDidPresentCustomEndCard:)] && endcard.isCustomEndCard) {
        [self.presenter.delegate rewardedPresenterDidPresentCustomEndCard:self.presenter];
    }
}

- (void)vastPlayerDidShowCustomCTA {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDidPresentsCustomCTA)]) {
        [self.presenter.delegate rewardedPresenterDidPresentsCustomCTA];
    }
}

- (void)vastPlayerDidClickCustomCTAOnEndCard:(BOOL)onEndCard {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDidClickCustomCTAOnEndCard:)]) {
        [self.presenter.delegate rewardedPresenterDidClickCustomCTAOnEndCard:onEndCard];
    }
}

- (void)vastPlayerDidReplay {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDidReplay:viewController:)]) {
        [self.presenter.delegate rewardedPresenterDidReplay:self.presenter viewController:self];
    }
}

#pragma mark - Utils: check for bundle resource existance.

- (NSString*)nameForResource:(NSString*)name :(NSString*)type {
    NSString* resourceName = [NSString stringWithFormat:@"iqv.bundle/%@", name];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:resourceName ofType:type];
    if (!path) {
        resourceName = name;
    }
    return resourceName;
}

@end
