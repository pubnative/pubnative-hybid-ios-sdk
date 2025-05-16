// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteTestUtil.h"
#import "HyBidDataModel.h"

@implementation PNLiteTestUtil

+ (instancetype)sharedInstance
{
    static PNLiteTestUtil *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteTestUtil alloc] init];
    });
    return _instance;
}

- (NSArray *)createMockImpressionBeaconArray
{
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"validImpressionURL",@"url", nil];
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"impression", @"type", urlDictionary, @"data", nil];
    HyBidDataModel * dataModel = [[HyBidDataModel alloc] initWithDictionary:dataDictionary];
    return [[NSArray array] arrayByAddingObject:dataModel];
}

- (NSArray *)createMockClickBeaconArray
{
    NSDictionary *urlDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"validClickURL",@"url", nil];
    NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"click", @"type", urlDictionary, @"data", nil];
    HyBidDataModel * dataModel = [[HyBidDataModel alloc] initWithDictionary:dataDictionary];
    return [[NSArray array] arrayByAddingObject:dataModel];
}

@end
