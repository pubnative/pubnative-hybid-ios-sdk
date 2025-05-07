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

#import "OMIDAdSessionWrapper.h"
#import "HyBid.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
    #import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
    #import <OMSDK_Smaato/OMIDImports.h>
#endif

@implementation OMIDAdSessionWrapper

- (instancetype)initWithAdSession:(id)session {
    self = [super init];
    if (self) {
        _adSession = session;
    }
    return self;
}

- (void)addFriendlyObstruction:(UIView *)view withReason:(NSString *)reason isInterstitial:(BOOL)isInterstitial {
    if (!_adSession || !view) return;

    NSError *error;
    
    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        [(OMIDPubnativenetAdSession *)_adSession addFriendlyObstruction:view
                                                                purpose:(isInterstitial ? OMIDFriendlyObstructionCloseAd : OMIDFriendlyObstructionOther)
                                                         detailedReason:reason
                                                                  error:&error];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        [(OMIDSmaatoAdSession *)_adSession addFriendlyObstruction:view
                                                          purpose:(isInterstitial ? OMIDFriendlyObstructionCloseAd : OMIDFriendlyObstructionOther)
                                                   detailedReason:reason
                                                            error:&error];
        #endif
    }

    if (error) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Failed to add friendly obstruction: %@", error.localizedDescription]];
    }
}

- (void)startAdSession {
    if (!_adSession) return;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        [(OMIDPubnativenetAdSession *)_adSession start];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        [(OMIDSmaatoAdSession *)_adSession start];
        #endif
    }
}

- (void)stopAdSession {
    if (!_adSession) return;

    if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
        #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
        [(OMIDPubnativenetAdSession *)_adSession finish];
        #endif
    } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
        #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
        [(OMIDSmaatoAdSession *)_adSession finish];
        #endif
    }
}

- (void)fireAdLoadEvent {
    if (!_adSession) return;

    id adEvents = [[HyBidViewabilityManager sharedInstance] getAdEvents:self];

    if (adEvents) {
        NSError *error = nil;
        
        if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
            #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
            [(OMIDPubnativenetAdEvents *)adEvents loadedWithError:&error];
            #endif
        } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
            #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
            [(OMIDSmaatoAdEvents *)adEvents loadedWithError:&error];
            #endif
        }

        if (error) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Error firing ad load event: %@", error.localizedDescription]];
        }
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad events object is nil. Cannot fire ad load event"];
    }
}

@end
