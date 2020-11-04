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

@class AMInterstitialAdController;

/**
 * The delegate of an `AMInterstitialAdController` object must adopt the
 * `AMInterstitialAdControllerDelegate` protocol.
 */

@protocol AMInterstitialAdControllerDelegate <NSObject>

@optional

/** @name Detecting When an Interstitial Ad is Loaded */

/**
 * Sent when an interstitial ad object successfully loads an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidLoadAd:(AMInterstitialAdController *)interstitial;

/**
 * Sent when an interstitial ad object fails to load an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidFailToLoadAd:(AMInterstitialAdController *)interstitial;

/**
 * Sent when an interstitial ad object fails to load an ad.
 *
 * @param interstitial The interstitial ad object sending the message.
 * @param error The error that occurred during the load.
 */
- (void)interstitialDidFailToLoadAd:(AMInterstitialAdController *)interstitial
                          withError:(NSError *)error;

/** @name Detecting When an Interstitial Ad is Presented */

/**
 * Sent immediately before an interstitial ad object is presented on the screen.
 *
 * Your implementation of this method should pause any application activity that requires user
 * interaction.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillAppear:(AMInterstitialAdController *)interstitial;

/**
 * Sent after an interstitial ad object has been presented on the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidAppear:(AMInterstitialAdController *)interstitial;

/** @name Detecting When an Interstitial Ad is Dismissed */

/**
 * Sent immediately before an interstitial ad object will be dismissed from the screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialWillDisappear:(AMInterstitialAdController *)interstitial;

/**
 * Sent after an interstitial ad object has been dismissed from the screen, returning control
 * to your application.
 *
 * Your implementation of this method should resume any application activity that was paused
 * prior to the interstitial being presented on-screen.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidDisappear:(AMInterstitialAdController *)interstitial;

/**
 * Sent when the user taps the interstitial ad and the ad is about to perform its target action.
 *
 * @param interstitial The interstitial ad object sending the message.
 */
- (void)interstitialDidReceiveTapEvent:(AMInterstitialAdController *)interstitial;

@end

