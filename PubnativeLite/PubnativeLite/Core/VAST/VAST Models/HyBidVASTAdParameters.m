// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTAdParameters.h"

@interface HyBidVASTAdParameters ()

@property (nonatomic, strong)HyBidXMLElementEx *adParametersXMLElement;

@end

@implementation HyBidVASTAdParameters

- (instancetype)initWithAdParametersXMLElement:(HyBidXMLElementEx *)adParametersXMLElement
{
    self = [super init];
    if (self) {
        self.adParametersXMLElement = adParametersXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)xmlEncoded
{
    return [self.adParametersXMLElement attribute:@"xmlEncoded"];
}

// MARK: - Values

- (NSString *)content
{
    return [self.adParametersXMLElement value];
}

@end
