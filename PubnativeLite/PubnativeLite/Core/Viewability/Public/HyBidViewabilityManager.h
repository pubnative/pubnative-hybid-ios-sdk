// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "OMIDAdSessionWrapper.h"

@interface HyBidViewabilityManager : NSObject

@property (nonatomic, assign) BOOL viewabilityMeasurementEnabled;
@property (nonatomic, assign, readonly) BOOL isViewabilityMeasurementActivated;

@property (nonatomic, strong) id partner;
@property (nonatomic, strong) OMIDAdSessionWrapper *omidAdSession;
@property (nonatomic, strong) OMIDAdSessionWrapper *omidMediaAdSession;
@property (nonatomic, strong) id adEvents;
@property (nonatomic, strong) id omidMediaEvents;

+ (instancetype)sharedInstance;
- (NSString *)getOMIDJS;
- (id)getAdEvents:(OMIDAdSessionWrapper *)omidAdSessionWrapper;
- (id)getMediaEvents:(OMIDAdSessionWrapper *)omidAdSessionWrapper;
- (void)reportEvent:(NSString *)eventType;

@end

