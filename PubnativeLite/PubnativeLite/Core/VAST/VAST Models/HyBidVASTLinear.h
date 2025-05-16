// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTAdParameters.h"
#import "HyBidVASTInteractiveCreativeFile.h"
#import "HyBidVASTIcon.h"
#import "HyBidVASTTrackingEvents.h"
#import "HyBidVASTMediaFiles.h"
#import "HyBidVASTVideoClicks.h"
#import "HyBidXMLElementEx.h"

@interface HyBidVASTLinear : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithInLineXMLElement:(HyBidXMLElementEx *)inLineXMLElement;

/**
 Time value that identifies when skip controls are made available to the end user.
 */
- (NSString *)skipOffset;

/**
 A time value for the duration of the Linear ad in the format HH:MM:SS.mmm (.mmm is optional and indicates milliseconds).
 */
- (NSString *)duration;

/**
 Metadata for the ad.
 */
- (HyBidVASTAdParameters *)adParameters;

/**
 The <VideoClicks> element provides URIs for clickthroughs, clicktracking, and custom clicks and is available for Linear Ads in both the InLine and Wrapper formats. 
 */
- (HyBidVASTVideoClicks *)videoClicks;

/**
 The <VideoClicks> element provides URIs for clickthroughs, clicktracking, and custom clicks and is available for Linear Ads in both the InLine and Wrapper formats.
 */
- (NSArray<HyBidVASTIcon *> *)icons;

- (HyBidVASTMediaFiles *)mediaFiles;

- (HyBidVASTTrackingEvents *)trackingEvents;

@end
