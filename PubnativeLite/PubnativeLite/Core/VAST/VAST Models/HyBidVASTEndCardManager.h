// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanion.h"
#import "HyBidVASTEndCard.h"
#import "HyBidVASTCompanionAds.h"


@interface HyBidVASTEndCardManager : NSObject

- (void)addCompanion:(HyBidVASTCompanion *)companion completion:(void(^)(void))completion;
- (HyBidVASTCompanion *)pickBestCompanionFromCompanionAds:(HyBidVASTCompanionAds *)companionAds;
- (NSArray<HyBidVASTEndCard *> *)endCards;

@end
