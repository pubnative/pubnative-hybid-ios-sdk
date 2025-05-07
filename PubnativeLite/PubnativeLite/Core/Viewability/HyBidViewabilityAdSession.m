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
        [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_LOADED];
    }
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
