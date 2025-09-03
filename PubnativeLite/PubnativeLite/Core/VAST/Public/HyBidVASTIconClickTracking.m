// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIconClickTracking.h"

@interface HyBidVASTIconClickTracking ()

@property (nonatomic, strong)HyBidXMLElementEx *iconClickTrackingXMLElement;

@end

@implementation HyBidVASTIconClickTracking

- (instancetype)initWithIconClickTrackingXMLElement:(HyBidXMLElementEx *)iconClickTrackingXMLElement
{
    if (iconClickTrackingXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iconClickTrackingXMLElement = iconClickTrackingXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.iconClickTrackingXMLElement attribute:@"id"];
}

- (NSString *)content
{
    return [self.iconClickTrackingXMLElement value];
}

@end
