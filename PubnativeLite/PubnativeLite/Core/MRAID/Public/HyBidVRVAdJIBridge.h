//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidVRVAdJIBridge : NSObject

+ (void)injectIntoController:(WKUserContentController *)controller;

@end

NS_ASSUME_NONNULL_END
