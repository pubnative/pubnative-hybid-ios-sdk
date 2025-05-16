//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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
