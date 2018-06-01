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

CGFloat const kPNLiteVASTMRectXPosition = 0.0f;
CGFloat const kPNLiteVASTMRectYPosition = 0.0f;
CGFloat const kPNLiteVASTMRectWidth = 300.0f;
CGFloat const kPNLiteVASTMRectHeight = 250.0f;

@interface PNLiteVASTMRectPresenter () <PNLiteVASTPlayerViewControllerDelegate>

@property (nonatomic, strong) PNLiteAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;

@end

@implementation PNLiteVASTMRectPresenter

- (void)dealloc
{
    self.adModel = nil;
    self.player = nil;
}

- (instancetype)initWithAd:(PNLiteAd *)ad
{
    self = [super init];
    if (self) {
        self.adModel = ad;
    }
    return self;
}

- (PNLiteAd *)ad
{
    return self.adModel;
}

- (void)load
{
    self.player = [[PNLiteVASTPlayerViewController alloc] init];
    self.player.delegate = self;
    [self.player loadWithVastString:self.adModel.vast];
}

- (UIView *)buildContainerWithVASTPlayer:(PNLiteVASTPlayerViewController *)player
{
    UIView *playerContainer = [[UIView alloc] initWithFrame:CGRectMake(kPNLiteVASTMRectXPosition, kPNLiteVASTMRectYPosition, kPNLiteVASTMRectWidth, kPNLiteVASTMRectHeight)];
    player.view.frame = playerContainer.bounds;
    [playerContainer addSubview:player.view];
    return playerContainer;
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer
{
    //TO-DO: Handle play when using PNLiteAdView
    
    [self.delegate mRectPresenter:self didLoadWithMRect:[self buildContainerWithVASTPlayer:vastPlayer]];
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error
{
    [self.delegate mRectPresenter:self didFailWithError:error];
}

- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController *)vastPlayer
{
    
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer
{
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer
{
    
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer
{
    [self.delegate mRectPresenterDidClick:self];
}

@end
