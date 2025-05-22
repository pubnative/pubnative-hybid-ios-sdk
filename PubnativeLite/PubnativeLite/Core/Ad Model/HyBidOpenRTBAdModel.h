// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidOpenRTBBaseModel.h"
#import "HyBidOpenRTBDataModel.h"

@interface HyBidOpenRTBAdModel : HyBidOpenRTBBaseModel

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *creativeid;
@property (nonatomic, strong) NSNumber *assetgroupid;
@property (nonatomic, strong) NSMutableArray<HyBidOpenRTBDataModel*> *assets;
@property (nonatomic, strong) NSArray<HyBidOpenRTBDataModel*> *beacons;
@property (nonatomic, strong) NSArray<HyBidOpenRTBDataModel*> *extensions;

- (HyBidOpenRTBDataModel *)assetWithType:(NSString *)type;
- (HyBidOpenRTBDataModel *)extensionWithType:(NSString *)type;
- (NSArray *)beaconsWithType:(NSString *)type;

@end
