// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIBattery : NSObject

@property (nonatomic, strong) NSString *capacity;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
