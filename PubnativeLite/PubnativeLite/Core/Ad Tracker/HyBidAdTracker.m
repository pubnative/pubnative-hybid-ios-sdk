// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdTracker.h"
#import "HyBidDataModel.h"
#import "HyBidURLDriller.h"
#import <WebKit/WebKit.h>
#import "HyBid.h"
#import "PNLiteData.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString *const PNLiteAdTrackerClick = @"click";
NSString *const PNLiteAdTrackerImpression = @"impression";
NSString *const PNLiteAdCustomEndCardImpression = @"custom_endcard_impression";
NSString *const PNLiteAdCustomEndCardClick = @"custom_endcard_click";
NSString *const PNLiteAdCustomCTAImpression = @"custom_cta_show";
NSString *const PNLiteAdCustomCTAClick = @"custom_cta_click";
NSString *const PNLiteAdCustomCTAEndCardClick = @"custom_cta_endcard_click";

@interface HyBidAdTracker() <HyBidAdTrackerRequestDelegate, HyBidURLDrillerDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) HyBidAdTrackerRequest *adTrackerRequest;
@property (nonatomic, strong) NSArray *impressionURLs;
@property (nonatomic, strong) NSArray *customEndcardImpressionURLs;
@property (nonatomic, strong) NSArray *clickURLs;
@property (nonatomic, strong) NSArray *customEndcardClickURLs;
@property (nonatomic, strong) HyBidCustomCTATracking *customCTATracking;
@property (nonatomic, assign) BOOL clickTracked;
@property (nonatomic, assign) BOOL customEndCardClickTracked;
@property (nonatomic, assign) BOOL customEndCardImpressionTracked;
@property (nonatomic, assign) BOOL customCTAImpressionTracked;
@property (nonatomic, assign) BOOL automaticClickTracked;
@property (nonatomic, assign) BOOL automaticCustomEndCardClickTracked;
@property (nonatomic, assign) BOOL automaticDefaultEndCardClickTracked;
@property (nonatomic, assign) BOOL clickBeaconsTracked;

@property (nonatomic, strong) NSString *trackTypeForURL;
@property (nonatomic, assign) BOOL customCTAClickTracked;
@property (nonatomic, assign) BOOL customCTAEndCardClickTracked;
@property (nonatomic, assign) BOOL urlDrillerEnabled;

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL vastReplayCLickTracked;

@end

@implementation HyBidAdTracker

- (void)dealloc {
    self.adTrackerRequest = nil;
    self.impressionURLs = nil;
    self.clickURLs = nil;
    self.wkWebView = nil;
    self.ad = nil;
    self.customCTATracking = nil;
}

- (instancetype)initWithImpressionURLs:(NSArray *)impressionURLs
       withCustomEndcardImpressionURLs:(NSArray *)customEndcardImpressionURLs
                         withClickURLs:(NSArray *)clickURLs
            withCustomEndcardClickURLs:(NSArray *)customEndcardClickURLs
                 withCustomCTATracking:(HyBidCustomCTATracking *)customCTATracking
                                 forAd:(HyBidAd *)ad {
    HyBidAdTrackerRequest *adTrackerRequest = [[HyBidAdTrackerRequest alloc] init];

    self = [self initWithAdTrackerRequest:adTrackerRequest
                       withImpressionURLs:impressionURLs
          withCustomEndcardImpressionURLs:customEndcardImpressionURLs
                            withClickURLs:clickURLs
               withCustomEndcardClickURLs:customEndcardClickURLs
                    withCustomCTATracking:customCTATracking];
    if (!self) { return nil; }

    self.ad = ad;

    return self;
}

- (instancetype)initWithAdTrackerRequest:(HyBidAdTrackerRequest *)adTrackerRequest
                      withImpressionURLs:(NSArray *)impressionURLs
         withCustomEndcardImpressionURLs:(NSArray *)customEndcardImpressionURLs
                           withClickURLs:(NSArray *)clickURLs
              withCustomEndcardClickURLs:(NSArray *)customEndcardClickURLs
                   withCustomCTATracking:(HyBidCustomCTATracking *)customCTATracking {
    self = [super init];
    if (self) {
        self.adTrackerRequest = adTrackerRequest;
        self.impressionURLs = impressionURLs;
        self.customEndcardImpressionURLs = customEndcardImpressionURLs;
        self.clickURLs = clickURLs;
        self.customEndcardClickURLs = customEndcardClickURLs;
        self.customCTATracking = customCTATracking;
    }
    return self;
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        if ([NSThread isMainThread]) {
            _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
            });
        }
    }
    return _wkWebView;
}

- (void)trackClickWithAdFormat:(NSString *)adFormat {
    if (self.clickTracked) {
        return;
    }
    
    [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    if (!self.ad.customEndCard.isCustomEndCardClicked && !self.ad.isEndcard) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
            HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CLICK adFormat:adFormat properties:nil];
            [[HyBid reportingManager] reportEventFor:reportingEvent];
        }
    }
    self.clickTracked = YES;
}

- (void)trackImpressionWithAdFormat:(NSString *)adFormat {
    if (self.impressionTracked) {
        return;
    }
    
    [self trackURLs:self.impressionURLs withTrackingType:PNLiteAdTrackerImpression];
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.IMPRESSION adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.impressionTracked = YES;
}

- (void)trackCustomEndCardImpressionWithAdFormat:(NSString *)adFormat {
    if (self.customEndCardImpressionTracked) {
        return;
    }
    
    [self trackURLs:self.customEndcardImpressionURLs withTrackingType:PNLiteAdCustomEndCardImpression];
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CUSTOM_ENDCARD_IMPRESSION adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.customEndCardImpressionTracked = YES;
}

- (void)trackCustomEndCardClickWithAdFormat:(NSString *)adFormat {
    if (self.customEndCardClickTracked) {
        return;
    }
    
    [self trackURLs:self.customEndcardClickURLs withTrackingType:PNLiteAdCustomEndCardClick];
    if(self.clickTracked == NO) {
        [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    }
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK
                                                                ad:self.ad];
    
    self.ad.customEndCard.isCustomEndCardClicked = YES;
    self.customEndCardClickTracked = YES;
}

- (void)trackCustomCTAImpressionWithAdFormat:(NSString *)adFormat {
    if (self.customCTAImpressionTracked) { return; }
    [self trackURLs:[self.customCTATracking impressionBeacons] withTrackingType:PNLiteAdCustomCTAImpression];
    self.customCTAImpressionTracked = YES;
}

- (void)trackCustomCTAClickWithAdFormat:(NSString *)adFormat onEndCard:(BOOL)onEndCard {
    if (onEndCard) {
        if (self.customCTAEndCardClickTracked) { return; }
        [self trackURLs:[self.customCTATracking endCardClickBeacons] withTrackingType:PNLiteAdCustomCTAEndCardClick];
        self.customCTAEndCardClickTracked = YES;
    } else {
        if (self.customCTAClickTracked) { return; }
        [self trackURLs:[self.customCTATracking clickBeacons] withTrackingType:PNLiteAdCustomCTAClick];
        self.customCTAClickTracked = YES;
    }
    
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent *reportingEvent = [[HyBidReportingEvent alloc]
                                               initWith: onEndCard
                                               ? HyBidReportingEventType.CUSTOM_CTA_ENDCARD_CLICK
                                               : HyBidReportingEventType.CUSTOM_CTA_CLICK
                                               adFormat: adFormat
                                               properties: nil];
        
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

- (void)trackSKOverlayAutomaticClickWithAdFormat:(NSString *)adFormat {
    if (self.automaticClickTracked) {
        return;
    }
    [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.SKOVERLAY_AUTOMATIC_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.automaticClickTracked = YES;
}

- (void)trackSKOverlayAutomaticDefaultEndCardClickWithAdFormat:(NSString *)adFormat {
    if (!self.clickBeaconsTracked) {
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK
                                                                    ad:self.ad];
        self.clickBeaconsTracked = YES;
    }

    if (self.automaticClickTracked) {
        return;
    }
    [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.SKOVERLAY_AUTOMATIC_DEFAULT_ENDCARD_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.automaticClickTracked = YES;
}

- (void)trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:(NSString *)adFormat {
    if (!self.clickBeaconsTracked) {
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK
                                                                    ad:self.ad];
        self.clickBeaconsTracked = YES;
    }

    if (self.automaticCustomEndCardClickTracked && self.automaticClickTracked) {
        return;
    }
    if (!self.automaticClickTracked) {
        [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
        self.automaticClickTracked = YES;
    }
    if (!self.automaticCustomEndCardClickTracked) {
        [self trackURLs:self.customEndcardClickURLs withTrackingType:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK];
        self.automaticCustomEndCardClickTracked = YES;
    }
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.SKOVERLAY_AUTOMATIC_CUSTOM_ENDCARD_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

- (void)trackStorekitAutomaticClickWithAdFormat:(NSString *)adFormat {
    if (self.automaticClickTracked) {
        return;
    }
    [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.STOREKIT_AUTOMATIC_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.automaticClickTracked = YES;
}

- (void)trackStorekitAutomaticDefaultEndCardClickWithAdFormat:(NSString *)adFormat {
    if (!self.clickBeaconsTracked) {
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.DEFAULT_ENDCARD_CLICK
                                                                    ad:self.ad];
        self.clickBeaconsTracked = YES;
    }

    if (self.automaticDefaultEndCardClickTracked) {
        return;
    }
    if (!self.automaticClickTracked) {
        [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
    }
    self.automaticClickTracked = YES;
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.STOREKIT_AUTOMATIC_DEFAULT_ENDCARD_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    self.automaticDefaultEndCardClickTracked = YES;
}

- (void)trackStorekitAutomaticCustomEndCardClickWithAdFormat:(NSString *)adFormat {
    if (!self.clickBeaconsTracked) {
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK
                                                                    ad:self.ad];
        self.clickBeaconsTracked = YES;
    }
    
    if (self.automaticCustomEndCardClickTracked && self.automaticClickTracked) {
        return;
    }
    if (!self.automaticClickTracked) {
        [self trackURLs:self.clickURLs withTrackingType:PNLiteAdTrackerClick];
        self.automaticClickTracked = YES;
    }
    if (!self.automaticCustomEndCardClickTracked) {
        [self trackURLs:self.customEndcardClickURLs withTrackingType:HyBidReportingEventType.CUSTOM_ENDCARD_CLICK];
        self.automaticCustomEndCardClickTracked = YES;
    }
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.STOREKIT_AUTOMATIC_CUSTOM_ENDCARD_CLICK adFormat:adFormat properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

- (void)trackReplayClickWithAdFormat:(NSString *)adFormat {
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.REPLAY
                                                                          adFormat:adFormat
                                                                        properties:nil];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
    
    if (self.vastReplayCLickTracked) { return; }
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.REPLAY ad:self.ad];
    self.vastReplayCLickTracked = YES;
}

- (void)trackURLs:(NSArray *)URLs withTrackingType:(NSString *)trackingType {
    if (URLs != nil) {
        for (HyBidDataModel *dataModel in URLs) {
            if (dataModel.url.length > 0) {
                if (self.urlDrillerEnabled) {
                    // Drilled URLs are reported in didFinishWithURL:trackingType: using the
                    // resolved URL, so the inspector matches what is actually dispatched and a
                    // failed drill reports nothing.
                    [[[HyBidURLDriller alloc] init] startDrillWithURLString:dataModel.url delegate:self withTrackingType:trackingType];
                } else {
                    // Report at fire-time so the beacon is recorded even if the request's weak
                    // delegate is deallocated before the network call completes.
                    [self reportBeaconWithTrackingType:trackingType url:dataModel.url];
                    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with URL: %@",trackingType, dataModel.url]];
                    [self.adTrackerRequest trackAdWithDelegate:self withURL:dataModel.url withTrackingType:trackingType];
                }
            } else if (dataModel.js != nil) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with JS Beacon: %@",trackingType, dataModel.js]];
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.wkWebView evaluateJavaScript:dataModel.js completionHandler:^(id _Nullable success, NSError * _Nullable error) {
                        
                        HyBidReportingBeacon *reportingBeacon = [self beaconReportObjectWith:trackingType content:@{PNLiteData.js : dataModel.js}];
                        if (success && [HyBidSDKConfig sharedConfig].reporting && reportingBeacon) {
                            [[HyBid reportingManager] reportBeaconFor:reportingBeacon];
                        }
                    }];
                });
            }
        }
        
    }
}

#pragma mark HyBidAdTrackerRequestDelegate

- (void)requestDidStart:(HyBidAdTrackerRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ started:",request]];
}

- (void)requestDidFinish:(HyBidAdTrackerRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ finished:",request]];
}

- (void)reportBeaconWithTrackingType:(NSString *)trackingType url:(NSString *)url {
    if (![HyBidSDKConfig sharedConfig].reporting || url.length == 0) { return; }
    HyBidReportingBeacon *reportingBeacon = [self beaconReportObjectWith:trackingType content:@{PNLiteData.url : url}];
    if (reportingBeacon) {
        [[HyBid reportingManager] reportBeaconFor:reportingBeacon];
    }
}

- (HyBidReportingBeacon *)beaconReportObjectWith:(NSString *)beaconType content:(NSDictionary *)content {
    
    NSArray<NSString *> *beaconsKeys = @[PNLiteAdTrackerClick, PNLiteAdTrackerImpression, PNLiteAdCustomEndCardImpression, PNLiteAdCustomEndCardClick, PNLiteAdCustomCTAImpression, PNLiteAdCustomCTAClick, PNLiteAdCustomCTAEndCardClick];
    
    if (![beaconsKeys containsObject:beaconType]) { return nil; }
    
    if ([beaconType isEqualToString:PNLiteAdTrackerClick]) { beaconType = HyBidReportingBeaconType.CLICK; }
    if ([beaconType isEqualToString:PNLiteAdTrackerImpression]) { beaconType = HyBidReportingBeaconType.IMPRESSION; }
    if ([beaconType isEqualToString:PNLiteAdCustomEndCardImpression]) {
        beaconType = HyBidReportingBeaconType.CUSTOM_ENDCARD_IMPRESSION;
    }
    if ([beaconType isEqualToString:PNLiteAdCustomEndCardClick]) { beaconType = HyBidReportingBeaconType.CUSTOM_ENDCARD_CLICK; }
    if ([beaconType isEqualToString:PNLiteAdCustomCTAImpression]) { beaconType = HyBidReportingEventType.CUSTOM_CTA_IMPRESSION; }
    if ([beaconType isEqualToString:PNLiteAdCustomCTAClick]) { beaconType = HyBidReportingEventType.CUSTOM_CTA_CLICK; }
    if ([beaconType isEqualToString:PNLiteAdCustomCTAEndCardClick]) { beaconType = HyBidReportingEventType.CUSTOM_CTA_ENDCARD_CLICK; }
    
    NSMutableDictionary* beaconProperties = [NSMutableDictionary new];
    [beaconProperties setObject: beaconType forKey: @"type"];
    [beaconProperties setObject: content forKey: @"data"];
    
    HyBidReportingBeacon *reportingBeacon = [[HyBidReportingBeacon alloc] initWith:beaconType properties:beaconProperties];
    return reportingBeacon;
}

- (void)request:(HyBidAdTrackerRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Tracker Request %@ failed with error: %@",request,error.localizedDescription]];
}

#pragma mark HyBidURLDrillerDelegate

- (void)didStartWithURL:(NSURL *)url {
    
}

- (void)didRedirectWithURL:(NSURL *)url {
    
}

- (void)didFinishWithURL:(NSURL *)url trackingType:(NSString *)trackingType {
    [self reportBeaconWithTrackingType:trackingType url:[url absoluteString]];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking %@ with URL: %@",trackingType, [url absoluteString]]];
    [self.adTrackerRequest trackAdWithDelegate:self withURL:[url absoluteString] withTrackingType:trackingType];
}

- (void)didFailWithURL:(NSURL *)url andError:(NSError *)error {
    
}

@end
