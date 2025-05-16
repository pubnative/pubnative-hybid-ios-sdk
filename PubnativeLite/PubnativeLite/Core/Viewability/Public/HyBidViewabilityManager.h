// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

@class OMIDPubnativenetPartner;
@class OMIDPubnativenetAdEvents;
@class OMIDPubnativenetAdSession;
@class OMIDPubnativenetMediaEvents;

#import <Foundation/Foundation.h>

@interface HyBidViewabilityManager : NSObject

@property (nonatomic, assign) BOOL viewabilityMeasurementEnabled;
@property (nonatomic, assign) BOOL isViewabilityMeasurementActivated;
@property (nonatomic, strong) OMIDPubnativenetPartner *partner;
@property (nonatomic, strong) OMIDPubnativenetAdSession *omidAdSession;
@property (nonatomic, strong) OMIDPubnativenetAdSession *omidMediaAdSession;
@property (nonatomic, strong) OMIDPubnativenetAdEvents *adEvents;
@property (nonatomic, strong) OMIDPubnativenetMediaEvents *omidMediaEvents;

+ (instancetype)sharedInstance;
- (NSString *)getOMIDJS;
- (OMIDPubnativenetAdEvents *)getAdEvents:(OMIDPubnativenetAdSession*)omidAdSession;
- (OMIDPubnativenetMediaEvents *)getMediaEvents:(OMIDPubnativenetAdSession*)omidAdSession;
- (void) reportEvent: (NSString*)eventType;

@end
