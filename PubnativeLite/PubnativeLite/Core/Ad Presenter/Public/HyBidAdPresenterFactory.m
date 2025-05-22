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
#import "HyBidAdPresenterFactory.h"
#import "PNLiteAdPresenterDecorator.h"
#import "HyBidAdTracker.h"

@implementation HyBidAdPresenterFactory

- (HyBidAdPresenter *)createAdPresenterWithAd:(HyBidAd *)ad withDelegate:(NSObject<HyBidAdPresenterDelegate> *)delegate {
    HyBidAdPresenter *adPresenter = [self adPresenterFromAd:ad];
    if (!adPresenter) {
        return nil;
    }
    NSArray *impressionBeacons = [ad beaconsDataWithType:PNLiteAdTrackerImpression];
    NSArray *clickBeacons = [ad beaconsDataWithType:PNLiteAdTrackerClick];
    
    NSArray *customEndcardImpressionBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardImpression];
    NSArray *customEndcardClickBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardClick];
    
    HyBidCustomCTATracking *customCTATracking = [[HyBidCustomCTATracking alloc] initWithAd:ad];
    
    HyBidAdTracker *adTracker = [[HyBidAdTracker alloc] initWithImpressionURLs:impressionBeacons
                                               withCustomEndcardImpressionURLs:customEndcardImpressionBeacons
                                                                 withClickURLs:clickBeacons
                                                    withCustomEndcardClickURLs:customEndcardClickBeacons
                                                         withCustomCTATracking:customCTATracking
                                                                         forAd:ad];
    PNLiteAdPresenterDecorator *adPresenterDecorator = [[PNLiteAdPresenterDecorator alloc] initWithAdPresenter:adPresenter
                                                                                                 withAdTracker: adTracker
                                                                                                  withDelegate:delegate];
    adPresenter.delegate = adPresenterDecorator;
    return adPresenterDecorator;
}

- (HyBidAdPresenter *)adPresenterFromAd:(HyBidAd *)ad {
    return nil;
}

@end
