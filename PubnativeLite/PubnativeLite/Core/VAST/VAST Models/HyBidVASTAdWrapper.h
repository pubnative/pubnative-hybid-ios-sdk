// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"
#import "HyBidVASTAdSystem.h"
#import "HyBidVASTImpression.h"
#import "HyBidVASTAdCategory.h"
#import "HyBidVASTVerification.h"
#import "HyBidVASTCreative.h"
#import "HyBidVASTError.h"
#import "HyBidVASTCTAButton.h"

@interface HyBidVASTAdWrapper : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithWrapperXMLElement:(HyBidXMLElementEx *)wrapperXmlElement;

/**
 A descriptive name for the system that serves the ad
 */
- (HyBidVASTAdSystem *)adSystem;

/**
 A string that provides a common name for the ad
 */
- (NSString *)adTitle;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTImpression *> *)impressions;

/**
 A unique or pseudo-unique (long enough to be unique when combined with timestamp data) GUID
 */
- (NSString *)adServingID;

/**
 A string that provides a category code or label that identifies the ad content category.
 */
- (NSArray<HyBidVASTAdCategory *> *)categories;

/**
 A string that provides a long ad description
 */
- (NSString *)description;

/**
 A string that provides the name of the advertiser as defined by the ad serving party
 */
- (NSString *)advertiser;

/**
 The <Error> element contains a URI that the player uses to notify the ad server when errors occur with ad playback.
 */
- (NSArray<HyBidVASTError *> *)errors;

/**
 List of the resources and metadata required to execute third-party measurement code in order to verify creative playback
 */
- (NSArray<HyBidVASTVerification *> *)adVerifications;

/**
 An array of URI that directs the media player to a tracking resource file that the media player must use to notify the ad server when the impression occurs.
 */
- (NSArray<HyBidVASTCreative *> *)creatives;

- (HyBidVASTCTAButton *)ctaButton;

@end
