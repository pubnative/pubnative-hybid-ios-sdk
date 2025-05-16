// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIApl : NSObject

@property (nonatomic, strong) NSString *IDFA;
@property (nonatomic, strong) NSString *IDFV;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
