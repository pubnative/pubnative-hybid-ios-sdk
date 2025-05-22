// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIApl.h"
#import "HyBidVGILr.h"
#import "HyBidVGITtd.h"

@interface HyBidVGIAppVendor : NSObject

@property (nonatomic, strong) HyBidVGIApl *APL;
@property (nonatomic, strong) HyBidVGILr *LR;
@property (nonatomic, strong) HyBidVGITtd *TTD;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
