////
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

#import "AppMonetBannerManager.h"
#import "AppMonetConstants.h"
#import "AppMonetBid.h"

@implementation AppMonetBannerManager

- (id)initWithDelegate:(id <AppMonetBannerManagerDelegate>)delegate andAdView:(AppMonetBannerView *)adView {
    self = [super init];
    self.delegate = delegate;
    self.adView = adView;
    return self;
}

- (void)loadAd:(CGSize)size {
    NSDictionary *localExtras = @{
        kAMAdUnitKeywordKey: _adUnitId,
        kAMAdSizeKey: [NSValue valueWithCGSize:size]
    };
    [self loadCustomEvent:localExtras withHandler:nil];
}

- (void)makeRequest:(NSDictionary *)requestExtras withHandler:(void (^)(AppMonetBid *bid))handler {
    NSMutableDictionary *localExtras= [[NSMutableDictionary alloc] initWithDictionary:requestExtras];
    [localExtras addEntriesFromDictionary:@{
        kAMAdUnitKeywordKey: _adUnitId
    }];
    [self loadCustomEvent:localExtras withHandler:handler];
}

- (void)adViewContent:(UIView *)bannerView {

    if (self.adView == nil) {
        return;
    }
    NSArray *viewsToRemove = [self.adView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self.adView addSubview:bannerView];
}

- (void)loadCustomEvent:(NSDictionary *)localExtras withHandler:(void (^)(AppMonetBid *bid))handler {
    [self.adView loadCustomEventAdapter:localExtras withHandler:handler];
}


@end
