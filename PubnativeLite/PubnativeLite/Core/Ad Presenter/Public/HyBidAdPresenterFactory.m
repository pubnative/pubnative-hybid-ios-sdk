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
    NSArray *customEndcardImpressionBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardImpression];
    NSArray *clickBeacons = [ad beaconsDataWithType:PNLiteAdTrackerClick];
    NSArray *customEndcardClickBeacons = [ad beaconsDataWithType:PNLiteAdCustomEndCardClick];

    HyBidAdTracker *adTracker = [[HyBidAdTracker alloc] initWithImpressionURLs:impressionBeacons withCustomEndcardImpressionURLs:customEndcardImpressionBeacons withClickURLs:clickBeacons withCustomEndcardClickURLs:customEndcardClickBeacons forAd:ad];
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
