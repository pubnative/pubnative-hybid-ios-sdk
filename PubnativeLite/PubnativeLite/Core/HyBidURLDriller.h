// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@protocol HyBidURLDrillerDelegate <NSObject>

@optional
- (void)didStartWithURL:(NSURL *)url;
- (void)didRedirectWithURL:(NSURL *)url;
- (void)didFinishWithURL:(NSURL *)url trackingType:(NSString *)trackingType;
- (void)didFailWithURL:(NSURL *)url andError:(NSError *)error;

@end

@interface HyBidURLDriller : NSObject

- (void)startDrillWithURLString:(NSString *)urlString
                       delegate:(NSObject<HyBidURLDrillerDelegate> *)delegate;
- (void)startDrillWithURLString:(NSString *)urlString
                       delegate:(NSObject<HyBidURLDrillerDelegate> *)delegate
               withTrackingType:(NSString *)trackingType;

@end

