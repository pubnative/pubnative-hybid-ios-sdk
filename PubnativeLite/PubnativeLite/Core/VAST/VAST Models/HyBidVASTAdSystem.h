// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTAdSystem : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithAdSystemXMLElement:(HyBidXMLElementEx *)adSystemXmlElement;

/**
 A string that provides the version number of the ad system that returned the ad
 */
- (NSString *)version;

/**
 A string that provides the name of the ad server that returned the ad
 */
- (NSString *)system;

@end
