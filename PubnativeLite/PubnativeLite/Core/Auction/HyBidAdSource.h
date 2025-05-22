//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAdRequest.h"
#import "HyBidAdSourceConfig.h"
#import "HyBidAdSourceAbstract.h"

@interface HyBidAdSource : HyBidAdSourceAbstract<HyBidAdRequestDelegate>

@property (nonatomic, strong) HyBidAdRequest *adRequest;
@property (nonatomic, strong) HyBidAdSourceConfig *config;
@property (nonatomic, strong) HyBidAdSize *adSize;

- (instancetype)initWithConfig:(HyBidAdSourceConfig *)config;

@end
