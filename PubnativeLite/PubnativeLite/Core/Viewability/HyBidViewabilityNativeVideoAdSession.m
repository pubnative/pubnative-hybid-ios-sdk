// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityNativeVideoAdSession.h"
#import "HyBid.h"
#import "HyBidViewabilityManager.h"

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
    #import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
    #import <OMSDK_Smaato/OMIDImports.h>
#endif

@interface HyBidViewabilityNativeVideoAdSession ()
@property (nonatomic, strong) id omidMediaEvents;
@property (nonatomic, strong) id adEvents;
@end

@implementation HyBidViewabilityNativeVideoAdSession

+ (instancetype)sharedInstance {
    static HyBidViewabilityNativeVideoAdSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityNativeVideoAdSession alloc] init];
    });
    return sharedInstance;
}

- (id)createOMIDAdSessionforNativeVideo:(UIView *)view withScript:(NSMutableArray *)scripts {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return nil;

    NSError *contextError;
    NSString *customReferenceID = @"";
    NSString *contentUrl = @"";
    
    id partner = [HyBidViewabilityManager sharedInstance].partner;
    id context = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:partner
                                                                     script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                                  resources:scripts
                                                                 contentUrl:contentUrl
                                                  customReferenceIdentifier:customReferenceID
                                                                      error:&contextError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        context = [[OMIDSmaatoAdSessionContext alloc] initWithPartner:partner
                                                               script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                            resources:scripts
                                                           contentUrl:contentUrl
                                            customReferenceIdentifier:customReferenceID
                                                                error:&contextError];
        #endif
    }
    
    return [self initialiseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNativeOwner];
}

- (id)initialiseOMIDAdSessionForView:(id)view
                  withSessionContext:(id)context
                  andImpressionOwner:(OMIDOwner)impressionOwner
                 andMediaEventsOwner:(OMIDOwner)mediaEventsOwner {
    NSError *configurationError;
    
    id config = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
                                                                      impressionType:OMIDImpressionTypeBeginToRender
                                                                     impressionOwner:impressionOwner
                                                                    mediaEventsOwner:mediaEventsOwner
                                                          isolateVerificationScripts:NO
                                                                               error:&configurationError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        config = [[OMIDSmaatoAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
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

    [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];

    if (omidAdSession) {
        OMIDAdSessionWrapper* adSessionWrapper = [[OMIDAdSessionWrapper alloc] initWithAdSession:omidAdSession];
        [omidAdSession setMainAdView:view];
        self.adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:adSessionWrapper];
        self.omidMediaEvents = [[HyBidViewabilityManager sharedInstance] getMediaEvents:adSessionWrapper];

        return adSessionWrapper;
    }

    return nil;
}

- (void)fireOMIDAdLoadEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    NSError *vastPropertiesError;
    OMIDPubnativenetVASTProperties *vastProperties = [[OMIDPubnativenetVASTProperties alloc] initWithAutoPlay:YES position:OMIDPositionStandalone];
    [self.adEvents loadedWithVastProperties:vastProperties error:&vastPropertiesError];
}

- (void)fireOMIDStartEventWithDuration:(CGFloat)duration withVolume:(CGFloat)volume {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents startWithDuration:duration mediaPlayerVolume:volume];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_STARTED];
}

- (void)fireOMIDFirstQuartileEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents firstQuartile];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_FIRST_QUARTILE];
}

- (void)fireOMIDMidpointEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents midpoint];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_MIDPOINT];
}

- (void)fireOMIDThirdQuartileEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents thirdQuartile];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_THIRD_QUARTILE];
}

- (void)fireOMIDCompleteEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents complete];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_COMPLETE];
}

- (void)fireOMIDPauseEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents pause];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_PAUSE];
}

- (void)fireOMIDResumeEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents resume];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_RESUME];
}

- (void)fireOMIDBufferStartEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents bufferStart];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_BUFFER_START];
    
}

- (void)fireOMIDBufferFinishEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents bufferFinish];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_BUFFER_FINISH];
}

- (void)fireOMIDVolumeChangeEventWithVolume:(CGFloat)volume {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents volumeChangeTo:volume];
}

- (void)fireOMIDSkippedEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents skipped];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_SKIPPED];
}

- (void)fireOMIDClickedEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    [self.omidMediaEvents adUserInteractionWithType:OMIDInteractionTypeClick];
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_CLICKED];
}

- (void)fireOMIDPlayerStateEventWithFullscreenInfo:(BOOL)isFullScreen {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if (isFullScreen) {
        [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateFullscreen];
    } else {
        [self.omidMediaEvents playerStateChangeTo:OMIDPlayerStateNormal];
    }
}

@end
