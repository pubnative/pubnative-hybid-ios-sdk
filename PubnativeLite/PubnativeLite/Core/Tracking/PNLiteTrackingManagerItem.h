// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface PNLiteTrackingManagerItem : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong )NSNumber *timestamp;

- (NSDictionary *)toDictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
