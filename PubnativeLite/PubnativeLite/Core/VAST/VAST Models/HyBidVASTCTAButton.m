// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCTAButton.h"

@interface HyBidVASTCTAButton ()

@property (nonatomic, strong)HyBidXMLElementEx *ctaButtonXMLElement;

@end

@implementation HyBidVASTCTAButton

- (instancetype)initWithCTAButtonXMLElement:(HyBidXMLElementEx *)ctaButtonXMLElement
{
    if (ctaButtonXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.ctaButtonXMLElement = ctaButtonXMLElement;
    }
    return self;
}

// MARK: - Elements

- (NSString *)htmlData
{
    NSString *query = @"/HtmlData";
    if ([[self.ctaButtonXMLElement query:query] count] > 0) {
        HyBidXMLElementEx* element = [[self.ctaButtonXMLElement query:query] firstObject];
        return [element value];
    }
    return nil;
}

- (HyBidVASTTrackingEvents *)trackingEvents
{
    if ([[self.ctaButtonXMLElement query:@"/TrackingEvents"] count] > 0) {
        HyBidXMLElementEx *trackingEventsElement = [[self.ctaButtonXMLElement query:@"/TrackingEvents"] firstObject];
        return [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:trackingEventsElement];
    }
    return nil;
}

@end
