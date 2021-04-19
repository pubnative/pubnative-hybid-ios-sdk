//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HyBidViewabilityNativeVideoAdSession.h"
#import "HyBid.h"

@interface HyBidViewabilityNativeVideoAdSession()

@property (nonatomic, strong) OMIDPubnativenetMediaEvents *omidMediaEvents;
@property (nonatomic, strong) OMIDPubnativenetAdEvents *adEvents;

@property (nonatomic, assign) BOOL isStartEventFired;
@property (nonatomic, assign) BOOL isFirstQuartileEventFired;
@property (nonatomic, assign) BOOL isMidpointEventFired;
@property (nonatomic, assign) BOOL isThirdQuartileEventFired;
@property (nonatomic, assign) BOOL isCompleteEventFired;

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
    
    if (!self.isStartEventFired) {
        [self.omidMediaEvents startWithDuration:duration mediaPlayerVolume:volume];
        self.isStartEventFired = YES;
        
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_STARTED];
    }
}

- (void)fireOMIDFirstQuartileEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
       return;
    
    if (!self.isFirstQuartileEventFired) {
        [self.omidMediaEvents firstQuartile];
        self.isFirstQuartileEventFired = YES;
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_FIRST_QUARTILE];
    }
}

- (void)fireOMIDMidpointEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
       return;
    
    if (!self.isMidpointEventFired) {
        [self.omidMediaEvents midpoint];
        self.isMidpointEventFired = YES;
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_MIDPOINT];
    }
}

- (void)fireOMIDThirdQuartileEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
       return;
    
    if (!self.isThirdQuartileEventFired) {
        [self.omidMediaEvents thirdQuartile];
        self.isThirdQuartileEventFired = YES;
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_THIRD_QUARTILE];
    }
}

- (void)fireOMIDCompleteEvent {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
       return;
    
    if (!self.isCompleteEventFired) {
        [self.omidMediaEvents complete];
        self.isCompleteEventFired = YES;
        [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_COMPLETE];
    }
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
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.VIDEO_AD_VOLUME_CHANGE];
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
