//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidEndCardView.h"

@interface HyBidEndCardView ()

- (instancetype)initWithDelegate:(NSObject<HyBidEndCardViewDelegate> *)delegate
              withViewController:(UIViewController *)viewController
                          withAd:(HyBidAd *)ad
                      withVASTAd:(HyBidVASTAd *)vastAd
                  isInterstitial:(BOOL)isInterstitial
                   iconXposition:(NSString *)iconXposition
                   iconYposition:(NSString *)iconYposition
                  withSkipButton:(BOOL)withSkipButton
     vastCompanionsClicksThrough:(NSArray<NSString *> *)vastCompanionsClicksThrough
    vastCompanionsClicksTracking:(NSArray<NSString *> *)vastCompanionsClicksTracking
         vastVideoClicksTracking:(NSArray<NSString *> *)vastVideoClicksTracking
          hasTrackedEndCardClick:(BOOL)hasTrackedEndCardClick
            hasTrackedVideoClick:(BOOL)hasTrackedVideoClick
            hasTrackedCompanionClickEvent:(BOOL)hasTrackedCompanionClickEvent
        hasTrackedCompanionClick:(BOOL)hasTrackedCompanionClick;

- (BOOL)hasTrackedEndCardClick;
- (BOOL)hasTrackedVideoClick;
- (BOOL)hasTrackedCompanionClickEvent;
- (BOOL)hasTrackedCompanionClick;
- (HyBidEndCard *)endCard;

@end
