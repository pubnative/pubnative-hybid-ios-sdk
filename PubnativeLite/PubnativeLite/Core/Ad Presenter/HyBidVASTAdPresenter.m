// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTAdPresenter.h"
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVideoAdCache.h"
#import "HyBidVideoAdCacheItem.h"

CGFloat const PNLiteVASTMRectWidth = 300.0f;
CGFloat const PNLiteVASTMRectHeight = 250.0f;

@interface HyBidVASTAdPresenter () <PNLiteVASTPlayerViewControllerDelegate>

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;

@end

@implementation HyBidVASTAdPresenter

- (void)dealloc {
    self.adModel = nil;
    self.player = nil;
    self.videoAdCacheItem = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.isLoaded = NO;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:self.adModel withAdFormat:HyBidAdFormatBanner];
    self.player.delegate = self;
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

- (void)startTracking {
    [self.player play];
    if ([self.delegate respondsToSelector:@selector(adPresenterDidAppear:)]) {
        [self.delegate adPresenterDidAppear:self];
    }
}

- (void)stopTracking {
    [self.player stop];
}

- (UIView *)buildContainerWithVASTPlayer:(PNLiteVASTPlayerViewController *)player {
    UIView *playerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PNLiteVASTMRectWidth, PNLiteVASTMRectHeight)];
    player.view.frame = playerContainer.bounds;
    [playerContainer addSubview:player.view];
    return playerContainer;
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer {
    if (!self.isLoaded) {
        self.isLoaded = YES;
        [self.delegate adPresenter:self didLoadWithAd:[self buildContainerWithVASTPlayer:vastPlayer]];
    }
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error {
    [self.delegate adPresenter:self didFailWithError:error];
}

- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController *)vastPlayer {
    if ([self.delegate respondsToSelector:@selector(adPresenterDidStartPlaying:)]) {
        [self.delegate adPresenterDidStartPlaying:self];
    }
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer {
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.delegate adPresenterDidClick:self];
    if ([self.delegate respondsToSelector:@selector(adPresenterDidDisappear:)]) {
        [self.delegate adPresenterDidDisappear:self];
    }
}

- (void)vastPlayerDidCloseOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    if ([self.delegate respondsToSelector:@selector(adPresenterDidAppear:)]) {        
        [self.delegate adPresenterDidAppear:self];
    }
}

- (void)vastPlayerDidShowEndCard:(PNLiteVASTPlayerViewController *)vastPlayer endcard:(HyBidEndCard *)endcard {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adPresenterDidPresentCustomEndCard:)]) {
        [self.delegate adPresenterDidPresentCustomEndCard:self];
    }
}

- (void)vastPlayerDidReplay {
    if ([self.delegate respondsToSelector:@selector(adPresenterDidReplay)]) {
        [self.delegate adPresenterDidReplay];
    }
}

@end
