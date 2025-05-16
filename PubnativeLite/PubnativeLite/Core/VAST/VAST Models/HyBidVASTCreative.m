// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCreative.h"

@interface HyBidVASTCreative ()

@property (nonatomic, strong)HyBidXMLElementEx *creativeXMLElement;

@end

@implementation HyBidVASTCreative

- (instancetype)initWithCreativeXMLElement:(HyBidXMLElementEx *)creativeXMLElement
{
    self = [super init];
    if (self) {
        self.creativeXMLElement = creativeXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.creativeXMLElement attribute:@"id"];
}

- (NSString *)adID
{
    return [self.creativeXMLElement attribute:@"adId"];
}

- (NSString *)sequence
{
    return [self.creativeXMLElement attribute:@"sequence"];
}

// MARK: - Elements

- (NSArray<HyBidVASTUniversalAdId *> *)universalAdIds
{
    NSArray<HyBidXMLElementEx *> *result = [self.creativeXMLElement query:@"/UniversalAdId"];
    NSMutableArray<HyBidVASTUniversalAdId *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTUniversalAdId *universalAdId = [[HyBidVASTUniversalAdId alloc] initWithUniversalAdIdXMLElement:result[i]];
        [array addObject:universalAdId];
    }
    
    return array;
}

- (HyBidVASTLinear *)linear
{
    if ([[self.creativeXMLElement query:@"/Linear"] count] > 0) {
        HyBidXMLElementEx *inLineElement = [[self.creativeXMLElement query:@"/Linear"] firstObject];
        return [[HyBidVASTLinear alloc] initWithInLineXMLElement:inLineElement];
    }
    return nil;
}

- (HyBidVASTCompanionAds *)companionAds
{
    if ([[self.creativeXMLElement query:@"/CompanionAds"] count] > 0) {
        HyBidXMLElementEx *companionAdsElement = [[self.creativeXMLElement query:@"/CompanionAds"] firstObject];
        return [[HyBidVASTCompanionAds alloc] initWithCompanionAdsXMLElement:companionAdsElement];
    }
    return nil;
}

@end
