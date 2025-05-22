// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIPrivacy : NSObject

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *TCFv1;
@property (nonatomic, strong) NSString *TCFv2;
@property (nonatomic, strong) NSString *iabCCPA;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
