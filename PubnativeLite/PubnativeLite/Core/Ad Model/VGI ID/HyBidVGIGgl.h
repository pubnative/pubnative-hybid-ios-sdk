// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIGgl : NSObject

@property (nonatomic, strong) NSString *GAID;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
