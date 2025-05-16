// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTVerificationParameters.h"

@interface HyBidVASTVerificationParameters ()

@property (nonatomic, strong)HyBidXMLElementEx *verificationParametersXMLElement;

@end

@implementation HyBidVASTVerificationParameters

- (instancetype)initWithVerificationParametersXMLElement:(HyBidXMLElementEx *)verificationParametersXMLElement
{
    if (self) {
        self.verificationParametersXMLElement = verificationParametersXMLElement;
    }
    return self;
}

- (NSString *)content
{
    return [self.verificationParametersXMLElement value];
}

@end
