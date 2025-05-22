// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTImpression.h"
#import "HyBidXMLEx.h"

@interface HyBidVASTImpression ()

@property (nonatomic, strong)HyBidXMLElementEx *impressionXMLElement;

@end

@implementation HyBidVASTImpression

- (instancetype)initWithImpressionXMLElement:(HyBidXMLElementEx *)impressionXMLElement
{
    self = [super init];
    if (self) {
        self.impressionXMLElement = impressionXMLElement;
    }
    return self;
}

- (NSString *)id
{
    return [self.impressionXMLElement attribute:@"id"];
}

- (NSString *)url
{
    return [self.impressionXMLElement value];
}

@end
