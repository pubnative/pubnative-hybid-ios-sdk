//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "HyBidViewabilityManager.h"
#import <OMSDK_Pubnativenet/OMIDImports.h>
#import "HyBidLogger.h"
#import "HyBidConstants.h"

static NSString *const HyBidViewabilityPartnerName = @"Pubnativenet";
static NSString *const HyBidOMIDSDKJSFilename = @"omsdk";

@interface HyBidViewabilityManager()

@property (nonatomic, assign) BOOL isViewabilityMeasurementActivated;
@property (nonatomic, readwrite, strong) NSString* omidJSString;
@property (nonatomic, strong) OMIDPubnativenetPartner *partner;

@end

@implementation HyBidViewabilityManager

+ (instancetype)sharedInstance {
    static HyBidViewabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidViewabilityManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.viewabilityMeasurementEnabled = YES;
        NSError *error;
        
        if (!OMIDPubnativenetSDK.sharedInstance.isActive) {
            [[OMIDPubnativenetSDK sharedInstance] activate];
            self.partner = [[OMIDPubnativenetPartner alloc] initWithName:HyBidViewabilityPartnerName versionString:HYBID_SDK_VERSION];
        } else {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Viewability Manager couldn't initialized properly with error: %@", error.debugDescription]];
        }
        
        if(!self.omidJSString){
            [self fetchOMIDJS];
        }
    }
    return self;
}

- (void)fetchOMIDJS {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *omSdkJSPath = [bundle pathForResource:HyBidOMIDSDKJSFilename ofType:@"js"];
    if (!omSdkJSPath) {
        return;
    }
    NSData *omSdkJsData = [NSData dataWithContentsOfFile:omSdkJSPath];
    self.omidJSString = [[NSString alloc] initWithData:omSdkJsData encoding:NSUTF8StringEncoding];
}

- (NSString *)getOMIDJS {
    if(!self.isViewabilityMeasurementActivated)
        return nil;
    
    NSString *scriptContent  = nil;
    @synchronized (self) {
        scriptContent  = self.omidJSString;
        if (!scriptContent) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Script Content is nil."];
            scriptContent=  @"";
        }
    }
    return scriptContent;
}

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforWebView:(WKWebView *)webView isVideoAd:(BOOL)videoAd {
    if(!self.isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    NSString *customReferenceID = @"";
    NSString *contentUrl = @"";
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:self.partner
                                                                                                  webView:webView
                                                                                               contentUrl:contentUrl
                                                                                customReferenceIdentifier:customReferenceID
                                                                                                    error:&contextError];
    OMIDOwner impressionOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNativeOwner;
    OMIDOwner mediaEventsOwner = (videoAd) ? OMIDJavaScriptOwner : OMIDNoneOwner;
    
    return [self initialseOMIDAdSessionForView:webView withSessionContext:context andImpressionOwner:impressionOwner andMediaEventsOwner:mediaEventsOwner isVideoAd:videoAd];
}

- (OMIDPubnativenetAdSession *)createOMIDAdSessionforNative:(UIView *)view withScript:(NSMutableArray *)scripts {
    if(!self.isViewabilityMeasurementActivated)
        return nil;
    
    NSError *contextError;
    
    OMIDPubnativenetAdSessionContext *context = [[OMIDPubnativenetAdSessionContext alloc] initWithPartner:self.partner
                                                                                                   script:self.getOMIDJS
                                                                                                resources:scripts
                                                                                               contentUrl:nil
                                                                                customReferenceIdentifier:nil
                                                                                                    error:&contextError];
    
    return [self initialseOMIDAdSessionForView:view withSessionContext:context andImpressionOwner:OMIDNativeOwner andMediaEventsOwner:OMIDNoneOwner isVideoAd:NO];
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
    
    return omidAdSession;
}

- (void)startOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession start];
    }
}

- (void)stopOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession finish];
        omidAdSession = nil;
    }
}

- (void)fireOMIDImpressionOccuredEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        NSError *adEventsError;
        OMIDPubnativenetAdEvents *adEvents = [[OMIDPubnativenetAdEvents alloc] initWithAdSession:omidAdSession error:&adEventsError];
        NSError *impressionError;
        [adEvents impressionOccurredWithError:&impressionError];
    }
}

- (void)addFriendlyObstruction:(UIView *)view toOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession isInterstitial:(BOOL)isInterstitial {
    if(!self.isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        NSError *addFriendlyObstructionError;
        if (isInterstitial) {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionCloseAd
                                   detailedReason:nil
                                            error:&addFriendlyObstructionError];
        } else {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionOther
                                   detailedReason:@"This view is related to Content Info"
                                            error:&addFriendlyObstructionError];
        }
    }
}

- (BOOL)isViewabilityMeasurementActivated {
    return OMIDPubnativenetSDK.sharedInstance.isActive && self.viewabilityMeasurementEnabled;
}

@end
