// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTAdType.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTAdInline.h"
#import "HyBidVASTAdWrapper.h"

@interface HyBidVASTAd : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithXMLElement:(HyBidXMLElementEx *)xmlElement;

/**
 An optional string that identifies the type of ad
 */
- (HyBidVASTAdType)adType;

/**
 An ad server-defined identifier string for the ad
 */
- (NSString *)id;

/**
 A integer greater than zero (0) that identifies the sequence in which an ad should
 */
- (NSString *)sequence;

/**
 A Boolean that identifies a conditional ad
 [Deprecated in VAST 4.1, along with apiFramework]
 */
- (BOOL)isConditionalAd;

/**
 Within the nested elements of an <InLine> ad are all the files and URIs necessary to play and track the ad.
 */
- (HyBidVASTAdInline *)inLine;

/**
 VAST Wrappers are used to redirect the media player to another server for either an additional <Wrapper> or the VAST <InLine> ad.
 */
- (HyBidVASTAdWrapper *)wrapper;

@end
