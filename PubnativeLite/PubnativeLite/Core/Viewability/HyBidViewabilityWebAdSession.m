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
