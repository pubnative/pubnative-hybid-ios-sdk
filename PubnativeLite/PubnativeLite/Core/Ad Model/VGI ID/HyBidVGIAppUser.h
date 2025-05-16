// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIAppVendor.h"

@interface HyBidVGIAppUser : NSObject

@property (nonatomic, strong) NSString *AUID;
@property (nonatomic, strong) NSString *SUID;
@property (nonatomic, strong) HyBidVGIAppVendor *vendor;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
