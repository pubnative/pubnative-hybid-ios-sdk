// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTUniversalAdId.h"

@interface HyBidVASTUniversalAdId ()

@property (nonatomic, strong)HyBidXMLElementEx *universalAdIdXMLElement;

@end

@implementation HyBidVASTUniversalAdId

- (instancetype)initWithUniversalAdIdXMLElement:(HyBidXMLElementEx *)universalAdIdXMLElement;
{
    self = [super init];
    if (self) {
        self.universalAdIdXMLElement = universalAdIdXMLElement;
    }
    return self;
}

- (NSString *)idRegistry
{
    return [self.universalAdIdXMLElement attribute:@"idRegistry"];
}

- (NSString *)universalAdId
{
    return [self.universalAdIdXMLElement value];
}

@end
