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

#import "PNLiteVASTMRectPresenter.h"
#import "PNLiteVASTPlayerViewController.h"

CGFloat const kPNLiteVASTMRectWidth = 300.0f;
CGFloat const kPNLiteVASTMRectHeight = 250.0f;

@interface PNLiteVASTMRectPresenter () <PNLiteVASTPlayerViewControllerDelegate>

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;
@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation PNLiteVASTMRectPresenter

- (void)dealloc {
    self.adModel = nil;
    self.player = nil;
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
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithContentInfo:self.adModel.contentInfo isInterstital:NO];
    self.player.delegate = self;
    [self.player loadWithVastString:self.adModel.vast];
}

- (void)startTracking {
    [self.player play];
}

- (void)stopTracking {
    [self.player stop];
}

- (UIView *)buildContainerWithVASTPlayer:(PNLiteVASTPlayerViewController *)player {
    UIView *playerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kPNLiteVASTMRectWidth, kPNLiteVASTMRectHeight)];
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
    
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.delegate adPresenterDidClick:self];
}

@end
