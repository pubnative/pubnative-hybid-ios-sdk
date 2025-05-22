// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanionAds.h"

@interface HyBidVASTCompanionAds ()

@property (nonatomic, strong)HyBidXMLElementEx *companionAdsXMLElement;

@end

@implementation HyBidVASTCompanionAds

- (instancetype)initWithCompanionAdsXMLElement:(HyBidXMLElementEx *)companionAdsXMLElement
{
    if (companionAdsXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.companionAdsXMLElement = companionAdsXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (HyBidVASTCompanionAdRequirement)required
{
    NSString *required = [self.companionAdsXMLElement attribute:@"required"];
    
    if ([required isEqualToString:@"all"]) {
        return HyBidVASTCompanionAdRequirement_ALL;
    } else if ([required isEqualToString:@"any"]) {
        return HyBidVASTCompanionAdRequirement_ANY;
    } else {
        return HyBidVASTCompanionAdRequirement_NONE;
    }
}

- (NSArray<HyBidVASTCompanion *> *)companions
{
    NSArray<HyBidXMLElementEx *> *companionElementsArray = [self.companionAdsXMLElement query:@"/Companion"];
    NSMutableArray<HyBidVASTCompanion *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [companionElementsArray count]; i++) {
        HyBidVASTCompanion *companion = [[HyBidVASTCompanion alloc] initWithCompanionXMLElement:companionElementsArray[i]];
        [array addObject:companion];
    }
    
    return array;
}

@end
