// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIconViewTracking.h"

@interface HyBidVASTIconViewTracking ()

@property (nonatomic, strong)HyBidXMLElementEx *iconViewTrackingXMLElement;

@end

@implementation HyBidVASTIconViewTracking

- (instancetype)initWithIconViewTrackingXMLElement:(HyBidXMLElementEx *)iconViewTrackingXMLElement
{
    if (iconViewTrackingXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.iconViewTrackingXMLElement = iconViewTrackingXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.iconViewTrackingXMLElement value];
}

@end
