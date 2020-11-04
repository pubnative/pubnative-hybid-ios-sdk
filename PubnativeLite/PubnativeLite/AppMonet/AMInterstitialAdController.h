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
#import <UIKit/UIKit.h>
#import "AMInterstitialAdControllerDelegate.h"
#import "HyBidInterstitialAd.h"

@class AMMonetBid;

@interface AMInterstitialAdController : NSObject

/**
 * Returns an interstitial ad object matching the given ad unit ID.
 *
 * @param adUnitId A string representing an AppMonet ad unit ID.
 */
+ (AMInterstitialAdController *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId;

@property(nonatomic, weak) id <AMInterstitialAdControllerDelegate> delegate;


/**
 * The AppMonet ad unit ID for this interstitial ad.
 */
@property(nonatomic, copy) NSString *adUnitId;

/**
 * Begins loading ad content for the interstitial.
 */
- (void)loadAd;

/**
 * Begins loading ad content with a particular AMMonetBid bid for the interstitial.
 * @param bid Bid to be loaded
 */
- (void)loadAd:(AMMonetBid *)bid;

/**
 * Requests an ad to be rendered.
 */
- (void)requestAds:(void (^)(AMMonetBid *bid))handler;

/**
 * Renders passed bid.
 */
-(void)renderAd:(AMMonetBid *)bid;


/**
 * A Boolean value that represents whether the interstitial ad has loaded an advertisement and is
 * ready to be presented.
 */
@property(nonatomic, assign, readonly) BOOL ready;

/**
 * Retrieves a loaded interstitial view content
 * @return  UIView
 */
- (UIView *)getInterstitialView;

/**
 * Presents the interstitial ad from the specified view controller.
 */
- (void)showFromViewController:(UIViewController *)controller;

@end
