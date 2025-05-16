// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTAdSystem.h"

@interface HyBidVASTAdSystem ()

@property (nonatomic, strong)HyBidXMLElementEx *adSystemXmlElement;

@end

@implementation HyBidVASTAdSystem

- (instancetype)initWithAdSystemXMLElement:(HyBidXMLElementEx *)adSystemXmlElement
{
    self = [super init];
    if (self) {
        self.adSystemXmlElement = adSystemXmlElement;
    }
    return self;
}

- (NSString *)version
{
    return [self.adSystemXmlElement attribute:@"version"];
}

- (NSString *)system
{
    return [self.adSystemXmlElement value];
}

@end
