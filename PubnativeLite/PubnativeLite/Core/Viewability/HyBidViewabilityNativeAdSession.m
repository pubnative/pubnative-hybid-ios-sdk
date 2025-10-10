// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityNativeAdSession.h"
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

@implementation HyBidViewabilityNativeAdSession

+ (instancetype)sharedInstance {
    static HyBidViewabilityNativeAdSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityNativeAdSession alloc] init];
    });
    return sharedInstance;
}

- (OMIDAdSessionWrapper *)createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return nil;

    NSError *contextError;
    id partner = [HyBidViewabilityManager sharedInstance].partner;
    
    if (!partner) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"OMID Partner is nil, cannot create ad session."];
        return nil;
    }

    id context = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:partner
                                                                     script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                                  resources:scripts
                                                                 contentUrl:nil
                                                  customReferenceIdentifier:nil
                                                                      error:&contextError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        context = [[OMIDSmaatoAdSessionContext alloc] initWithPartner:partner
                                                               script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                            resources:scripts
                                                           contentUrl:nil
                                            customReferenceIdentifier:nil
                                                                error:&contextError];
        #endif
    }

    return [self initialiseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNoneOwner];
}

- (OMIDAdSessionWrapper *)initialiseOMIDAdSessionForView:(UIView *)view
                                      withSessionContext:(id)context
                                      andImpressionOwner:(OMIDOwner)impressionOwner
                                     andMediaEventsOwner:(OMIDOwner)mediaEventsOwner {
    NSError *configurationError;
    
    id config = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay
                                                                      impressionType:OMIDImpressionTypeBeginToRender
                                                                     impressionOwner:impressionOwner
                                                                    mediaEventsOwner:mediaEventsOwner
                                                          isolateVerificationScripts:NO
                                                                               error:&configurationError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        config = [[OMIDSmaatoAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay
                                                                 impressionType:OMIDImpressionTypeBeginToRender
                                                                impressionOwner:impressionOwner
                                                               mediaEventsOwner:mediaEventsOwner
                                                     isolateVerificationScripts:NO
                                                                          error:&configurationError];
        #endif
    }

    NSError *sessionError;
    id omidAdSession = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        omidAdSession = [[OMIDPubnativenetAdSession alloc] initWithConfiguration:config
                                                               adSessionContext:context
                                                                          error:&sessionError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        omidAdSession = [[OMIDSmaatoAdSession alloc] initWithConfiguration:config
                                                           adSessionContext:context
                                                                      error:&sessionError];
        #endif
    }

    if (omidAdSession) {
        [omidAdSession setMainAdView:view];
    }

    [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];

    return [[OMIDAdSessionWrapper alloc] initWithAdSession:omidAdSession];
}

- (void)fireOMIDAdLoadEvent:(OMIDAdSessionWrapper *)omidAdSessionWrapper {
    [super fireOMIDAdLoadEvent:omidAdSessionWrapper];
    
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    
    if (omidAdSessionWrapper) {
        id adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:omidAdSessionWrapper];

        NSError *loadedError;
        if (adEvents) {
            if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
                #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
                [(OMIDPubnativenetAdEvents *)adEvents loadedWithError:&loadedError];
                #endif
            } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
                #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
                [(OMIDSmaatoAdEvents *)adEvents loadedWithError:&loadedError];
                #endif
            }
        }

        if (loadedError) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Error firing ad load event"];
        }
    }
}

@end

