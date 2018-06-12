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
#import "PNLiteAd.h"
#import "PNLiteAdRequest.h"

@protocol PNLiteAdViewDelegate<NSObject>

- (void)adViewDidLoad;
- (void)adViewDidFailWithError:(NSError *)error;
- (void)adViewDidTrackImpression;
- (void)adViewDidTrackClick;

@end

@interface PNLiteAdView : UIView <PNLiteAdRequestDelegate>

@property (nonatomic, readonly) PNLiteAdRequest *adRequest;
@property (nonatomic, strong) PNLiteAd *ad;
@property (nonatomic, strong) NSObject <PNLiteAdViewDelegate> *delegate;

- (void)loadWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<PNLiteAdViewDelegate> *)delegate;
- (void)setupAdView:(UIView *)adView;
- (void)renderAd;
- (void)startTracking;
- (void)stopTracking;
- (void)invokeDidLoad;
- (void)invokeDidFailWithError:(NSError *)error;
- (void)invokeDidTrackClick;
- (void)invokeDidTrackImpression;

@end
