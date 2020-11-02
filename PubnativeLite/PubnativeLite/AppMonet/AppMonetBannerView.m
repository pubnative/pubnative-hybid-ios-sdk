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

#import "AppMonetBannerView.h"
#import "AppMonetConstants.h"
#import "AppMonetBannerManagerDelegate.h"
#import "AppMonetBannerManager.h"
//#import "AMOCustomEventBannerAdapter.h"
#import "AppMonetBid.h"

CGSize const MONET_BANNER_SIZE = {.width = 320.0f, .height = 50.0f};
CGSize const MONET_MEDIUM_RECT_SIZE = {.width = 300.0f, .height = 250.0f};

@interface AppMonetBannerView () <AppMonetBannerManagerDelegate>
@property(nonatomic, strong) AppMonetBannerManager *adManager;
@property(nonatomic) CGSize size;
//@property(nonatomic, strong) AMOCustomEventBannerAdapter *customEventBannerAdapter;
@end

@implementation AppMonetBannerView
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.adUnitId = adUnitId;
        self.adManager = [[AppMonetBannerManager alloc] initWithDelegate:self andAdView:self];

        self.frame = ({
            CGRect frame = self.frame;
            frame.size = [AppMonetBannerView sizeForContainer:self adSize:size adUnitId:adUnitId];
            frame;
        });
        self.adManager.adUnitId = adUnitId;
        self.size = size;
    }
    return self;
}

- (void)loadAd {
    [self.adManager loadAd:self.size];
}

- (void)requestAds:(void (^)(AppMonetBid *bid))handler {
    NSDictionary *requestExtras = @{
        kAMAdSizeKey: [NSValue valueWithCGSize:self.size]
    };
    [self.adManager makeRequest:requestExtras withHandler:handler];
}

- (void)render:(AppMonetBid *)bid {
    NSDictionary *requestExtras = @{
        kAMAdSizeKey: [NSValue valueWithCGSize:self.size],
        AMBidKey: bid.id
    };
    [self.adManager makeRequest:requestExtras withHandler:nil];
}

- (void)loadCustomEventAdapter:(NSDictionary *)localExtras withHandler:(void (^)(AppMonetBid *bid))handler {
//    if (self.customEventBannerAdapter != nil) {
//        [self invalidateAdapter];
//    }

//    AMLogDebug(@"Custom event adapter creation and load");

//    self.customEventBannerAdapter = [[AMOCustomEventBannerAdapter alloc] initWithAdView:self andLocalExtras:localExtras];
//    [self.customEventBannerAdapter loadAd:handler];
}

- (void)invalidateAdapter {
//    if (self.customEventBannerAdapter != nil) {
//        [self.customEventBannerAdapter invalidate];
//    }
}

- (void)registerClick {
    if (_bannerDelegate) {
        [_bannerDelegate wasClicked:self];
    }
}

- (void)onBannerFailed:(NSError *)error {
    if (_bannerDelegate) {
        [_bannerDelegate adError:error withBannerView:self];
    }
}

- (void)adLoaded {
    if (_bannerDelegate) {
        [_bannerDelegate adLoaded:self];
    }
}

- (void)setAdView:(UIView *)bannerView {
    if (self.adManager != nil) {
        [_adManager adViewContent:bannerView];
    }
}

- (void)dealloc {
    self.adManager = nil;
}

+ (CGSize)sizeForContainer:(UIView *_Nullable)container adSize:(CGSize)adSize adUnitId:(NSString *_Nullable)adUnitId {
    // Hydrating an ad size means resolving the `kMPFlexibleAdSize` value
    // into it's final size value based upon the container bounds.
    CGSize hydratedAdSize = adSize;

    // Hydrate the width.
    if (adSize.width == kAMFlexibleAdSize) {
        // Frame hasn't been set, issue a warning.
        if (container.bounds.size.width == 0) {}

        hydratedAdSize.width = container.bounds.size.width;
    }

    if (adSize.height == kAMFlexibleAdSize) {
        // Frame hasn't been set, issue a warning.
        if (container.bounds.size.height == 0) {}

        hydratedAdSize.height = container.bounds.size.height;
    }

    return hydratedAdSize;
}

@end
