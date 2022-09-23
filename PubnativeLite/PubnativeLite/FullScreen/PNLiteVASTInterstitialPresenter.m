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
#import "PNLiteVASTPlayerInterstitialViewController.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteVASTInterstitialPresenter()

@property (nonatomic, strong) HyBidAd *adModel;
@property (nonatomic, strong) PNLiteVASTPlayerInterstitialViewController *vastViewController;

@end

@implementation PNLiteVASTInterstitialPresenter

- (void)dealloc {
    self.adModel = nil;
    self.vastViewController = nil;
}

- (instancetype)initWithAd:(HyBidAd *)ad
            withSkipOffset:(NSInteger)skipOffset
         withCloseOnFinish:(BOOL)closeOnFinish {
    self = [super init];
    if (self) {
        self.adModel = ad;
        self.skipOffset = skipOffset;
        self.closeOnFinish = closeOnFinish;
    }
    return self;
}

- (HyBidAd *)ad {
    return self.adModel;
}

- (void)load {
    self.vastViewController = [PNLiteVASTPlayerInterstitialViewController new];
    self.vastViewController.closeOnFinish = self.closeOnFinish;
    [self.vastViewController setModalPresentationStyle: UIModalPresentationFullScreen];
    [self.vastViewController loadFullScreenPlayerWithPresenter:self withAd:self.adModel withSkipOffset:self.skipOffset];
}

- (void)show {
    [[UIApplication sharedApplication].topViewController presentViewController:self.vastViewController animated:NO completion:nil];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [viewController presentViewController:self.vastViewController animated:NO completion:nil];
}

- (void)hide {
    UIViewController *topViewController = [UIApplication sharedApplication].topViewController;
    
    if ([topViewController isKindOfClass:[HyBidSKAdNetworkViewController class]]) {
        [topViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    } else {
        [[UIApplication sharedApplication].topViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
