// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTStaticResource.h"

@interface HyBidVASTStaticResource ()

@property (nonatomic, strong)HyBidXMLElementEx *staticResourceXMLElement;

@end

@implementation HyBidVASTStaticResource

- (instancetype)initWithStaticResourceXMLElement:(HyBidXMLElementEx *)staticResourceXMLElement
{
    if (staticResourceXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.staticResourceXMLElement = staticResourceXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)creativeType
{
    return [self.staticResourceXMLElement attribute:@"creativeType"];
}

// MARK: - Elements

- (NSString *)content
{
    return [self.staticResourceXMLElement value];
}

@end
