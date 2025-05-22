// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"
#import "HyBidVASTTrackingEvents.h"

@interface HyBidVASTCTAButton : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCTAButtonXMLElement:(HyBidXMLElementEx *)ctaButtonXMLElement;

- (NSString *)htmlData;

- (HyBidVASTTrackingEvents *)trackingEvents;

@end
