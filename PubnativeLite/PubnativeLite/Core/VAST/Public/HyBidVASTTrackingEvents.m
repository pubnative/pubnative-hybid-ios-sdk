// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTTrackingEvents.h"

@interface HyBidVASTTrackingEvents ()

@property (nonatomic, strong)HyBidXMLElementEx *trackingEventsXMLElement;

@end

@implementation HyBidVASTTrackingEvents

- (instancetype)initWithTrackingEventsXMLElement:(HyBidXMLElementEx *)trackingEventsXMLElement
{
    if (trackingEventsXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.trackingEventsXMLElement = trackingEventsXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTTracking *> *)events
{
    NSString *query = @"/Tracking";
    NSArray<HyBidXMLElementEx *> *result = [self.trackingEventsXMLElement query:query];
    NSMutableArray<HyBidVASTTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTTracking *event = [[HyBidVASTTracking alloc] initWithTrackingXMLElement:result[i]];
        [array addObject:event];
    }
    
    return array;
}

@end
