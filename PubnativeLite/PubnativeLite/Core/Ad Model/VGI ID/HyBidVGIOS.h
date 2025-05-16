// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIOS : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *buildSignature;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
