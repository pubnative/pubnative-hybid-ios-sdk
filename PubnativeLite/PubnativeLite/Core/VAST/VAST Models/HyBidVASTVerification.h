// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTJavaScriptResource.h"
#import "HyBidVASTExecutableResource.h"
#import "HyBidVASTTrackingEvents.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTVerificationParameters.h"

@interface HyBidVASTVerification : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithVerificationXMLElement:(HyBidXMLElementEx *)verificationXMLElement;

/**
 An identifier for the verification vendor. The recommended format is [domain]- [useCase], to avoid name collisions.
 For example, "company.com-omid".
 */
- (NSString *)vendor;

- (NSArray<HyBidVASTJavaScriptResource *> *)javaScriptResource;

- (NSArray<HyBidVASTExecutableResource *> *)executableResource;

- (HyBidVASTTrackingEvents *)trackingEvents;

- (HyBidVASTVerificationParameters *)verificationParameters;

@end
