//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAdSourceAbstract.h"
#import "HyBidAd.h"

typedef void(^CompletionAdResponses)(NSArray<HyBidAd*>* mAdResponses, NSError* error);

typedef enum {
    READY,
    AWAITING_RESPONSES,
    PROCESSING_RESULTS,
    DONE,
} AuctionState;

@interface HyBidAuction : NSObject

@property (nonatomic, assign) AuctionState mAuctionState;
@property (nonatomic, strong) CompletionAdResponses completionAdResponses;
@property (nonatomic, strong) NSMutableArray<HyBidAdSourceAbstract*>* mAuctionAdSources;
@property (nonatomic, strong) NSMutableArray<HyBidAd*>* mAdResponses;
@property (nonatomic, strong) NSString* mZoneId;

@property long mMissingResponses ;
@property long timeoutInMillis;

- (instancetype)initWithAdSources: (NSMutableArray<HyBidAdSourceAbstract*>*) mAuctionAdSources mZoneId:(NSString*)mZoneId timeout: (long) timeoutInMillis;
-(void)runAction:(CompletionAdResponses)completionAdResponses;

@end

