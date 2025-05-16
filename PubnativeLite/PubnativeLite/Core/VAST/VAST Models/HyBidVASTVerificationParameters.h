// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTVerificationParameters : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithVerificationParametersXMLElement:(HyBidXMLElementEx *)verificationParametersXMLElement;

/**
 CDATA-wrapped metadata string for the verification executable.
 */
- (NSString *)content;

@end
