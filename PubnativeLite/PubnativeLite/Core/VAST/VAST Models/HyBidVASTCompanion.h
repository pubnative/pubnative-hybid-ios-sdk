// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTTrackingEvents.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTStaticResource.h"
#import "HyBidVASTAdParameters.h"
#import "HyBidVASTCompanionClickThrough.h"
#import "HyBidVASTCompanionClickTracking.h"
#import "HyBidVASTHTMLResource.h"
#import "HyBidVASTIFrameResource.h"

@interface HyBidVASTCompanion : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionXMLElement:(HyBidXMLElementEx *)companionXMLElement;

- (NSString *)id;

- (NSString *)width;

- (NSString *)height;

- (NSString *)assetWidth;

- (NSString *)assetHeight;

- (NSString *)expandedWidth;

- (NSString *)expandedHeight;

// MARK: - Elements

/**
 A URI to the static creative file to be used for the ad component identified in the parent element.
 */
- (NSArray<HyBidVASTStaticResource *> *)staticResources;

- (HyBidVASTAdParameters *)adParameters;

/**
 A URI to the advertiser’s page that the media player opens when the viewer clicks the companion ad.
 */
- (HyBidVASTCompanionClickThrough *)companionClickThrough;

/**
 A URI to a tracking resource file used to track a companion clickthrough
 */
- (NSArray<HyBidVASTCompanionClickTracking *>  *)companionClickTracking;

/**
 The <TrackingEvents> element is a container for <Tracking> elements used to define specific tracking events
 */
- (HyBidVASTTrackingEvents *)trackingEvents;

/**
 A HTML code snippet (within a CDATA element)
 */
- (NSArray<HyBidVASTHTMLResource *> *)htmlResources;

/**
 A URI to the iframe creative file to be used for the ad component identified in the parent element.
 */
- (NSArray<HyBidVASTIFrameResource *> *)iFrameResources;

@end
