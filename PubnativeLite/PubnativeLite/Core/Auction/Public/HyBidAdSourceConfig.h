//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidBaseModel.h"

@interface HyBidAdSourceConfig : HyBidBaseModel

@property (nonatomic, assign) double eCPM;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* vastTagUrl;
@property (nonatomic, strong) NSString* type;

@end
