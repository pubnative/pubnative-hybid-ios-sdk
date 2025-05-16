// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVGIBattery.h"
#import "HyBidVGIOS.h"

@interface HyBidVGIDevice : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) HyBidVGIOS *OS;
@property (nonatomic, strong) NSString *manufacture;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) HyBidVGIBattery *battery;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
