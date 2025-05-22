// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanionClickTracking.h"

@interface HyBidVASTCompanionClickTracking ()

@property (nonatomic, strong)HyBidXMLElementEx *companionClickTrackingXMLElement;

@end

@implementation HyBidVASTCompanionClickTracking

- (instancetype)initWithCompanionClickTrackingXMLElement:(HyBidXMLElementEx *)companionClickTrackingXMLElement
{
    if (companionClickTrackingXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.companionClickTrackingXMLElement = companionClickTrackingXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.companionClickTrackingXMLElement value];
}

@end
