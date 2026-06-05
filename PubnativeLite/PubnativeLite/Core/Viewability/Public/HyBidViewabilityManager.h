// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidOMIDAdSessionWrapper.h"

@interface HyBidViewabilityManager : NSObject

@property (nonatomic, assign) BOOL viewabilityMeasurementEnabled;
@property (nonatomic, assign, readonly) BOOL isViewabilityMeasurementActivated;

@property (nonatomic, strong) id partner;
@property (nonatomic, strong) HyBidOMIDAdSessionWrapper *omidAdSession;
@property (nonatomic, strong) HyBidOMIDAdSessionWrapper *omidMediaAdSession;
@property (nonatomic, strong) id adEvents;
@property (nonatomic, strong) id omidMediaEvents;

+ (instancetype)sharedInstance;
- (NSString *)getOMIDJS;
- (id)getAdEvents:(HyBidOMIDAdSessionWrapper *)omidAdSessionWrapper;
- (id)getMediaEvents:(HyBidOMIDAdSessionWrapper *)omidAdSessionWrapper;
- (void)reportEvent:(NSString *)eventType;

@end

