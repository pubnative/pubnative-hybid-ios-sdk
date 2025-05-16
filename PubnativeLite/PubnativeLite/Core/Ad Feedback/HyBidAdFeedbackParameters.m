// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
    if (self.ad.audioState) {
        return self.ad.audioState;
    } else {
        switch (HyBidConstants.audioStatus) {
            case HyBidAudioStatusMuted:
                return @"muted";
                break;
            case HyBidAudioStatusON:
                return @"on";
                break;
            case HyBidAudioStatusDefault:
                return @"default";
                break;
        }
    }
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)deviceInfo {
    return [NSString stringWithFormat:@"%@ iOS %@", [HyBidSettings sharedInstance].deviceModel, [HyBidSettings sharedInstance].osVersion];
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
