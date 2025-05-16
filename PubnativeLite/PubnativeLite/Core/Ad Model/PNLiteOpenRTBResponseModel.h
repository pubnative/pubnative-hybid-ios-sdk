// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidOpenRTBBaseModel.h"

@interface PNLiteOpenRTBResponseModel : HyBidOpenRTBBaseModel

@property (nonatomic, strong) NSArray *bids;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
