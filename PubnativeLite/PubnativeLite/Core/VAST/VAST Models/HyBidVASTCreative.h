// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTUniversalAdId.h"
#import "HyBidVASTLinear.h"
#import "HyBidVASTCompanionAds.h"
#import "HyBidXMLElementEx.h"

@interface HyBidVASTCreative : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCreativeXMLElement:(HyBidXMLElementEx *)creativeXMLElement;

/**
 A string used to identify the ad server that provides the creative
 */
- (NSString *)id;

/**
 Used to provide the ad server’s unique identifier for the creative
 */
- (NSString *)adID;

/**
 A number representing the numerical order in which each sequenced creative within an ad should play
 */
- (NSString *)sequence;

/**
 An array of strings identifying the unique creative identifier. Default value is “unknown”
 */
- (NSArray<HyBidVASTUniversalAdId *> *)universalAdIds;

/**
 Linear Ads are the video or audio formatted ads that play linearly within the streaming content
 */
- (HyBidVASTLinear *)linear;

- (HyBidVASTCompanionAds *)companionAds;

@end
