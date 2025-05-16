// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIFrameResource.h"

@interface HyBidVASTIFrameResource ()

@property (nonatomic, strong)HyBidXMLElementEx *iFrameResourceXMLElement;

@end

@implementation HyBidVASTIFrameResource

- (instancetype)initWithIFrameResourceXMLElement:(HyBidXMLElementEx *)iFrameResourceXMLElement
{
    if (iFrameResourceXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iFrameResourceXMLElement = iFrameResourceXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.iFrameResourceXMLElement value];
}

@end
