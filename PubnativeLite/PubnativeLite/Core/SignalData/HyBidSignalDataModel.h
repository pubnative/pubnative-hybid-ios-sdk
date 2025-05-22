// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"
#import "PNLiteResponseModel.h"

@interface HyBidSignalDataModel : HyBidBaseModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *tagid;
@property (nonatomic, strong) NSString *admurl;
@property (nonatomic, strong) PNLiteResponseModel *adm;

@end
