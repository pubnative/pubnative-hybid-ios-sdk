// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTImpression : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithImpressionXMLElement:(HyBidXMLElementEx *)impressionXMLElement;

/**
 An ad server id for the impression
 */
- (NSString *)id;

/**
 Impression URI.
 */
- (NSString *)url;

@end
