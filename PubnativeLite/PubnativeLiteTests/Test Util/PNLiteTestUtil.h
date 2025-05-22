// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface PNLiteTestUtil : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)createMockImpressionBeaconArray;
- (NSArray *)createMockClickBeaconArray;

@end
