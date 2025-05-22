// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidConfigModel.h"

@interface HyBidConfig : NSObject

@property (nonatomic, readonly) BOOL atomEnabled;

- (instancetype)initWithData:(HyBidConfigModel *)data;

- (HyBidDataModel *)appLevelDataWithType:(NSString *)type;

@end
