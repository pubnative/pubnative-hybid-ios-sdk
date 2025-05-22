//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAdSourceConfig.h"
#import "HyBidAdSize.h"
#import "HyBidAdSourceAbstract.h"
#import "PNLiteHttpRequest.h"

@interface HyBidVastTagAdSource : HyBidAdSourceAbstract<PNLiteHttpRequestDelegate>

@property (nonatomic, strong) HyBidAdSourceConfig *config;
@property (nonatomic, strong) HyBidAdSize *adSize;

- (instancetype)initWithConfig:(HyBidAdSourceConfig *)config;

@end
