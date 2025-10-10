// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HyBidContentInfoView.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidAd.h"
#import "HyBidEndCard.h"
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
                skOverlayDelegate:(id<HyBidSKOverlayDelegate>)skOverlayDelegate
                customCTADelegate:(id<HyBidCustomCTAViewDelegate>)customCTADelegate;
- (void)vastPlayerDidShowEndCard:(PNLiteVASTPlayerViewController*)vastPlayer endcard:(HyBidEndCard*) endcard;
- (void)vastPlayerDidShowSKOverlayWithClickType:(HyBidSKOverlayAutomaticCLickType)clickType;
- (void)vastPlayerDidShowStorekitWithClickType:(HyBidStorekitAutomaticClickType)clickType;
- (void)vastPlayerDidShowAutoStorekit;
- (void)vastPlayerDidClickCustomCTAOnEndCard:(BOOL)onEndCard;
- (void)vastPlayerDidShowCustomCTA;
- (void)vastPlayerDidReplay;

@end

@interface PNLiteVASTPlayerViewController : UIViewController

@property (nonatomic, assign) NSTimeInterval loadTimeout;
@property (nonatomic, assign) BOOL canResize;
@property (nonatomic, assign) BOOL closeOnFinish;
@property (nonatomic, strong) NSObject<PNLiteVASTPlayerViewControllerDelegate> *delegate;
@property (nonatomic, strong) HyBidVideoAdCacheItem *videoAdCacheItem;
@property (nonatomic, strong) HyBidSkipOffset *skipOffset;
@property (nonatomic, weak) NSObject<HyBidCustomCTAViewDelegate> *customCTADelegate;
@property (nonatomic, weak) NSObject<HyBidSKOverlayDelegate> *skOverlayDelegate;

- (instancetype)initPlayerWithAdModel:(HyBidAd *)adModel
                         withAdFormat:(HyBidAdFormatForVASTPlayer)adFormat;
- (void)loadWithVastUrl:(NSURL*)url;
- (void)loadWithVastString:(NSString*)vast;
- (void)loadWithVideoAdCacheItem:(HyBidVideoAdCacheItem*)videoAdCacheItem;
- (void)play;
- (void)pause;
- (void)stop;

@end
