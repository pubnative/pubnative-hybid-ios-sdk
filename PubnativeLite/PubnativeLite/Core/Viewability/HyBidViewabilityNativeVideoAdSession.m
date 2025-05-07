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
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return nil;

    NSError *contextError;
    id partner = [HyBidViewabilityManager sharedInstance].partner;
    
    if (!partner) {
        NSLog(@"❌ OMID Partner is nil, cannot create ad session.");
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

    if (!context) return nil;

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

    if (!config) return nil;

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
        self.adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:omidAdSession];
        self.omidMediaEvents = [[HyBidViewabilityManager sharedInstance] getMediaEvents:omidAdSession];

        [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];
    }

    return omidAdSession;
}

- (void)fireOMIDStartEventWithDuration:(CGFloat)duration withVolume:(CGFloat)volume {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents startWithDuration:duration mediaPlayerVolume:volume];
}

- (void)fireOMIDFirstQuartileEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents firstQuartile];
}

- (void)fireOMIDMidpointEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents midpoint];
}

- (void)fireOMIDThirdQuartileEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents thirdQuartile];
}

- (void)fireOMIDCompleteEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents complete];
}

- (void)fireOMIDPauseEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents pause];
}

- (void)fireOMIDResumeEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents resume];
}

- (void)fireOMIDBufferStartEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents bufferStart];
}

- (void)fireOMIDBufferFinishEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents bufferFinish];
}

- (void)fireOMIDVolumeChangeEventWithVolume:(CGFloat)volume {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents volumeChangeTo:volume];
}

- (void)fireOMIDSkippedEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents skipped];
}

- (void)fireOMIDClickedEvent {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents adUserInteractionWithType:OMIDInteractionTypeClick];
}

- (void)fireOMIDPlayerStateEventWithFullscreenInfo:(BOOL)isFullScreen {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    [self.omidMediaEvents playerStateChangeTo:isFullScreen ? OMIDPlayerStateFullscreen : OMIDPlayerStateNormal];
}

@end
