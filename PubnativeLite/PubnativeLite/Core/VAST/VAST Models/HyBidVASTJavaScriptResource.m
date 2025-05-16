// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTJavaScriptResource.h"

@interface HyBidVASTJavaScriptResource ()

@property (nonatomic, strong)HyBidXMLElementEx *javaScriptResourceXMLElement;

@end

@implementation HyBidVASTJavaScriptResource

- (instancetype)initWithJavaScriptResourceXMLElement:(HyBidXMLElementEx *)javaScriptResourceXMLElement
{
    if (self) {
        self.javaScriptResourceXMLElement = javaScriptResourceXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)browserOptional
{
    return [self.javaScriptResourceXMLElement attribute:@"browserOptional"];
}

// MARK: - Elements

- (NSString *)url
{
    return [self.javaScriptResourceXMLElement value];
}

@end
