// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIEmail.h"
#import "HyBidVGIUserVendor.h"
#import "HyBidVGILocation.h"
#import "HyBidVGIAudience.h"

@interface HyBidVGIUser : NSObject

@property (nonatomic, strong) NSString *SUID;
@property (nonatomic, strong) NSArray<HyBidVGIEmail *> *emails;
@property (nonatomic, strong) HyBidVGIUserVendor *vendor;
@property (nonatomic, strong) NSArray<HyBidVGILocation *> *locations;
@property (nonatomic, strong) NSArray<HyBidVGIAudience *> *audiences;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
