// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIApp.h"
#import "HyBidVGIDevice.h"
#import "HyBidVGIUser.h"

@interface HyBidVGIModel : NSObject

@property (nonatomic, strong) NSArray<HyBidVGIApp *> *apps;
@property (nonatomic, strong) HyBidVGIDevice *device;
@property (nonatomic, strong) NSArray<HyBidVGIUser *> *users;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
