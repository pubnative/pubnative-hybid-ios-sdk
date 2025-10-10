// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidContentInfoView.h"
#import "HyBidAd.h"

@class HyBidMRAIDView;
@protocol HyBidMRAIDServiceDelegate;

// A delegate for MRAIDView to listen for notification on ad ready or expand related events.
@protocol HyBidMRAIDViewDelegate <NSObject>

@optional

// These callbacks are for basic banner ad functionality.
- (void)mraidViewAdReady:(HyBidMRAIDView *)mraidView;
- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView;
- (void)mraidViewAdFailed:(HyBidMRAIDView *)mraidView withError:(NSError *)error;
- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView;
- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView;
- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url;
- (void)mraidViewWillShowEndCard:(HyBidMRAIDView *)mraidView
                 isCustomEndCard:(BOOL)isCustomEndCard
               skOverlayDelegate:(id<HyBidSKOverlayDelegate>)skOverlayDelegate;
- (void)mraidViewDidPresentCustomEndCard:(HyBidMRAIDView *)mraidView;
- (void)mraidViewAutoStoreKitDidShowWithClickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)mraidViewDidShowSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType;

// This callback is to ask permission to resize an ad.
- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen;

@end

@interface HyBidMRAIDView : UIView <HyBidSKOverlayDelegate>

@property (nonatomic, strong) id<HyBidMRAIDViewDelegate> delegate;
@property (nonatomic, strong) id<HyBidMRAIDServiceDelegate> serviceDelegate;
@property (nonatomic, weak, setter = setRootViewController:) UIViewController *rootViewController;
// DEPRECATED: isViewable is deprecated as from MRAID 3.0
@property (nonatomic, assign, getter = isViewable, setter = setIsViewable:) BOOL isViewable;
@property (nonatomic, strong) NSString *urlStringForEndCardTracking;

// IMPORTANT: This is the only valid initializer for an MRAIDView; -init and -initWithFrame: will throw exceptions
- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString *)htmlData
        withBaseURL:(NSURL *)bsURL
             withAd:(HyBidAd *)ad
  supportedFeatures:(NSArray *)features
      isInterstital:(BOOL)isInterstitial
       isScrollable:(BOOL)isScrollable
           delegate:(id<HyBidMRAIDViewDelegate>)delegate
    serviceDelegate:(id<HyBidMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController
        contentInfo:(HyBidContentInfoView *)contentInfo
         skipOffset:(NSInteger)skipOffset
          isEndcard:(BOOL)isEndcard
shouldHandleInterruptions:(BOOL)shouldHandleInterruptions;

- (void)cancel;

/// Helper method that presents the interstitial ad modally from the current view controller.
- (void)showAsInterstitial;

/**
* Helper method that presents the interstitial ad modally from the specified view controller.
*
* @param viewController The view controller that should be used to present the interstitial ad.
*/
- (void)showAsInterstitialFromViewController:(UIViewController *)viewController;
- (void)hide;
- (void)stopAdSession;
- (void)startAdSession;
// These methods provide the means for native code to talk to JavaScript code.
- (void)injectJavaScript:(NSString *)js;
- (nullable UIView *)modalView;
@end
