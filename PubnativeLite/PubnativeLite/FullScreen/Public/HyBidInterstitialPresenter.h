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

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

@class HyBidInterstitialPresenter;

@protocol HyBidInterstitialPresenterDelegate<NSObject>

- (void)interstitialPresenterDidLoad:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidShow:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidClick:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidDismiss:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenter:(HyBidInterstitialPresenter *)interstitialPresenter
             didFailWithError:(NSError *)error;

@optional
- (void)interstitialPresenterDidAppear:(HyBidInterstitialPresenter *)interstitialPresenter;
- (void)interstitialPresenterDidDisappear:(HyBidInterstitialPresenter *)interstitialPresenter;

@end

@interface HyBidInterstitialPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic) NSObject <HyBidInterstitialPresenterDelegate> *delegate;

- (void)load;

/// Presents the interstitial ad modally from the current view controller.
- (void)show;

/**
 * Presents the interstitial ad modally from the specified view controller.
 *
 * @param viewController The view controller that should be used to present the interstitial ad.
 */
- (void)showFromViewController:(UIViewController *)viewController;

- (void)hideFromViewController:(UIViewController *)viewController;

@end
