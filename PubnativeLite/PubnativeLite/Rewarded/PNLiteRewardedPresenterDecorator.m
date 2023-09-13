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

#import "PNLiteRewardedPresenterDecorator.h"
#import "HyBidViewabilityAdSession.h"
#import "HyBid.h"
#import "HyBidSKOverlay.h"
#import "PNLiteImpressionTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface PNLiteRewardedPresenterDecorator() <PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidAdTracker *adTracker;
@property (nonatomic) NSObject<HyBidRewardedPresenterDelegate> *rewardedPresenterDelegate;
@property (nonatomic, strong) NSMutableDictionary *errorReportingProperties;
@property (nonatomic, strong) HyBidSKOverlay *skoverlay;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;

@end

@implementation PNLiteRewardedPresenterDecorator

- (void)dealloc {
    self.rewardedPresenter = nil;
    self.adTracker = nil;
    self.rewardedPresenterDelegate = nil;
    self.errorReportingProperties = nil;
    self.skoverlay = nil;
}

- (void)load {
    [self.rewardedPresenter load];
}

- (void)show {
    [self.rewardedPresenter show];
}

- (void)showFromViewController:(UIViewController *)viewController {
    [self.rewardedPresenter showFromViewController:viewController];
}

- (void)hideFromViewController:(UIViewController *)viewController {
    [self.rewardedPresenter hideFromViewController:viewController];
}

- (instancetype)initWithRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
                                withAdTracker:(HyBidAdTracker *)adTracker
                                 withDelegate:(NSObject<HyBidRewardedPresenterDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.rewardedPresenter = rewardedPresenter;
        self.adTracker = adTracker;
        self.rewardedPresenterDelegate = delegate;
        self.errorReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary withRewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter {
    if ([HyBidSDKConfig sharedConfig].appToken != nil && [HyBidSDKConfig sharedConfig].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSDKConfig sharedConfig].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (rewardedPresenter.ad.zoneID != nil && rewardedPresenter.ad.zoneID.length > 0) {
        [reportingDictionary setObject:rewardedPresenter.ad.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if (rewardedPresenter.ad.assetGroupID) {
        [reportingDictionary setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
    }

    NSString *vast = rewardedPresenter.ad.isUsingOpenRTB
            ? rewardedPresenter.ad.openRtbVast
            : rewardedPresenter.ad.vast;
    if (vast) {
        [reportingDictionary setObject:vast forKey:HyBidReportingCommon.CREATIVE];
    }
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidLoad:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidLoad:rewardedPresenter];
        
        if(!self.impressionTracker) {
            self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
            [self.impressionTracker determineViewbilityRemoteConfig:rewardedPresenter.ad];
        }
        
        if (self.impressionTracker.impressionTrackingMethod == HyBidAdImpressionTrackerRender) {
            [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
        }
        
        if (self.rewardedPresenter.ad.skoverlayEnabled) {
            if ([self.rewardedPresenter.ad.skoverlayEnabled boolValue]) {
                self.skoverlay = [[HyBidSKOverlay alloc] initWithAd:rewardedPresenter.ad];
            }
        } else if ([HyBidRenderingConfig sharedConfig].rewardedSKOverlay) {
            self.skoverlay = [[HyBidSKOverlay alloc] initWithAd:rewardedPresenter.ad];
        }
    }
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidShow:)] && !self.adTracker.impressionTracked) {
        [self.adTracker trackImpressionWithAdFormat:HyBidReportingAdFormat.REWARDED];
        [self.rewardedPresenterDelegate rewardedPresenterDidShow:rewardedPresenter];
        [self.skoverlay presentWithAd:rewardedPresenter.ad];
    }
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidClick:)]) {
        [self.adTracker trackClickWithAdFormat:HyBidReportingAdFormat.REWARDED];
        [self.rewardedPresenterDelegate rewardedPresenterDidClick:rewardedPresenter];
    }
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidDismiss:)]) {
        [self.rewardedPresenterDelegate rewardedPresenterDidDismiss:rewardedPresenter];
        [self.skoverlay dismissWithAd:rewardedPresenter.ad];
    }
}

- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter
{
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenterDidFinish:)]) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.VIDEO_FINISHED adFormat:HyBidReportingAdFormat.REWARDED properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        [self.rewardedPresenterDelegate rewardedPresenterDidFinish:rewardedPresenter];
    }
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    if (self.rewardedPresenterDelegate && [self.rewardedPresenterDelegate respondsToSelector:@selector(rewardedPresenter:didFailWithError:)]) {
        if (error != nil && error.localizedDescription != nil && error.localizedDescription.length > 0) {
            [self.errorReportingProperties setObject:error.localizedDescription forKey:HyBidReportingCommon.ERROR_MESSAGE];
        }
        [self addCommonPropertiesToReportingDictionary:self.errorReportingProperties withRewardedPresenter:rewardedPresenter];
        if(self.errorReportingProperties){
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR adFormat:HyBidReportingAdFormat.REWARDED properties:self.errorReportingProperties];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
        [self.rewardedPresenterDelegate rewardedPresenter:rewardedPresenter didFailWithError:error];
    }
}

- (void)rewardedPresenterDidAppear:(HyBidRewardedPresenter *)rewardedPresenter {
    
}

- (void)rewardedPresenterDidDisappear:(HyBidRewardedPresenter *)rewardedPresenter {
    
}

- (void)rewardedPresenterPresentsSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.skoverlay presentWithAd:rewardedPresenter.ad];
}

- (void)rewardedPresenterDismissesSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter {
    [self.skoverlay dismissWithAd:rewardedPresenter.ad];
}

@end
