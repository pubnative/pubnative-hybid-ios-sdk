// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"

@interface HyBidConfigResponseModel : HyBidBaseModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSDictionary *configs;

@end
