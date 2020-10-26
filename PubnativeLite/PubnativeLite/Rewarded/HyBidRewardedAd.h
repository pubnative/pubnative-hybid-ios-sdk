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
#import "HyBidSignalDataProcessor.h"

@protocol HyBidRewardedAdDelegate<NSObject>

- (void)rewardedDidLoad;
- (void)rewardedDidFailWithError:(NSError *)error;
- (void)rewardedDidTrackImpression;
- (void)rewardedDidTrackClick;
- (void)rewardedDidDismiss;
- (void)onReward;

@end

@interface HyBidRewardedAd: NSObject <HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isMediation;

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate;
- (instancetype)initWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate;
- (void)load;
- (void)prepareAdWithContent:(NSString *)adContent;

/**
 Presents the rewarded ad modally from the current view controller.
 This method will do nothing if the rewarded ad has not been loaded (i.e. the value of its `isReady` property is NO).
 */
- (void)show;

/**
* Presents the rewarded ad modally from the specified view controller.
*
* This method will do nothing if the rewarded ad has not been loaded (i.e. the value of its
* `isReady` property is NO).
*
* @param viewController The view controller that should be used to present the rewarded ad.
*/
- (void)showFromViewController:(UIViewController *)viewController;
- (void)hide;

@end
