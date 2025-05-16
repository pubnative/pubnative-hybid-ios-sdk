// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTVideoClicks.h"

@interface HyBidVASTVideoClicks ()

@property (nonatomic, strong)HyBidXMLElementEx *videoClicksXMLElement;

@end

@implementation HyBidVASTVideoClicks

- (instancetype)initWithVideoClicksXMLElement:(HyBidXMLElementEx *)videoClicksXMLElement;
{
    if (videoClicksXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.videoClicksXMLElement = videoClicksXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTClickTracking *> *)clickTrackings
{
    NSString *query = @"/ClickTracking";
    NSArray<HyBidXMLElementEx *> *result = [self.videoClicksXMLElement query:query];
    NSMutableArray<HyBidVASTClickTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTClickTracking *clickTracking = [[HyBidVASTClickTracking alloc] initWithClickTrackingXMLElement:result[i]];
        [array addObject:clickTracking];
    }
    
    return array;
}

- (HyBidVASTClickThrough *)clickThrough
{
    if ([[self.videoClicksXMLElement query:@"/ClickThrough"] count] > 0) {
        HyBidXMLElementEx *clickThroughElement = [[self.videoClicksXMLElement query:@"/ClickThrough"] firstObject];
        
        return [[HyBidVASTClickThrough alloc] initWithClickThroughXMLElement:clickThroughElement];
    }
    return nil;
}

- (NSArray<HyBidVASTCustomClick *> *)customClicks
{
    NSString *query = @"/CustomClick";
    NSArray<HyBidXMLElementEx *> *result = [self.videoClicksXMLElement query:query];
    NSMutableArray<HyBidVASTCustomClick *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTCustomClick *customClick = [[HyBidVASTCustomClick alloc] initWithCustomClickXMLElement:result[i]];
        [array addObject:customClick];
    }
    
    return array;
}


@end
