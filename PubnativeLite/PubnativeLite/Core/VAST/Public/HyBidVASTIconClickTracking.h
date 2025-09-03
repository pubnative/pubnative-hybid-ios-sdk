// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTIconClickTracking : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIconClickTrackingXMLElement:(HyBidXMLElementEx *)iconClickTrackingXMLElement;

/**
 An id for the click to be measured.
 */
- (NSString *)id;

/**
 A URI to the tracking resource file to be called when a click corresponding to the id attribute (if provided) occurs.
 */
- (NSString *)content;

@end
