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

#import "PNLiteVASTPlayerInterstitialViewController.h"
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVideoAdCache.h"
#import "HyBidVideoAdCacheItem.h"

@interface PNLiteVASTPlayerInterstitialViewController () <PNLiteVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;
@property (nonatomic, strong) HyBidInterstitialPresenter *presenter;
@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;

@end

@implementation PNLiteVASTPlayerInterstitialViewController

- (void)dealloc {
    [self.player stop];
    self.player = nil;
    self.presenter = nil;
    self.adModel = nil;
    self.videoAdCacheItem = nil;
}

- (instancetype)init {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithNibName:[self nameForResource:@"PNLiteVASTPlayerInterstitialViewController": @"nib"] bundle:currentBundle];
    self.view = [currentBundle loadNibNamed:[self nameForResource:@"PNLiteVASTPlayerInterstitialViewController":@"nib"]
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

- (void)loadFullScreenPlayerWithPresenter:(HyBidInterstitialPresenter *)interstitialPresenter withAd:(HyBidAd *)ad withSkipOffset:(NSInteger)skipOffset {
    self.presenter = interstitialPresenter;
    self.adModel = ad;
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithAdModel:self.adModel isInterstital:YES];
    self.player.delegate = self;
    self.player.skipOffset = skipOffset;
    if (self.adModel.zoneID != nil && self.adModel.zoneID.length > 0) {
        self.videoAdCacheItem = [[HyBidVideoAdCache sharedInstance] retrieveVideoAdCacheItemFromCacheWithZoneID:self.adModel.zoneID];
        if (!self.videoAdCacheItem) {
            [self.player loadWithVastString:self.adModel.vast];
        } else {
            [self.player loadWithVideoAdCacheItem:self.videoAdCacheItem];
        }
    } else {
        [self.player loadWithVastString:self.adModel.vast];
    }
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer {
    self.player = vastPlayer;
    self.player.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:self.player.view];
    [self.presenter.delegate interstitialPresenterDidLoad:self.presenter];
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error {
    [self.presenter.delegate interstitialPresenter:self.presenter didFailWithError:error];
}

- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate interstitialPresenterDidShow:self.presenter];
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer {
    if (self.closeOnFinish) {
        [self.presenter hide];
        [self.presenter.delegate interstitialPresenterDidDismiss:self.presenter];
    }
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate interstitialPresenterDidClick:self.presenter];
    [self.presenter.delegate interstitialPresenterDidDisappear:self.presenter];
}

- (void)vastPlayerDidClose:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter hide];
    [self.presenter.delegate interstitialPresenterDidDismiss:self.presenter];
}

- (void)vastPlayerDidCloseOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate interstitialPresenterDidAppear:self.presenter];
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
