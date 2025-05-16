// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTAdCategory.h"
#import "HyBidXMLEx.h"

@interface HyBidVASTAdCategory ()

@property (nonatomic, strong)HyBidXMLElementEx *categoryXmlElement;

@end

@implementation HyBidVASTAdCategory

- (instancetype)initWithCategoryXMLElement:(HyBidXMLElementEx *)categoryXmlElement
{
    self = [super init];
    if (self) {
        self.categoryXmlElement = categoryXmlElement;
    }
    return self;
}

- (NSString *)authority
{
    return [self.categoryXmlElement attribute:@"authority"];
}

- (NSString *)category
{
    return [self.categoryXmlElement value];
}

@end
