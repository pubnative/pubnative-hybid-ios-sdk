// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTExecutableResource.h"

@interface HyBidVASTExecutableResource ()

@property (nonatomic, strong)HyBidXMLElementEx *executableResourceXMLElement;

@end

@implementation HyBidVASTExecutableResource

- (instancetype)initWithExecutableResourceXMLElement:(HyBidXMLElementEx *)executableResourceXMLElement
{
    if (self) {
        self.executableResourceXMLElement = executableResourceXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)language
{
    return [self.executableResourceXMLElement attribute:@"language"];
}

- (NSString *)apiFramework
{
    return [self.executableResourceXMLElement attribute:@"apiFramework"];
}

// MARK: - Elements

- (NSString *)url
{
    return [self.executableResourceXMLElement value];
}

@end
