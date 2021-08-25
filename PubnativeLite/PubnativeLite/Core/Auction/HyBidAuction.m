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

#import "HyBidAuction.h"
#import "HyBidError.h"

@implementation HyBidAuction

- (instancetype)initWithAdSources:(NSMutableArray<HyBidAdSourceAbstract *> *)mAuctionAdSources mZoneId:(NSString *)mZoneId timeout:(long)timeoutInMillis {
    if (self) {
        self.mAuctionAdSources = mAuctionAdSources;
        self.mAuctionState = READY;
        self.timeoutInMillis = timeoutInMillis;
        self.mZoneId = mZoneId;
    }
    return self;
}

-(void)runAction:(CompletionAdResponses)completionAdResponses {
    self.completionAdResponses = completionAdResponses;
    self.mMissingResponses = self.mAuctionAdSources.count;
    self.mAdResponses = [[NSMutableArray alloc]init];
    self.mAuctionState = AWAITING_RESPONSES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.timeoutInMillis * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if (self. mAuctionState == AWAITING_RESPONSES) {
            [self processResults];
        }
    });
    
    [self requestFromAdSources];
}

-(void)requestFromAdSources {
    for (HyBidAdSourceAbstract* adSource in self.mAuctionAdSources) {
        [adSource fetchAdWithZoneId:self.mZoneId completionBlock:^(HyBidAd *ad, NSError *error) {
            if (error == nil) {
                [self.mAdResponses addObject:ad];
            }
            self.mMissingResponses -= 1;
            
            if (self.mAuctionState == AWAITING_RESPONSES && self.mMissingResponses <= 0) {
                [self processResults];
            }
        }];
    }
}

-(void) processResults {
    self.mAuctionState = PROCESSING_RESULTS;
    NSArray* mAdResponsesArray = [self.mAdResponses sortedArrayUsingSelector:@selector(compare:)];

    if (self.mAdResponses.count > 0 ) {
        self.mAuctionState = DONE;
        self.completionAdResponses(mAdResponsesArray, nil);
    } else {
        self.mAuctionState = DONE;
        NSError *error = [NSError hyBidAuctionNoAd];
        self.completionAdResponses(nil, error);
    }
}

@end
