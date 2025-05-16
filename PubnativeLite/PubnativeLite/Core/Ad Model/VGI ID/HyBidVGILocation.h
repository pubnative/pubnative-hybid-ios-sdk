// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGILocation : NSObject

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) NSString *accuracy;
@property (nonatomic, strong) NSString *ts;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
