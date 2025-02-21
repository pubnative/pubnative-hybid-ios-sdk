//
//  Copyright © 2020 PubNative. All rights reserved.
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
#import "HyBidCustomCTAViewDelegate.h"
#import "HyBidSKOverlay.h"
#import "HyBidSKOverlayDelegate.h"

@class HyBidRewardedPresenter;

@protocol HyBidRewardedPresenterDelegate<NSObject>

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidFinish:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter
             didFailWithError:(NSError *)error;

@optional
- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter viewController:(UIViewController *)viewController;
- (void)rewardedPresenterDidAppear:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidDisappear:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterPresentsSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDismissesSKOverlay:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDismissesCustomCTA:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenteWillPresentEndCard:(HyBidRewardedPresenter *)rewardedPresenter
                         skoverlayDelegate:(id<HyBidSKOverlayDelegate>)skoverlayDelegate
                         customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate;
- (void)rewardedPresenteDidPresentCustomEndCard:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidPresentsCustomCTA;
- (void)rewardedPresenterDidClickCustomCTAOnEndCard:(BOOL)OnEndCard;
- (void)rewardedPresenterDidPresentCustomEndCard:(HyBidRewardedPresenter *)rewardedPresenter;
- (void)rewardedPresenterDidSKOverlayAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter
                                              clickType:(HyBidSKOverlayAutomaticCLickType)clickType;
- (void)rewardedPresenterDidStorekitAutomaticClick:(HyBidRewardedPresenter *)rewardedPresenter
                                              clickType:(HyBidStorekitAutomaticClickType)clickType;

@end

@interface HyBidRewardedPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic) NSObject <HyBidRewardedPresenterDelegate> *delegate;
@property (nonatomic) NSObject <HyBidCustomCTAViewDelegate> *customCTADelegate;
@property (nonatomic) NSObject <HyBidSKOverlayDelegate> *skoverlayDelegate;

- (void)load;

/// Presents the rewarded ad modally from the current view controller.
- (void)show;

/**
 * Presents the rewarded ad modally from the specified view controller.
 *
 * @param viewController The view controller that should be used to present the rewarded ad.
 */
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hideFromViewController:(UIViewController *)viewController;

@end
