//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
- (void)mraidViewWillExpand:(HyBidMRAIDView *)mraidView;
- (void)mraidViewDidClose:(HyBidMRAIDView *)mraidView;
- (void)mraidViewNavigate:(HyBidMRAIDView *)mraidView withURL:(NSURL *)url;

// This callback is to ask permission to resize an ad.
- (BOOL)mraidViewShouldResize:(HyBidMRAIDView *)mraidView toPosition:(CGRect)position allowOffscreen:(BOOL)allowOffscreen;

@end

@interface HyBidMRAIDView : UIView

@property (nonatomic, strong) id<HyBidMRAIDViewDelegate> delegate;
@property (nonatomic, strong) id<HyBidMRAIDServiceDelegate> serviceDelegate;
@property (nonatomic, weak, setter = setRootViewController:) UIViewController *rootViewController;
// DEPRECATED: isViewable is deprecated as from MRAID 3.0
@property (nonatomic, assign, getter = isViewable, setter = setIsViewable:) BOOL isViewable;

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
    needCloseButton:(BOOL)needCloseButton;

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
@end
