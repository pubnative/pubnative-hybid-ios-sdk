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

#import "AppMonet.h"
#import "MPAdView.h"
#import "HyBidAdRequest.h"

@class MPNativeAdRequest;

@interface AppMonet (MoPub) <HyBidAdRequestDelegate>

/**
 * This method allows you to attach bids to {@code MPAdView} instance.
 * Bids will only get attached if they associated with the view's ad unit id, If no bids are locally cached it will try
 * to get some within the timeout period provided. If no bids return you will not have anything attached on {@code MPAdView}.
 * <p/>
 *
 * @param adView The {@code MPAdView} you are trying to load an ad on.
 * @param timeout  The wait time in milliseconds for a bid response.
 * @param onReadyBlock The block notifying that addBids completed.
 */
+ (void)addBids:(MPAdView *)adView andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock;

/**
 * This method allows you to get back a modified {@code MPAdView} instance that has bids attached to it.
 * Bids will only get attached if they associated with the view's ad unit id, and are locally cached. IF bids are not
 * cached, nothing will be attached to {@code MPAdView}.
 * @param adView  {@code MPAdView} to attach bid to.
 * @return {@code MPAdView} with bids attached.
 */
//+ (MPAdView *)addBids:(MPAdView *)adView;

+ (void)addNativeBids:(MPNativeAdRequest *)adRequest andAdUnitId:(NSString *)adUnitId andTimeout:(NSNumber *)timeout :(void (^)(void))onReadyBlock;
+ (void)enableVerboseLogging:(BOOL)verboseLogging;

@end
