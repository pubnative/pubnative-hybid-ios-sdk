// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTError : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithErrorXMLElement:(HyBidXMLElementEx *)errorXMLElement;

/**
 A URI to a tracking resource to be used when an error in ad playback occurs.
 */
- (NSString *)content;


@end

