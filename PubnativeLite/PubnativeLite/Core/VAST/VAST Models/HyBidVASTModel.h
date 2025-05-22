// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTAd.h"

typedef NSArray<NSString *> * HyBidVASTErrorTagURLs;
@interface HyBidVASTModel : NSObject

- (instancetype)initWithData:(NSData *)data;

/**
 A string that identifies the version of VAST.
 */
- (NSString *)version;

/**
 An array of ads.
 */
- (NSArray<HyBidVASTAd *> *)ads;

/**
 An array of errors.
 */
- (HyBidVASTErrorTagURLs)errors;

- (NSString *)vastString;

- (NSMutableArray<NSData *> *)vastArray;

@end
