// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGITtd : NSObject

@property (nonatomic, strong) NSString *IDL;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
