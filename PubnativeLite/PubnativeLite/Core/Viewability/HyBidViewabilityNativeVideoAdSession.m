// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityNativeVideoAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

@interface HyBidViewabilityNativeVideoAdSession()

@property (nonatomic, strong) OMIDPubnativenetMediaEvents *omidMediaEvents;
@property (nonatomic, strong) OMIDPubnativenetAdEvents *adEvents;

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

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforNativeVideo:(UIView *)view withScript:(NSMutableArray *)scripts {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    NSString *customReferenceID = @"";
    NSString *contentUrl = @"";
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:[HyBidViewabilityManager sharedInstance].partner
                                                                                                   script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                                                                resources:scripts
                                                                                               contentUrl:contentUrl
                                                                                customReferenceIdentifier:customReferenceID
                                                                                                    error:&contextError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNativeOwner];
}

- (OMIDPubnativenetAdSession *)initialseOMIDAdSessionForView:(id)view
                                          withSessionContext:(OMIDPubnativenetAdSessionContext*)context
                                          andImpressionOwner:(OMIDOwner)impressionOwner
                                         andMediaEventsOwner:(OMIDOwner)mediaEventsOwner{
    NSError *configurationError;
    
    OMIDPubnativenetAdSessionConfiguration *config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeVideo
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
    [self createAdEventsWithSession:omidAdSession];
    [self createMediaEventsWithSession:omidAdSession];
    
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];
    
    return omidAdSession;
}

- (void)createAdEventsWithSession:(OMIDPubnativenetAdSession *)omidAdSession {
    self.adEvents = [[HyBidViewabilityManager sharedInstance]getAdEvents:omidAdSession];
}

- (void)createMediaEventsWithSession:(OMIDPubnativenetAdSession *)omidAdSession {
    self.omidMediaEvents = [[HyBidViewabilityManager sharedInstance]getMediaEvents:omidAdSession];
}

- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    [super fireOMIDAdLoadEvent:omidAdSession];
    [self fireOMIDAdLoadEvent];
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

- (void)fireOMIDClikedEvent {
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
