// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdPresenter.h"

@implementation HyBidAdPresenter

- (void)dealloc {
    self.delegate = nil;
}

- (void)load {
    // Do nothing, this method should be overriden
}

- (void)loadMarkupWithSize:(HyBidAdSize *)adSize {
    // Do nothing, this method should be overriden
}

- (void)startTracking {
    // Do nothing, this method should be overriden
}

- (void)stopTracking {
    // Do nothing, this method should be overriden
}

- (HyBidAd *)ad {
    return nil;
}

@end
