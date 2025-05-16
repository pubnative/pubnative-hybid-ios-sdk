// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTClickTracking.h"

@interface HyBidVASTClickTracking ()

@property (nonatomic, strong)HyBidXMLElementEx *clickTrackingXMLElement;

@end

@implementation HyBidVASTClickTracking

- (instancetype)initWithClickTrackingXMLElement:(HyBidXMLElementEx *)clickTrackingXMLElement
{
    if (clickTrackingXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.clickTrackingXMLElement = clickTrackingXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.clickTrackingXMLElement attribute:@"id"];
}

- (NSString *)content
{
    return [self.clickTrackingXMLElement value];
}

@end
