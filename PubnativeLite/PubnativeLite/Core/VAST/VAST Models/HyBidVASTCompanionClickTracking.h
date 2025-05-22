// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTCompanionClickTracking : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionClickTrackingXMLElement:(HyBidXMLElementEx *)companionClickTrackingXMLElement;

/**
 A URI to a tracking resource file used to track a companion clickthrough
 */
- (NSString *)content;

@end

