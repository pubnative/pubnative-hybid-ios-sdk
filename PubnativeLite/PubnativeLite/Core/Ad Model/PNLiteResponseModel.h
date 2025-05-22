// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAdModel.h"
#import "HyBidBaseModel.h"

@interface PNLiteResponseModel : HyBidBaseModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSArray *ads;

@end
