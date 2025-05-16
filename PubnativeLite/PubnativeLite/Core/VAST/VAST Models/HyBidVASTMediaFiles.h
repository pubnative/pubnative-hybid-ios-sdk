// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTMediaFile.h"
#import "HyBidVASTInteractiveCreativeFile.h"
#import "HyBidXMLElementEx.h"

@interface HyBidVASTMediaFiles : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMediaFilesXMLElement:(HyBidXMLElementEx *)mediaFilesXMLElement;

/**
 An array of a CDATA-wrapped URI to a media files.
 */
- (NSArray<HyBidVASTMediaFile *> *)mediaFiles;

/**
 An array of a CDATA-wrapped URI to a file providing creative functions for the media file.
 */
- (NSArray<HyBidVASTInteractiveCreativeFile *> *)interactiveCreativeFiles;

@end
