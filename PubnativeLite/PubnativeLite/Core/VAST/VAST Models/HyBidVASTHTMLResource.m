// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTHTMLResource.h"
#import "UIKit/UIKit.h"

@interface HyBidVASTHTMLResource ()

@property (nonatomic, strong)HyBidXMLElementEx *htmlResourceXMLElement;

@end

@implementation HyBidVASTHTMLResource

- (instancetype)initWithHTMLResourceXMLElement:(HyBidXMLElementEx *)htmlResourceXMLElement
{
    if (htmlResourceXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.htmlResourceXMLElement = htmlResourceXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.htmlResourceXMLElement value];
}

@end
