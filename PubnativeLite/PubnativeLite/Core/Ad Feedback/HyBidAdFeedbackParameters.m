//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidAdFeedbackParameters.h"
#import "HyBidIntegrationType.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface HyBidAdFeedbackParameters()

@property (nonatomic, strong) NSMutableDictionary *adCache;
@property (nonatomic, strong) NSMutableDictionary *adRequestCache;
@property (readonly) HyBidAdRequest *adRequest;
@property (readonly) HyBidAd *ad;

@end

@implementation HyBidAdFeedbackParameters

+ (HyBidAdFeedbackParameters *)sharedInstance {
    static HyBidAdFeedbackParameters *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HyBidAdFeedbackParameters alloc] init];
        _instance.adCache = [[NSMutableDictionary alloc] init];
        _instance.adRequestCache = [[NSMutableDictionary alloc] init];
    });
    return _instance;
}

- (void)cacheAd:(HyBidAd *)ad andAdRequest:(HyBidAdRequest *)adRequest withZoneID:(NSString *)zoneID {
    [[HyBidAdFeedbackParameters sharedInstance].adCache setObject:ad forKey:zoneID];
    [[HyBidAdFeedbackParameters sharedInstance].adRequestCache setObject:adRequest forKey:zoneID];
}

- (HyBidAd *)ad {
    return [[HyBidAdFeedbackParameters sharedInstance].adCache objectForKey:self.requestedZoneID];
}

- (HyBidAdRequest *)adRequest {
    return [[HyBidAdFeedbackParameters sharedInstance].adRequestCache objectForKey:self.requestedZoneID];
}

- (NSString *)appToken {
    return [HyBidSDKConfig sharedConfig].appToken;
}

- (NSString *)audioState {
    switch ([HyBidRenderingConfig sharedConfig].audioStatus) {
        case HyBidAudioStatusMuted:
            return @"Muted";
            break;
        case HyBidAudioStatusON:
            return @"ON";
            break;
        case HyBidAudioStatusDefault:
            return @"Default";
            break;
    }
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)deviceInfo {
    return [NSString stringWithFormat:@"%@ iOS %@", [HyBidSettings sharedInstance].deviceName, [HyBidSettings sharedInstance].osVersion];
}

- (NSString *)sdkVersion {
    return HyBidConstants.HYBID_SDK_VERSION;
}

- (NSString *)zoneID {
    return self.ad.zoneID;
}

- (NSString *)creativeID {
    return self.ad.creativeID;
}

- (NSString *)creative {
    if (self.ad.assetGroupID) {
        switch (self.ad.assetGroupID.integerValue) {
            case VAST_MRECT:
            case VAST_INTERSTITIAL:
                return self.ad.vast ? self.ad.vast : nil;
                break;                
            default:
                return self.ad.htmlData ? self.ad.htmlData : self.ad.htmlUrl ? self.ad.htmlUrl : nil;
                break;
        }
    } else {
        return nil;
    }
}

- (NSString *)impressionBeacon {
    return self.ad.impressionID;
}

- (NSString *)integrationType {
    return [HyBidIntegrationType integrationTypeToString:self.adRequest.integrationType];
}

- (NSString *)adFormat {
    if ([self.adRequest isRewarded]) {
        return HyBidReportingAdFormat.REWARDED;
    } else {
        if ([[self.adRequest adSize] isEqualTo:HyBidAdSize.SIZE_INTERSTITIAL]) {
            return HyBidReportingAdFormat.FULLSCREEN;
        } else if ([[self.adRequest adSize] isEqualTo:HyBidAdSize.SIZE_NATIVE]) {
            return HyBidReportingAdFormat.NATIVE;
        } else {
            return HyBidReportingAdFormat.BANNER;
        }
    }
}

- (BOOL)hasEndCard {
    return self.ad.hasEndCard;
}

@end
