// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTMediaFile.h"

@interface HyBidVASTMediaFile ()

@property (nonatomic, strong)HyBidXMLElementEx *mediaFileXmlElement;

@end

@implementation HyBidVASTMediaFile

- (instancetype)initWithMediaFileXMLElement:(HyBidXMLElementEx *)mediaFileXMLElement
{
    self = [super init];
    if (self) {
        self.mediaFileXmlElement = mediaFileXMLElement;
    }
    return self;
}

// MARK: - Attributes

- (NSString *)delivery
{
    return [self.mediaFileXmlElement attribute:@"delivery"];
}

- (NSString *)height
{
    return [self.mediaFileXmlElement attribute:@"height"];
}

- (NSString *)width
{
    return [self.mediaFileXmlElement attribute:@"width"];
}

- (NSString *)type
{
    return [self.mediaFileXmlElement attribute:@"type"];
}

// MARK: - Elements

- (NSString *)url
{
    return [self.mediaFileXmlElement value];
}

@end
