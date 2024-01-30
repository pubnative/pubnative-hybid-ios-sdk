//
//  Copyright © 2020 PubNative. All rights reserved.
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

- (void)vastPlayerDidClose:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter hideFromViewController:self];
    [self.presenter.delegate rewardedPresenterDidDismiss:self.presenter];
}

- (void)vastPlayerDidCloseOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate rewardedPresenterDidAppear:self.presenter];
}

- (void)vastPlayerWillShowEndCard:(PNLiteVASTPlayerViewController *)vastPlayer {
    self.skAdModel = self.adModel.isUsingOpenRTB ? self.adModel.getOpenRTBSkAdNetworkModel : self.adModel.getSkAdNetworkModel;
    if ([self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] != [NSNull null] && [self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] && [[self.skAdModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] intValue] == -1) {
        if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDismissesSKOverlay:)]) {
            [self.presenter.delegate rewardedPresenterDismissesSKOverlay:self.presenter];
        }
    } else {        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VASTEndCardWillShow" object:nil];
    }
}

- (void)vastPlayerDidShowEndCard:(PNLiteVASTPlayerViewController *)vastPlayer endcard:(HyBidVASTEndCard *)endcard {
    if (self.presenter.delegate && [self.presenter.delegate respondsToSelector:@selector(rewardedPresenterDismissesCustomCTA:)] && endcard.isCustomEndCard) {
        [self.presenter.delegate rewardedPresenterDismissesCustomCTA:self.presenter];
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
