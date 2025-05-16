// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidXMLElementEx.h"

@interface HyBidVASTMediaFile : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMediaFileXMLElement:(HyBidXMLElementEx *)mediaFileXMLElement;

/**
 Either “progressive” for progressive download protocols (such as HTTP) or “streaming” for streaming protocols.
 */
- (NSString *)delivery;

/**
 MIME type for the file container. Popular MIME types include, but are not limited to “video/mp4” for MP4, “audio/mpeg” and "audio/aac" for audio ads.
 */
- (NSString *)type;

/**
 The native width of the video file, in pixels. (0 for audio ads)
 */
- (NSString *)width;

/**
 The native height of the video file, in pixels. (0 for audio ads)
 */
- (NSString *)height;

- (NSString *)url;

@end
