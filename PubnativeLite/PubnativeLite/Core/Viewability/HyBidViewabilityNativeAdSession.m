// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityNativeAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
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

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:[HyBidViewabilityManager sharedInstance].partner
                                                                                                   script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                                                                resources:scripts
                                                                                               contentUrl:nil
                                                                                customReferenceIdentifier:nil
                                                                                                    error:&contextError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNoneOwner];
}

- (OMIDPubnativenetAdSession *)initialseOMIDAdSessionForView:(id)view
                                          withSessionContext:(OMIDPubnativenetAdSessionContext*)context
                                          andImpressionOwner:(OMIDOwner)impressionOwner
                                         andMediaEventsOwner:(OMIDOwner)mediaEventsOwner{
    NSError *configurationError;
    
    OMIDPubnativenetAdSessionConfiguration *config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay
                                                                                                           impressionType:OMIDImpressionTypeBeginToRender
                                                                                                          impressionOwner:impressionOwner
                                                                                                         mediaEventsOwner:mediaEventsOwner
                                                                                               isolateVerificationScripts:NO
                                                                                                                    error:&configurationError];
    NSError *sessionError;
    OMIDPubnativenetAdSession *omidAdSession = [[OMIDPubnativenetAdSession alloc] initWithConfiguration:config
                                                                                       adSessionContext:context
                                                                                                  error:&sessionError];
    
    omidAdSession.mainAdView = view;
    
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];

    return omidAdSession;
}

- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    [super fireOMIDAdLoadEvent:omidAdSession];
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
    return;
    
    if(omidAdSession != nil){
         OMIDPubnativenetAdEvents* adEvents = [[HyBidViewabilityManager sharedInstance]getAdEvents:omidAdSession];
        
        NSError *loadedError;
        [adEvents loadedWithError:&loadedError];
        
    }
}

@end
