//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import "ATOMManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

@implementation ATOMManager

+ (void)fireAdSessionEventWithData:(HyBidAdSessionData *)data
{
    NSMutableDictionary<NSString *, id> *adSessionDict = [NSMutableDictionary dictionary];

    if (data.creativeId.length > 0) {
        adSessionDict[@"Creative_id"] = data.creativeId;
    }
    if (data.campaignId.length > 0) {
        adSessionDict[@"Campaign_id"] = data.campaignId;
    }
    if (data.bidPrice.length > 0) {
        adSessionDict[@"Bid_price"] = data.bidPrice;
    }
    if (data.adFormat.length > 0) {
        adSessionDict[@"Ad format"] = data.adFormat;
    }
    if (data.renderingStatus.length > 0) {
        adSessionDict[@"Rendering_status"] = data.renderingStatus;
    }

    NSNumber *vNum = data.viewability;
    if (vNum != nil) {
        double v = vNum.doubleValue;
        if (isfinite(v)) {
            adSessionDict[@"Viewability"] = @(v);
        } else {
            adSessionDict[@"Viewability"] = @(-1);
        }
    }

    if (adSessionDict.count == 0) {
        return;
    }

    NSDictionary *jsonObject = @{
        [HyBidConstants AD_SESSION_DATA] : adSessionDict
    };

#if __has_include(<ATOM/ATOM-Swift.h>)
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&err];
    if (jsonData && !err) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString.length > 0) {
            [Atom fireWithEventWithName: [HyBidConstants AD_SESSION_DATA] eventWithValue: jsonString withDelegate:nil];
            [ATOMManager reportAdSessionDataSharedEventWithAdSessionDict:adSessionDict];
        }
    }
#endif
}

+ (HyBidAdSessionData *)createAdSessionDataFromRequest:(HyBidAdRequest * _Nullable)request
                                                    ad:(HyBidAd *)ad
{
    HyBidAdSessionData *adSessionData = [[HyBidAdSessionData alloc] init];

    if (ad.creativeID.length > 0) {
        adSessionData.creativeId = ad.creativeID;
    }
    if (ad.campaignID.length > 0) {
        adSessionData.campaignId = ad.campaignID;
    }

    NSString *adFormat = nil;
    if ([request respondsToSelector:@selector(getAdFormat)]) {
        adFormat = [request getAdFormat];
    }
    if (adFormat.length == 0 && ad.adFormat.length > 0) {
        adFormat = ad.adFormat;
    }
    if (adFormat.length > 0) {
        adSessionData.adFormat = adFormat;
    }
    NSString *bidPrice = [HyBidHeaderBiddingUtils eCPMFromAd:ad
                                        withDecimalPlaces:THREE_DECIMAL_PLACES];
    if (bidPrice.length > 0) {
        adSessionData.bidPrice = bidPrice;
    }

    adSessionData.viewability = @(1);
    adSessionData.renderingStatus = [HyBidConstants RENDERING_SUCCESS];

    return adSessionData;
}

+ (void)reportAdSessionDataSharedEventWithAdSessionDict:(NSDictionary<NSString *, id> *)adSessionDict
{
    if ([HyBidSDKConfig sharedConfig].reporting) {
        NSDictionary *properties = @{ [HyBidConstants AD_SESSION_DATA] : adSessionDict ?: @{} };

        HyBidReportingEvent *reportingEvent =
            [[HyBidReportingEvent alloc] initWith:HyBidReportingEventType.AD_SESSION_DATA_SHARED_TO_ATOM
                                          adFormat:nil
                                         properties:properties];

        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

@end

