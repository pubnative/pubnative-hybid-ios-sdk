// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidMRAIDServiceProvider : NSObject

- (void)openBrowser:(NSString *)urlString;
- (void)playVideo:(NSString *)urlString;
- (void)storePicture:(NSString *)urlString __attribute__((deprecated("mraid.storePicture is not supported; this method does nothing.")));
- (void)sendSMS:(NSString *)urlString;
- (void)callNumber:(NSString *)urlString;

@end
