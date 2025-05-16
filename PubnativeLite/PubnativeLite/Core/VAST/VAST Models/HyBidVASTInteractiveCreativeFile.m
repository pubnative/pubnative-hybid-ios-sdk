// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTInteractiveCreativeFile.h"

@interface HyBidVASTInteractiveCreativeFile ()

@property (nonatomic, strong)HyBidXMLElementEx *interactiveCreativeFileXMLElement;

@end

@implementation HyBidVASTInteractiveCreativeFile

- (instancetype)initWithInteractiveCreativeFileXMLElement:(HyBidXMLElementEx *)interactiveCreativeFileXMLElement
{
    self = [super init];
    if (self) {
        self.interactiveCreativeFileXMLElement = interactiveCreativeFileXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)type
{
    return [self.interactiveCreativeFileXMLElement attribute:@"type"];
}

- (NSString *)variableDuration
{
    return [self.interactiveCreativeFileXMLElement attribute:@"variableDuration"];
}

// MARK: - Elements

- (NSString *)url
{
    return [self.interactiveCreativeFileXMLElement value];
}

@end
