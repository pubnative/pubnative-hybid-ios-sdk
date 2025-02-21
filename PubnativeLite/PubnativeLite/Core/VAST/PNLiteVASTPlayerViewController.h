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
#import "HyBidVASTEndCard.h"
#import "HyBidCustomCTAViewDelegate.h"
#import "HyBidSKOverlayDelegate.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@class PNLiteVASTPlayerViewController;

typedef enum {
    HyBidAdFormatBanner,
    HyBidAdFormatInterstitial,
    HyBidAdFormatRewarded
} HyBidAdFormatForVASTPlayer;

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
- (void)vastPlayerDidCloseOffer:(PNLiteVASTPlayerViewController*)vastPlayer;
- (void)vastPlayerWillShowEndCard:(PNLiteVASTPlayerViewController*)vastPlayer
                  isCustomEndCard:(BOOL)isCustomEndCard
                skoverlayDelegate:(id<HyBidSKOverlayDelegate>)skoverlayDelegate
                customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate;
- (void)vastPlayerDidShowEndCard:(PNLiteVASTPlayerViewController*)vastPlayer endcard:(HyBidVASTEndCard*) endcard;
- (void)vastPlayerDidShowSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType;
- (void)vastPlayerDidShowStorekitWithClickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)vastPlayerDidShowAutoStorekit;
- (void)vastPlayerDidClickCustomCTAOnEndCard:(BOOL)onEndCard;
- (void)vastPlayerDidShowCustomCTA;

@end

@interface PNLiteVASTPlayerViewController : UIViewController

@property (nonatomic, assign) NSTimeInterval loadTimeout;
@property (nonatomic, assign) BOOL canResize;
@property (nonatomic, assign) BOOL closeOnFinish;
@property (nonatomic, strong) NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;
@property (nonatomic, strong) HyBidSkipOffset *skipOffset;
@property (nonatomic, weak) NSObject<HyBidCustomCTAViewDelegate> *customCTADelegate;
@property (nonatomic, weak) NSObject<HyBidSKOverlayDelegate> *skoverlayDelegate;

- (instancetype)initPlayerWithAdModel:(HyBidAd *)adModel
                         withAdFormat:(HyBidAdFormatForVASTPlayer)adFormat;
- (void)loadWithVastUrl:(NSURL*)url;
- (void)loadWithVastString:(NSString*)vast;
- (void)loadWithVideoAdCacheItem:(HyBidVideoAdCacheItem*)videoAdCacheItem;
- (void)play;
- (void)pause;
- (void)stop;

@end
