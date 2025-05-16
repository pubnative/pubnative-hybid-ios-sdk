// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTCompanion.h"

@interface HyBidVASTCompanion ()

@property (nonatomic, strong)HyBidXMLElementEx *companionXMLElement;

@end

@implementation HyBidVASTCompanion

- (instancetype)initWithCompanionXMLElement:(HyBidXMLElementEx *)companionXMLElement
{
    if (companionXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.companionXMLElement = companionXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.companionXMLElement attribute:@"id"];
}

- (NSString *)width
{
    return [self.companionXMLElement attribute:@"width"];
}

- (NSString *)height
{
    return [self.companionXMLElement attribute:@"height"];
}

- (NSString *)assetWidth
{
    return [self.companionXMLElement attribute:@"assetWidth"];
}

- (NSString *)assetHeight
{
    return [self.companionXMLElement attribute:@"assetHeight"];
}

- (NSString *)expandedWidth
{
    return [self.companionXMLElement attribute:@"expandedWidth"];
}

- (NSString *)expandedHeight
{
    return [self.companionXMLElement attribute:@"expandedHeight"];
}

// MARK: - Elements

- (NSArray<HyBidVASTStaticResource *> *)staticResources
{
    NSArray<HyBidXMLElementEx *> *result = [self.companionXMLElement query:@"/StaticResource"];
    NSMutableArray<HyBidVASTStaticResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTStaticResource *staticResource = [[HyBidVASTStaticResource alloc] initWithStaticResourceXMLElement:result[i]];
        [array addObject:staticResource];
    }
    
    return array;
}

- (HyBidVASTAdParameters *)adParameters
{
    if ([[self.companionXMLElement query:@"/AdParameters"] count] > 0) {
        HyBidXMLElementEx *adParametersElement = [[self.companionXMLElement query:@"/AdParameters"] firstObject];
        return [[HyBidVASTAdParameters alloc] initWithAdParametersXMLElement:adParametersElement];
    }
    return nil;
}

- (HyBidVASTCompanionClickThrough *)companionClickThrough
{
    if ([[self.companionXMLElement query:@"/CompanionClickThrough"] count] > 0) {
        HyBidXMLElementEx *companionClickThroughElement = [[self.companionXMLElement query:@"/CompanionClickThrough"] firstObject];
        
        return [[HyBidVASTCompanionClickThrough alloc] initWithCompanionClickThroughXMLElement:companionClickThroughElement];
    }
    return nil;
}

- (NSArray<HyBidVASTCompanionClickTracking *>  *)companionClickTracking
{
    NSString *query = @"/CompanionClickTracking";
    NSArray<HyBidXMLElementEx *> *result = [self.companionXMLElement query:query];
    NSMutableArray<HyBidVASTCompanionClickTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTCompanionClickTracking *clickTracking = [[HyBidVASTCompanionClickTracking alloc] initWithCompanionClickTrackingXMLElement:result[i]];
        [array addObject:clickTracking];
    }
    
    return array;
}

- (HyBidVASTTrackingEvents *)trackingEvents
{
    if ([[self.companionXMLElement query:@"/TrackingEvents"] count] > 0) {
        HyBidXMLElementEx *trackingEventsElement = [[self.companionXMLElement query:@"/TrackingEvents"] firstObject];
        return [[HyBidVASTTrackingEvents alloc] initWithTrackingEventsXMLElement:trackingEventsElement];
    }
    return nil;
}

- (NSArray<HyBidVASTHTMLResource *> *)htmlResources
{
    NSString *query = @"/HTMLResource";
    NSArray<HyBidXMLElementEx *> *result = [self.companionXMLElement query:query];
    NSMutableArray<HyBidVASTHTMLResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTHTMLResource *htmlResource = [[HyBidVASTHTMLResource alloc] initWithHTMLResourceXMLElement:result[i]];
        [array addObject:htmlResource];
    }
    
    return array;
}

- (NSArray<HyBidVASTIFrameResource *> *)iFrameResources
{
    NSString *query = @"/IFrameResource";
    NSArray<HyBidXMLElementEx *> *result = [self.companionXMLElement query:query];
    NSMutableArray<HyBidVASTIFrameResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTIFrameResource *iFrameResource = [[HyBidVASTIFrameResource alloc] initWithIFrameResourceXMLElement:result[i]];
        [array addObject:iFrameResource];
    }
    
    return array;
}


@end
