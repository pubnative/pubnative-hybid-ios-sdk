////
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

#import "Auction.h"

@implementation Auction

long mMissingResponses;
long timeoutInMillis;

- (instancetype)initWithAdSources:(NSMutableArray<AdSource *> *)mAuctionAdSources timeout:(int)timeoutInMillis completion:(CompletionAdResponses)completionAdResponses {
    if (self) {
        self.mAuctionAdSources = mAuctionAdSources;
        self.completionAdResponses = completionAdResponses;
        self.mAuctionState = READY;
        timeoutInMillis = timeoutInMillis;
    }
    return self;
}

-(void)timerFired {
    if (self.mAuctionState == AWAITING_RESPONSES) {
        [self processResults];
    }
}

-(void)runAction {
    mMissingResponses = self.mAuctionAdSources.count;
    [self.mAdResponses removeAllObjects];
    self.mAuctionState = AWAITING_RESPONSES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeoutInMillis target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    [self requestFromAdSources];
}

-(void)requestFromAdSources {
    for (AdSource* adSource in self.mAuctionAdSources) {
        [adSource fetchAd:^(HyBidAd *ad, NSError *error) {
            if (error == nil) {
                [self.mAdResponses addObject:ad];
            }
            mMissingResponses -= 1;
            
            if (self.mAuctionState == AWAITING_RESPONSES && mMissingResponses <= 0) {
                [self processResults];
            }
            
        }];
    }
}

-(void) processResults {
    self.mAuctionState = PROCESSING_RESULTS;
    if (self.mAdResponses.count > 0 ) {
        self.mAuctionState = DONE;
        self.completionAdResponses(self.mAdResponses, nil);
    } else {
        self.mAuctionState = DONE;
        NSError *error = [NSError errorWithDomain:@"The auction concluded without any winning bid."
                                             code:0
                                         userInfo:nil];
        self.completionAdResponses(nil, error);
    }
}

@end
