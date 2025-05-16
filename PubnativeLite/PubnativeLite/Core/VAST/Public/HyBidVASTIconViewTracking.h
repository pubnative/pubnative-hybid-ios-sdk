// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTIconViewTracking : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIconViewTrackingXMLElement:(HyBidXMLElementEx *)iconViewTrackingXMLElement;

/**
 A URI for the tracking resource file to be called when the icon creative is displayed.
 */
- (NSString *)content;

@end
