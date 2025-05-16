// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanionClickThrough.h"

@interface HyBidVASTCompanionClickThrough ()

@property (nonatomic, strong)HyBidXMLElementEx *companionClickThroughXMLElement;

@end

@implementation HyBidVASTCompanionClickThrough

- (instancetype)initWithCompanionClickThroughXMLElement:(HyBidXMLElementEx *)companionClickThroughXMLElement
{
    if (companionClickThroughXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.companionClickThroughXMLElement = companionClickThroughXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.companionClickThroughXMLElement value];
}

@end
