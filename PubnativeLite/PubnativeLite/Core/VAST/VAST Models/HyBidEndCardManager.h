// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanion.h"
#import "HyBidEndCard.h"
#import "HyBidVASTCompanionAds.h"
#import "HyBidVASTCreative.h"

@interface HyBidEndCardManager : NSObject

- (void)addCompanion:(HyBidVASTCompanion *)companion completion:(void(^)(void))completion;
- (HyBidVASTCompanion *)pickBestCompanionFromCompanionAds:(HyBidVASTCompanionAds *)companionAds;
- (NSArray<HyBidEndCard *> *)endCards;
- (void)fetchEndCardsFromCreatives:(NSArray<HyBidVASTCreative *>*)creatives
                        completion:(void(^)(NSArray<HyBidEndCard *> *endCards))completion;

@end
