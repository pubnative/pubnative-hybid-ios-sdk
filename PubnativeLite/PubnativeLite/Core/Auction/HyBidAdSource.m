//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdSource.h"
#import "HyBidIntegrationType.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidAdSource

- (instancetype)initWithConfig:(HyBidAdSourceConfig *)config {
    if (self) {
        self.config = config;
    }
    return self;
}

- (void)fetchAdWithZoneId:(NSString *)zoneId completionBlock:(CompletionBlock)completionBlock {
    self.adRequest = [[HyBidAdRequest alloc]init];
    self.adRequest.adSize = self.adSize;
    [self.adRequest setIntegrationType:IN_APP_BIDDING withZoneID:zoneId];
    [self.adRequest requestAdWithDelegate:self withZoneID:zoneId];
    self.completionBlock = completionBlock;
}

//MARK: HyBidAdRequestDelegate
- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    self.completionBlock(ad, nil);
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ failed with error: %@",request, error.localizedDescription]];
    self.completionBlock(nil, error);
}

@end
