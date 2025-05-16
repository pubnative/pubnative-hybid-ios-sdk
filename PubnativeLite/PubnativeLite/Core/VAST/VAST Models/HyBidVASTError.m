// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTError.h"

@interface HyBidVASTError ()

@property (nonatomic, strong)HyBidXMLElementEx *errorXMLElement;

@end

@implementation HyBidVASTError

- (instancetype)initWithErrorXMLElement:(HyBidXMLElementEx *)errorXMLElement
{
    if (errorXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.errorXMLElement = errorXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.errorXMLElement value];
}

@end
