// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIconClickThrough.h"

@interface HyBidVASTIconClickThrough ()

@property (nonatomic, strong)HyBidXMLElementEx *iconClickThroughXMLElement;

@end

@implementation HyBidVASTIconClickThrough

- (instancetype)initWithIconClickThroughXMLElement:(HyBidXMLElementEx *)iconClickThroughXMLElement
{
    if (iconClickThroughXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iconClickThroughXMLElement = iconClickThroughXMLElement;
    }
    return self;
}

// MARK: - Elements

- (NSString *)content
{
    return [self.iconClickThroughXMLElement value];
}


@end
