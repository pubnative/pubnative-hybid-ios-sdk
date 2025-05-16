// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIconClicks.h"

@interface HyBidVASTIconClicks ()

@property (nonatomic, strong)HyBidXMLElementEx *iconClicksXMLElement;

@end

@implementation HyBidVASTIconClicks

- (instancetype)initWithIconClicksXMLElement:(HyBidXMLElementEx *)iconClicksXMLElement
{
    if (iconClicksXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iconClicksXMLElement = iconClicksXMLElement;
    }
    return self;
}

- (HyBidVASTIconClickThrough *)iconClickThrough
{
    if ([[self.iconClicksXMLElement query:@"/IconClickThrough"] count] > 0) {
        HyBidXMLElementEx *iconClickThroughElement = [[self.iconClicksXMLElement query:@"/IconClickThrough"] firstObject];
        HyBidVASTIconClickThrough *iconClickThrough = [[HyBidVASTIconClickThrough alloc] initWithIconClickThroughXMLElement:iconClickThroughElement];
        
        return iconClickThrough;
    }
    return nil;
}

- (NSArray<HyBidVASTIconClickTracking *> *)iconClickTracking
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconClicksXMLElement query:@"/IconClickTracking"];
    NSMutableArray<HyBidVASTIconClickTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTIconClickTracking *iconClickTracking = [[HyBidVASTIconClickTracking alloc] initWithIconClickTrackingXMLElement:result[i]];
        [array addObject:iconClickTracking];
    }
    
    return array;
}

@end
