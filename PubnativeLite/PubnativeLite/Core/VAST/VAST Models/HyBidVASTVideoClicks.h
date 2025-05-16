// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"
#import "HyBidVASTClickThrough.h"
#import "HyBidVASTClickTracking.h"
#import "HyBidVASTCustomClick.h"

@interface HyBidVASTVideoClicks : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithVideoClicksXMLElement:(HyBidXMLElementEx *)videoClicksXMLElement;


- (NSArray<HyBidVASTClickTracking *> *)clickTrackings;

- (HyBidVASTClickThrough *)clickThrough;

- (NSArray<HyBidVASTCustomClick *> *)customClicks;

@end
