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
#import <AVFoundation/AVFoundation.h>
#import "HyBidContentInfoView.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidAd.h"

@class PNLiteVASTPlayerViewController;

@protocol PNLiteVASTPlayerViewControllerDelegate <NSObject>

@required
- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController*)vastPlayer;
- (void)vastPlayer:(PNLiteVASTPlayerViewController*)vastPlayer didFailLoadingWithError:(NSError*)error;
- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController*)vastPlayer;
- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController*)vastPlayer;
- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController*)vastPlayer;
- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController*)vastPlayer;
@optional
- (void)vastPlayerDidClose:(PNLiteVASTPlayerViewController*)vastPlayer;

@end

@interface PNLiteVASTPlayerViewController : UIViewController

@property (nonatomic, assign) NSTimeInterval loadTimeout;
@property (nonatomic, assign) BOOL canResize;
@property (nonatomic, strong) NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;
@property (nonatomic, assign) NSInteger skipOffset;
@property (nonatomic, assign) BOOL isRewarded;

- (instancetype)initPlayerWithAdModel:(HyBidAd *)adModel
                            isInterstital:(BOOL)isInterstitial;
- (void)loadWithVastUrl:(NSURL*)url;
- (void)loadWithVastString:(NSString*)vast;
- (void)loadWithVideoAdCacheItem:(HyBidVideoAdCacheItem*)videoAdCacheItem;
- (void)play;
- (void)pause;
- (void)stop;

@end
