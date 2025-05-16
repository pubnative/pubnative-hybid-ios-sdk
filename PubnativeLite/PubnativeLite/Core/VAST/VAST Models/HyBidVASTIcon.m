// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIcon.h"

@interface HyBidVASTIcon ()

@property (nonatomic, strong)HyBidXMLElementEx *iconXmlElement;

@end

@implementation HyBidVASTIcon

- (instancetype)initWithIconXMLElement:(HyBidXMLElementEx *)iconXMLElement
{
    self = [super init];
    if (self) {
        self.iconXmlElement = iconXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)duration
{
    return [self.iconXmlElement attribute:@"duration"];
}

- (NSString *)height
{
    return [self.iconXmlElement attribute:@"height"];
}

- (NSString *)width
{
    return [self.iconXmlElement attribute:@"width"];
}

- (NSString *)offset
{
    return [self.iconXmlElement attribute:@"offset"];
}

- (NSString *)program
{
    return [self.iconXmlElement attribute:@"program"];
}

- (NSString *)pxRatio
{
    return [self.iconXmlElement attribute:@"pxratio"];
}

- (NSString *)xPosition
{
    return [self.iconXmlElement attribute:@"xPosition"];
}

- (NSString *)yPosition
{
    return [self.iconXmlElement attribute:@"yPosition"];
}

// MARK: - Elements

- (NSArray<HyBidVASTIconViewTracking *> *)iconViewTracking
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconXmlElement query:@"/IconViewTracking"];
    NSMutableArray<HyBidVASTIconViewTracking *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTIconViewTracking *iconViewTracking = [[HyBidVASTIconViewTracking alloc] initWithIconViewTrackingXMLElement:result[i]];
        [array addObject:iconViewTracking];
    }
    
    return array;
}

- (NSArray<HyBidVASTStaticResource *> *)staticResources
{
    NSArray<HyBidXMLElementEx *> *result = [self.iconXmlElement query:@"/StaticResource"];
    NSMutableArray<HyBidVASTStaticResource *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTStaticResource *staticResource = [[HyBidVASTStaticResource alloc] initWithStaticResourceXMLElement:result[i]];
        [array addObject:staticResource];
    }
    
    return array;
}

- (HyBidVASTIconClicks *)iconClicks
{
    if ([[self.iconXmlElement query:@"/IconClicks"] count] > 0) {
        HyBidXMLElementEx *iconClicksElement = [[self.iconXmlElement query:@"/IconClicks"] firstObject];
        HyBidVASTIconClicks *iconClicks = [[HyBidVASTIconClicks alloc] initWithIconClicksXMLElement:iconClicksElement];
        
        return iconClicks;
    }
    return nil;
}

@end
