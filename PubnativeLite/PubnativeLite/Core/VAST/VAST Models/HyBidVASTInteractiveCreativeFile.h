// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTInteractiveCreativeFile : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithInteractiveCreativeFileXMLElement:(HyBidXMLElementEx *)interactiveCreativeFileXMLElement;

/**
 Identifies the MIME type of the file provided.
 */
- (NSString *)type;

/**
 Useful for interactive use cases. Identifies whether the ad always drops when the duration is reached, or if it can potentially extend the duration by pausing the underlying video or delaying the adStopped call after adVideoComplete.
 */
- (NSString *)variableDuration;

/**
 A CDATA-wrapped URI to a file providing creative functions for the media file.
 */
- (NSString *)url;

@end
