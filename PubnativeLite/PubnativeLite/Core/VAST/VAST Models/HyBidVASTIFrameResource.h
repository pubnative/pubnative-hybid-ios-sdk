// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTIFrameResource : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIFrameResourceXMLElement:(HyBidXMLElementEx *)iFrameResourceXMLElement;

/**
 A URI to the iframe creative file to be used for the ad component identified in the parent element.
 */
- (NSString *)content;

@end
