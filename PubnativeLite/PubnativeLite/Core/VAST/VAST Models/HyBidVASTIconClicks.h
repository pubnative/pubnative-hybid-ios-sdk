// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"
#import "HyBidVASTIconClickThrough.h"
#import "HyBidVASTIconClickTracking.h"

@interface HyBidVASTIconClicks : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIconClicksXMLElement:(HyBidXMLElementEx *)iconClicksXMLElement;

/**
 The <IconClickThrough> is used to provide a URI to the industry program page that the media player opens when the icon is clicked.
 */
- (HyBidVASTIconClickThrough *)iconClickThrough;

/**
 <IconClickTracking> is used to track click activity within the icon.
 */
- (NSArray<HyBidVASTIconClickTracking *> *)iconClickTracking;

@end
