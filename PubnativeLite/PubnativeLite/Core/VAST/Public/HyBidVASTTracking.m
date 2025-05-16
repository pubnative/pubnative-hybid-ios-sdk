// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTTracking.h"

@interface HyBidVASTTracking ()

@property (nonatomic, strong)HyBidXMLElementEx *trackingXMLElement;

@end

@implementation HyBidVASTTracking

- (instancetype)initWithTrackingXMLElement:(HyBidXMLElementEx *)trackingXMLElement
{
    self = [super init];
    if (self) {
        self.trackingXMLElement = trackingXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)event
{
    return [self.trackingXMLElement attribute:@"event"];
}

// MARK: - Values

- (NSString *)url
{
    return [self.trackingXMLElement value];
}

- (NSString *)offset
{
    return [self.trackingXMLElement attribute:@"offset"];
}



@end
