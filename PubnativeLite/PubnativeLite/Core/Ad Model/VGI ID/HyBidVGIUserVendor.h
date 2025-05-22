// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIGgl.h"
#import "HyBidVGIApl.h"

@interface HyBidVGIUserVendor : NSObject

@property (nonatomic, strong) HyBidVGIGgl *GGL;
@property (nonatomic, strong) HyBidVGIApl *APL;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
