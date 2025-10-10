// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import "HyBidViewabilityManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
    #import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
    #import <OMSDK_Smaato/OMIDImports.h>
#endif

@implementation HyBidViewabilityAdSession

+ (instancetype)sharedInstance {
    static HyBidViewabilityAdSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityAdSession alloc] init];
    });
    return sharedInstance;
}

- (void)startOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;

    if (omidAdSessionWrapper) {
        [omidAdSessionWrapper startAdSession];
        [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_STARTED];
    }
}

- (void)stopOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;

    if (omidAdSessionWrapper) {
        [omidAdSessionWrapper stopAdSession];
        [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_STOPPED];
    }
}

- (void)fireOMIDImpressionOccuredEvent:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;

    if (omidAdSessionWrapper) {
        id adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:omidAdSessionWrapper];

        if (adEvents) {
            NSError *impressionError = nil;

            if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
                #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
                [(OMIDPubnativenetAdEvents *)adEvents impressionOccurredWithError:&impressionError];
                #endif
            } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
                #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
                [(OMIDSmaatoAdEvents *)adEvents impressionOccurredWithError:&impressionError];
                #endif
            }
        }
    }

    [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.OMID_IMPRESSION];
}

- (void)fireOMIDAdLoadEvent:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;

    if (omidAdSessionWrapper) {
        [omidAdSessionWrapper fireAdLoadEvent];
    }
    [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_LOADED];
}

- (void)addFriendlyObstruction:(UIView * _Nonnull)view
               toOMIDAdSession:(OMIDAdSessionWrapper * _Nonnull)omidAdSessionWrapper
                    withReason:(NSString * _Nonnull)reasonForFriendlyObstruction
                isInterstitial:(BOOL)isInterstitial {
    
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;

    if (omidAdSessionWrapper) {
        [omidAdSessionWrapper addFriendlyObstruction:view withReason:reasonForFriendlyObstruction isInterstitial:isInterstitial]; 
    }
}

@end
