// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidBaseModel : NSObject

@property (nonatomic, strong) NSDictionary *dictionary;

+ (NSArray *)parseArrayValues:(NSArray *)array;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
