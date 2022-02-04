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

@protocol HyBidInterstitialAdDelegate<NSObject>

- (void)interstitialDidLoad;
- (void)interstitialDidFailWithError:(NSError *)error;
- (void)interstitialDidTrackImpression;
- (void)interstitialDidTrackClick;
- (void)interstitialDidDismiss;

@end

@interface HyBidInterstitialAd : NSObject

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isMediation;
@property (nonatomic, assign) BOOL isAutoCacheOnLoad;

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate;
- (instancetype)initWithDelegate:(NSObject<HyBidInterstitialAdDelegate> *)delegate;
- (void)load;
- (void)prepareAdWithContent:(NSString *)adContent;
- (void)prepareVideoTagFrom:(NSString *)url;
- (void)prepareCustomMarkupFrom:(NSString *)markup;
- (void)prepare;

/// Presents the interstitial ad modally from the current view controller.
///
/// This method will do nothing if the interstitial ad has not been loaded (i.e. the value of its `isReady` property is NO).
- (void)show;

/**
* Presents the interstitial ad modally from the specified view controller.
*
* This method will do nothing if the interstitial ad has not been loaded (i.e. the value of its
* `isReady` property is NO).
*
* @param viewController The view controller that should be used to present the interstitial ad.
*/
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hide;

- (void)setSkipOffset:(NSInteger)seconds DEPRECATED_MSG_ATTRIBUTE("Use either setVideoSkipOffset: or setHTMLSkipOffset: based on your ad format instead.");
- (void)setVideoSkipOffset:(NSInteger)seconds;
- (void)setHTMLSkipOffset:(NSInteger)seconds;
- (void)setCloseOnFinish:(BOOL)closeOnFinish;

@end
