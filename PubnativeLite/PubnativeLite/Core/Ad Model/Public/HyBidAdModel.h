// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidBaseModel.h"
#import "HyBidDataModel.h"

@interface HyBidAdModel : HyBidBaseModel

@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSNumber *assetgroupid;
@property (nonatomic, strong) NSMutableArray<HyBidDataModel*> *assets;
@property (nonatomic, strong) NSArray<HyBidDataModel*> *beacons;
@property (nonatomic, strong) NSArray<HyBidDataModel*> *meta;

- (HyBidDataModel *)assetWithType:(NSString *)type;
- (HyBidDataModel *)metaWithType:(NSString *)type;
- (NSArray *)beaconsWithType:(NSString *)type;

@end
