// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCustomClick.h"

@interface HyBidVASTCustomClick ()

@property (nonatomic, strong)HyBidXMLElementEx *customClickXMLElement;

@end

@implementation HyBidVASTCustomClick

- (instancetype)initWithCustomClickXMLElement:(HyBidXMLElementEx *)customClickXMLElement
{
    if (customClickXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.customClickXMLElement = customClickXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.customClickXMLElement attribute:@"id"];
}

- (NSString *)content
{
    return [self.customClickXMLElement value];
}

@end
