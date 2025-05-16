// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidMRAIDServiceProvider : NSObject

- (void)openBrowser:(NSString *)urlString;
- (void)playVideo:(NSString *)urlString;
- (void)storePicture:(NSString *)urlString;
- (void)sendSMS:(NSString *)urlString;
- (void)callNumber:(NSString *)urlString;

@end
