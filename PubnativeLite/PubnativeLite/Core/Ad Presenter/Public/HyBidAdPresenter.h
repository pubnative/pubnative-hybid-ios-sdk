// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"
#import "HyBidAdSize.h"

@class HyBidAdPresenter;
@class HyBidAdSessionData;

@protocol HyBidAdPresenterDelegate<NSObject>

- (void)adPresenter:(HyBidAdPresenter *)adPresenter
      didLoadWithAd:(UIView *)adView;
- (void)adPresenterDidClick:(HyBidAdPresenter *)adPresenter;
- (void)adPresenter:(HyBidAdPresenter *)adPresenter
       didFailWithError:(NSError *)error;

@optional
- (void)adPresenterDidStartPlaying:(HyBidAdPresenter *)adPresenter;
- (void)adPresenterDidAppear:(HyBidAdPresenter *)adPresenter;
- (void)adPresenterDidDisappear:(HyBidAdPresenter *)adPresenter;
- (void)adPresenterDidPresentCustomEndCard:(HyBidAdPresenter *)adPresenter;
- (void)adPresenterDidReplay;

@end

@interface HyBidAdPresenter : NSObject

@property (nonatomic, readonly) HyBidAd *ad;
@property (nonatomic, weak) NSObject <HyBidAdPresenterDelegate> *delegate;
@property (nonatomic, strong) HyBidAdSessionData *adSessionData;

- (void)load;
- (void)loadMarkupWithSize:(HyBidAdSize *)adSize;
- (void)startTracking;
- (void)stopTracking;

@end
