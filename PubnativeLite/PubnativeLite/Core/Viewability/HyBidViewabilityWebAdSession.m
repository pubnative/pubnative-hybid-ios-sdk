// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidViewabilityWebAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

@interface HyBidViewabilityWebAdSession()

@property (nonatomic, strong) OMIDPubnativenetMediaEvents *omidMediaEvents;
@property (nonatomic, strong) OMIDPubnativenetAdEvents *adEvents;

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

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    NSString *customReferenceID = @"";
    NSString *contentUrl = @"";
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:[HyBidViewabilityManager sharedInstance].partner
                                                                                                  webView:webView
                                                                                               contentUrl:contentUrl
                                                                                customReferenceIdentifier:customReferenceID
                                                                                                    error:&contextError];
    OMIDOwner impressionOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNativeOwner;
    OMIDOwner mediaEventsOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNoneOwner;
    
    return [self initialseOMIDAdSessionForView:webView withSessionContext:context andImpressionOwner:impressionOwner andMediaEventsOwner:mediaEventsOwner isVideoAd:videoAd];
}

- (OMIDPubnativenetAdSession *)initialseOMIDAdSessionForView:(id)view
                                          withSessionContext:(OMIDPubnativenetAdSessionContext*)context
                                          andImpressionOwner:(OMIDOwner)impressionOwner
                                         andMediaEventsOwner:(OMIDOwner)mediaEventsOwner
                                                   isVideoAd:(BOOL)videoAd{
    NSError *configurationError;
    OMIDCreativeType creativeType = (videoAd) ? OMIDCreativeTypeDefinedByJavaScript : OMIDCreativeTypeHtmlDisplay;
    OMIDImpressionType impressionType = (videoAd) ? OMIDImpressionTypeDefinedByJavaScript : OMIDImpressionTypeBeginToRender;
    
    OMIDPubnativenetAdSessionConfiguration *config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:creativeType
                                                                                                           impressionType:impressionType
                                                                                                          impressionOwner:impressionOwner
                                                                                                         mediaEventsOwner:mediaEventsOwner
                                                                                               isolateVerificationScripts:NO
                                                                                                                    error:&configurationError];
    NSError *sessionError;
    OMIDPubnativenetAdSession *omidAdSession = [[OMIDPubnativenetAdSession alloc] initWithConfiguration:config
                                                                                       adSessionContext:context
                                                                                                  error:&sessionError];
    
    omidAdSession.mainAdView = view;
    
    [[HyBidViewabilityManager sharedInstance]reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];

    return omidAdSession;
}


- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    [super fireOMIDAdLoadEvent:omidAdSession];
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
    return;
    
    if(omidAdSession != nil){
        self.adEvents = [[HyBidViewabilityManager sharedInstance]getAdEvents:omidAdSession];
        
        NSError *loadedError;
        [self.adEvents loadedWithError:&loadedError];
        
    }
}

@end
