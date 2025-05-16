// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidViewabilityAdSession

+ (instancetype)sharedInstance {
    return nil;
}

- (void)startOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession start];
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_STARTED];
    }
}

- (void)stopOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession finish];
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_STOPPED];
        omidAdSession = nil;
    }
}

- (void)fireOMIDImpressionOccuredEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        OMIDPubnativenetAdEvents* adEvents = [[HyBidViewabilityManager sharedInstance]getAdEvents:omidAdSession];
        NSError *impressionError;
        [adEvents impressionOccurredWithError:&impressionError];
    }
    
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.OMID_IMPRESSION];
}

- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_LOADED];
}

- (void)addFriendlyObstruction:(UIView *)view toOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession withReason:(NSString *)reasonForFriendlyObstruction isInterstitial:(BOOL)isInterstitial {
    
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        NSError *addFriendlyObstructionError;
        if (isInterstitial) {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionCloseAd
                                   detailedReason:reasonForFriendlyObstruction
                                            error:&addFriendlyObstructionError];
        } else {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionOther
                                   detailedReason:reasonForFriendlyObstruction
                                            error:&addFriendlyObstructionError];
        }
    }
}

@end
