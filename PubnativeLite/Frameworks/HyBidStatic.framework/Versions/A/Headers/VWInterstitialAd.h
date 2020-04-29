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

typedef enum : NSUInteger {
  VWInterstitialAdSizePhone,
  VWInterstitialAdSizePad
} VWInterstitialAdSize;

@class VWInterstitialAd, VWAdRequest;

@protocol VWInterstitialAdDelegate <NSObject>

@required
- (void)interstitialAdReceiveAd:(nonnull VWInterstitialAd *)interstitialAd;

@optional
- (void)interstitialAd:(nonnull VWInterstitialAd *)interstitialAd didFailToReceiveAdWithError:(nullable NSError *)error;
- (void)interstitialAdWillPresentAd:(nonnull VWInterstitialAd *)interstitialAd;
- (void)interstitialAdWillDismissAd:(nonnull VWInterstitialAd *)interstitialAd;
- (void)interstitialAdDidDismissAd:(nonnull VWInterstitialAd *)interstitialAd;
- (void)interstitialAdWillLeaveApplication:(nonnull VWInterstitialAd *)interstitialAd;

@end

@interface VWInterstitialAd : NSObject

@property (nonatomic, weak, nullable) id<VWInterstitialAdDelegate> delegate;
@property(nonatomic, readonly, assign) BOOL isReady;
@property(nonatomic, readonly, assign) BOOL hasBeenUsed;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithSize:(VWInterstitialAdSize)size;
- (void)loadRequestWithZoneID:(NSString *_Nonnull)zoneID andWithRequest:(nonnull VWAdRequest *)request;
- (void)presentFromViewController:(nonnull UIViewController *)viewController;

@end


