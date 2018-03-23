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

#import "PNLiteInterstitialPresenterFactory.h"
#import "PNLiteAssetGroupType.h"
#import "PNLiteInterstitialPresenterDecorator.h"
#import "PNLiteMRAIDInterstitialPresenter.h"
#import "PNLiteAdTracker.h"

@implementation PNLiteInterstitialPresenterFactory

- (PNLiteInterstitialPresenter *)createInterstitalPresenterWithAd:(PNLiteAd *)ad
                                                     withDelegate:(NSObject<PNLiteInterstitialPresenterDelegate> *)delegate
{
    PNLiteInterstitialPresenter *interstitialPresenter = [self createInterstitalPresenterFromAd:ad];
    if (!interstitialPresenter) {
        return nil;
    }
    PNLiteInterstitialPresenterDecorator *interstitialPresenterDecorator = [[PNLiteInterstitialPresenterDecorator alloc] initWithInterstitialPresenter:interstitialPresenter
                                                                                                                                         withAdTracker:[[PNLiteAdTracker alloc] initWithImpressionURLs:[ad beaconsDataWithType:kPNLiteAdTrackerImpression] withClickURLs:[ad beaconsDataWithType:kPNLiteAdTrackerClick]]
                                                                                                                                          withDelegate:delegate];
    interstitialPresenter.delegate = interstitialPresenterDecorator;
    return interstitialPresenterDecorator;
}

- (PNLiteInterstitialPresenter *)createInterstitalPresenterFromAd:(PNLiteAd *)ad
{
    switch (ad.assetGroupID.integerValue) {
        case MRAID_INTERSTITIAL: {
            PNLiteMRAIDInterstitialPresenter *mraidInterstitalPresenter = [[PNLiteMRAIDInterstitialPresenter alloc] initWithAd:ad];
            return mraidInterstitalPresenter;
            break;
        }
        default:
            NSLog(@"PNLiteInterstitialPresenterFactory - Asset Group %@ is an incompatible Asset Group ID for Interstitial ad format", ad.assetGroupID);
            return nil;
            break;
    }
}

@end
