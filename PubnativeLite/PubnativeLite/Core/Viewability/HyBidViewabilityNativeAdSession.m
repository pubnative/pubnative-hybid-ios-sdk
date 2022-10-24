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

#import "HyBidViewabilityNativeAdSession.h"
#import "HyBid.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidViewabilityNativeAdSession

+ (instancetype)sharedInstance {
    static HyBidViewabilityNativeAdSession *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityNativeAdSession alloc] init];
    });
    return sharedInstance;
}

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:[HyBidViewabilityManager sharedInstance].partner
                                                                                                   script:[[HyBidViewabilityManager sharedInstance] getOMIDJS]
                                                                                                resources:scripts
                                                                                               contentUrl:nil
                                                                                customReferenceIdentifier:nil
                                                                                                    error:&contextError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNoneOwner];
}

- (OMIDPubnativenetAdSession *)initialseOMIDAdSessionForView:(id)view
                                          withSessionContext:(OMIDPubnativenetAdSessionContext*)context
                                          andImpressionOwner:(OMIDOwner)impressionOwner
                                         andMediaEventsOwner:(OMIDOwner)mediaEventsOwner{
    NSError *configurationError;
    
    OMIDPubnativenetAdSessionConfiguration *config = [[OMIDPubnativenetAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeNativeDisplay
                                                                                                           impressionType:OMIDImpressionTypeBeginToRender
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
         OMIDPubnativenetAdEvents* adEvents = [[HyBidViewabilityManager sharedInstance]getAdEvents:omidAdSession];
        
        NSError *loadedError;
        [adEvents loadedWithError:&loadedError];
        
    }
}

@end
