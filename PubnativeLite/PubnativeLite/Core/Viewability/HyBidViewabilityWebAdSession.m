// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityWebAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

#import "HyBidViewabilityWebAdSession.h"
#import "HyBidViewabilityManager.h"

#import "HyBidViewabilityWebAdSession.h"
#import "HyBidViewabilityManager.h"

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
    #import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
    #import <OMSDK_Smaato/OMIDImports.h>
#endif

@interface HyBidViewabilityWebAdSession()
@property (nonatomic, strong) id omidMediaEvents;
@property (nonatomic, strong) id adEvents;
@end

@implementation HyBidViewabilityWebAdSession

+ (instancetype)sharedInstance {
    static HyBidViewabilityWebAdSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityWebAdSession alloc] init];
    });
    return sharedInstance;
}

- (OMIDAdSessionWrapper*) createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd {
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return nil;

    NSError *contextError;
    NSString *customReferenceID = @"";
    NSString *contentUrl = @"";

    id partner = [HyBidViewabilityManager sharedInstance].partner;

    id context = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:partner
                                                                   webView:webView
                                                                contentUrl:contentUrl
                                                 customReferenceIdentifier:customReferenceID
                                                                     error:&contextError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        context = [[OMIDSmaatoAdSessionContext alloc] initWithPartner:partner
                                                             webView:webView
                                                          contentUrl:contentUrl
                                           customReferenceIdentifier:customReferenceID
                                                               error:&contextError];
        #endif
    }

    OMIDOwner impressionOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNativeOwner;
    OMIDOwner mediaEventsOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNoneOwner;

    id config = nil;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay
                                                                      impressionType:OMIDImpressionTypeBeginToRender
                                                                     impressionOwner:impressionOwner
                                                                    mediaEventsOwner:mediaEventsOwner
                                                          isolateVerificationScripts:NO
                                                                               error:&contextError];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        config = [[OMIDSmaatoAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeHtmlDisplay
                                                                  impressionType:OMIDImpressionTypeBeginToRender
                                                                 impressionOwner:impressionOwner
                                                                mediaEventsOwner:mediaEventsOwner
                                                      isolateVerificationScripts:NO
                                                                           error:&contextError];
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
        [omidAdSession setMainAdView:webView];
        return [[OMIDAdSessionWrapper alloc] initWithAdSession:omidAdSession];
    }

    return nil;
}

- (void)fireOMIDAdLoadEvent:(id)omidAdSession {
    [super fireOMIDAdLoadEvent:omidAdSession];
    if (![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated) return;
    
    if (omidAdSession) {
        self.adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:omidAdSession];

        NSError *loadedError;
        if (self.adEvents) {
            if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
                #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
                [(OMIDPubnativenetAdEvents *)self.adEvents loadedWithError:&loadedError];
                #endif
            } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
                #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
                [(OMIDSmaatoAdEvents *)self.adEvents loadedWithError:&loadedError];
                #endif
            }
        }
    }
}

@end
