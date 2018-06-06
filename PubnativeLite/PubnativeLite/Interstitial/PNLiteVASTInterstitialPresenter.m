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

#import "PNLiteVASTInterstitialPresenter.h"
#import "PNLiteVASTPlayerViewController.h"

@interface PNLiteVASTInterstitialPresenter() <PNLiteVASTPlayerViewControllerDelegate>

@property (nonatomic, strong) PNLiteAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;

@end

@implementation PNLiteVASTInterstitialPresenter

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
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithContentInfo:self.adModel.contentInfo isInterstital:YES];
    self.player.delegate = self;
    [self.player loadWithVastString:self.adModel.vast];
}

- (void)show
{
    [self.player showAsInterstitial];
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer
{
    [self.delegate interstitialPresenterDidLoad:self];
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error
{
    [self.delegate interstitialPresenter:self didFailWithError:error];
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
    [self.delegate interstitialPresenterDidClick:self];
}

@end
