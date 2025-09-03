// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif
#import <Foundation/Foundation.h>
#import "HyBidAdTrackerRequest.h"
#import "HyBidAd.h"

extern NSString *const PNLiteAdTrackerClick;
extern NSString *const PNLiteAdTrackerImpression;
extern NSString *const PNLiteAdCustomEndCardImpression;
extern NSString *const PNLiteAdCustomEndCardClick;
extern NSString *const PNLiteAdCustomCTAImpression;
extern NSString *const PNLiteAdCustomCTAClick;
extern NSString *const PNLiteAdCustomCTAEndCardClick;

@interface HyBidAdTracker : NSObject

@property (nonatomic, assign) BOOL impressionTracked;

- (instancetype)initWithImpressionURLs:(NSArray *)impressionURLs
       withCustomEndcardImpressionURLs:(NSArray *)customEndcardImpressionURLs
                         withClickURLs:(NSArray *)clickURLs
            withCustomEndcardClickURLs:(NSArray *)customEndcardClickURLs
                 withCustomCTATracking:(HyBidCustomCTATracking *)customCTATracking
                                 forAd:(HyBidAd *)ad;
- (void)trackClickWithAdFormat:(NSString *)adFormat;
- (void)trackImpressionWithAdFormat:(NSString *)adFormat;
- (void)trackCustomEndCardImpressionWithAdFormat:(NSString *)adFormat;
- (void)trackCustomEndCardClickWithAdFormat:(NSString *)adFormat;
- (void)trackCustomCTAImpressionWithAdFormat:(NSString *)adFormat;
- (void)trackCustomCTAClickWithAdFormat:(NSString *)adFormat onEndCard:(BOOL)onEndCard;
- (void)trackSKOverlayAutomaticClickWithAdFormat:(NSString *)adFormat;
- (void)trackSKOverlayAutomaticDefaultEndCardClickWithAdFormat:(NSString *)adFormat;
- (void)trackSKOverlayAutomaticCustomEndCardClickWithAdFormat:(NSString *)adFormat;
- (void)trackStorekitAutomaticClickWithAdFormat:(NSString *)adFormat;
- (void)trackStorekitAutomaticDefaultEndCardClickWithAdFormat:(NSString *)adFormat;
- (void)trackStorekitAutomaticCustomEndCardClickWithAdFormat:(NSString *)adFormat;
- (void)trackReplayClickWithAdFormat:(NSString *)adFormat;

@end
