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

extern NSString * _Nonnull const VWVideoAdErrorDomain;

typedef enum {
  VWVideoAdErrorUnknown = 0,
  VWVideoAdErrorInventoryUnavailable = 1,
} VWVideoAdError;

@class VWInterstitialVideoAd, VWVideoAdRequest;

@protocol VWInterstitialVideoAdDelegate <NSObject>

@required
- (void)interstitialVideoAdReceiveAd:(nonnull VWInterstitialVideoAd *)interstitialVideoAd;

@optional
- (void)interstitialVideoAd:(nonnull VWInterstitialVideoAd *)interstitialVideoAd didFailToReceiveAdWithError:(nullable NSError *)error;
- (void)interstitialVideoAdWillPresentAd:(nonnull VWInterstitialVideoAd *)interstitialVideoAd;
- (void)interstitialVideoAdWillDismissAd:(nonnull VWInterstitialVideoAd *)interstitialVideoAd;
- (void)interstitialVideoAdDidDismissAd:(nonnull VWInterstitialVideoAd *)interstitialVideoAd;

@end

@interface VWInterstitialVideoAd : NSObject

@property (nonatomic, weak, nullable) id<VWInterstitialVideoAdDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *partnerKeyword;
@property (nonatomic, assign) BOOL allowAutoPlay;
@property (nonatomic, assign) BOOL allowAudioOnStart;

- (void)loadRequestWithZoneID:(NSString *_Nonnull)zoneID andWithRequest:(nonnull VWVideoAdRequest *)request;
- (void)presentFromViewController:(nonnull UIViewController *)viewController;

@end

