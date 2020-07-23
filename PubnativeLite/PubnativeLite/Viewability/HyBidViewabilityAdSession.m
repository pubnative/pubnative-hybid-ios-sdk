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

#import "HyBidViewabilityAdSession.h"

@implementation HyBidViewabilityAdSession

+ (instancetype)sharedInstance {
    return nil;
}

- (void)startOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession start];
    }
}

- (void)stopOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession){
        [omidAdSession finish];
        omidAdSession = nil;
    }
}

- (void)fireOMIDImpressionOccuredEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        if ([HyBidViewabilityManager sharedInstance].adEvents == nil) {
            NSError *adEventsError;
            [HyBidViewabilityManager sharedInstance].adEvents = [[OMIDPubnativenetAdEvents alloc] initWithAdSession:omidAdSession error:&adEventsError];
        }

        NSError *impressionError;
        [[HyBidViewabilityManager sharedInstance].adEvents impressionOccurredWithError:&impressionError];
        
    }
}

- (void)fireOMIDAdLoadEvent:(OMIDPubnativenetAdSession *)omidAdSession {
    
}

- (void)addFriendlyObstruction:(UIView *)view toOMIDAdSession:(OMIDPubnativenetAdSession *)omidAdSession withReason:(NSString *)reasonForFriendlyObstruction isInterstitial:(BOOL)isInterstitial {
    
    if(![HyBidViewabilityManager sharedInstance].isViewabilityMeasurementActivated)
        return;
    
    if(omidAdSession != nil){
        NSError *addFriendlyObstructionError;
        if (isInterstitial) {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionCloseAd
                                   detailedReason:reasonForFriendlyObstruction
                                            error:&addFriendlyObstructionError];
        } else {
            [omidAdSession addFriendlyObstruction:view
                                          purpose:OMIDFriendlyObstructionOther
                                   detailedReason:reasonForFriendlyObstruction
                                            error:&addFriendlyObstructionError];
        }
    }
}

@end
