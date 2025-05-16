// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTClickThrough.h"

@interface HyBidVASTClickThrough ()

@property (nonatomic, strong)HyBidXMLElementEx *clickThroughXMLElement;

@end

@implementation HyBidVASTClickThrough

- (instancetype)initWithClickThroughXMLElement:(HyBidXMLElementEx *)clickThroughXMLElement
{
    if (clickThroughXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.clickThroughXMLElement = clickThroughXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.clickThroughXMLElement attribute:@"id"];
}

- (NSString *)content
{
    return [self.clickThroughXMLElement value];
}

@end
