// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@protocol HyBidInternalWebBrowserDelegate <NSObject>
@optional
- (void)internalWebBrowserWillShow;
- (void)internalWebBrowserDidShow;
- (void)internalWebBrowserWillDismiss;
- (void)internalWebBrowserDidDismiss;
- (void)internalWebBrowserDidFail;

@end
