// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidVGIEmail : NSObject

@property (nonatomic, strong) NSString *bundleID;

- (instancetype)initWithJSON:(id)json;
- (NSDictionary *)dictionary;

@end
