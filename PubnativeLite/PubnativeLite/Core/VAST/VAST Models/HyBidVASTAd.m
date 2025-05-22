// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTAd.h"
#import "HyBidVASTAdCategory.h"

@interface HyBidVASTAd ()

@property (nonatomic, strong)HyBidXMLElementEx *xmlElement;

@end

@implementation HyBidVASTAd

- (instancetype)initWithXMLElement:(HyBidXMLElementEx *)xmlElement
{
    self = [super init];
    if (self) {
        self.xmlElement = xmlElement;
    }
    return self;
}

- (HyBidVASTAdType)adType
{
    HyBidVASTAdType adType = HyBidVASTAdType_NONE;
    NSString *inlineQuery = @"/InLine";
    NSString *wrapperQuery = @"/Wrapper";
        
    if ([[self.xmlElement query:inlineQuery] count] != 0) {
        return HyBidVASTAdType_INLINE;
    } else if ([[self.xmlElement query:wrapperQuery] count] != 0) {
        return HyBidVASTAdType_WRAPPER;
    }
    
    return adType;
}

// MARK: - Attributes

- (NSString *)id
{
    return [self.xmlElement attribute:@"id"];
}

- (NSString *)sequence
{
    return [self.xmlElement attribute:@"sequence"];
}

- (BOOL)isConditionalAd
{
    return [[self.xmlElement attribute:@"conditionalAd"] isEqualToString:@"true"] ? YES : NO;
}

// MARK: - Elements

/**
 The Ad element requires exactly one child, which can either be an <InLine> or <Wrapper> element.
 */
- (HyBidVASTAdInline *)inLine
{
    if ([[self.xmlElement query:@"/InLine"] count] > 0) {
        return [[HyBidVASTAdInline alloc] initWithInLineXMLElement:[[self.xmlElement query:@"/InLine"] firstObject]];
    }
    return nil;
}

/**
 The Ad element requires exactly one child, which can either be an <InLine> or <Wrapper> element.
 */
- (HyBidVASTAdWrapper *)wrapper
{
    if ([[self.xmlElement query:@"/Wrapper"] count] > 0) {
        return [[HyBidVASTAdWrapper alloc] initWithWrapperXMLElement:[[self.xmlElement query:@"/Wrapper"] firstObject]];
    }
    return nil;
}

@end
