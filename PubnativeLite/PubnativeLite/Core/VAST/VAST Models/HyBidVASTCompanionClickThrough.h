// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTCompanionClickThrough : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionClickThroughXMLElement:(HyBidXMLElementEx *)companionClickThroughXMLElement;

/**
 A URI to the advertiser’s page that the media player opens when the viewer clicks the companion ad.
 */
- (NSString *)content;

@end
