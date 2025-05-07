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
    
    if (!partner) {
        NSLog(@"❌ OMID Partner is nil, cannot create ad session.");
        return nil;
    }

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

    if (!context) return nil;

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
        [omidAdSession setMainAdView:webView];
        [[HyBidViewabilityManager sharedInstance] reportEvent:HyBidReportingEventType.AD_SESSION_INITIALIZED];
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
