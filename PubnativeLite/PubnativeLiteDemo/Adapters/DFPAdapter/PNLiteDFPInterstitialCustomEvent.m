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

#import "PNLiteDFPInterstitialCustomEvent.h"
#import "PNLiteDFPUtils.h"

@interface PNLiteDFPInterstitialCustomEvent () <PNLiteInterstitialPresenterDelegate>

@property (nonatomic, strong) PNLiteInterstitialPresenter *interstitialPresenter;
@property (nonatomic, strong) PNLiteInterstitialPresenterFactory *interstitalPresenterFactory;
@property (nonatomic, strong) PNLiteAd *ad;

@end

@implementation PNLiteDFPInterstitialCustomEvent

@synthesize delegate;

- (void)dealloc
{
    self.interstitialPresenter = nil;
    self.interstitalPresenterFactory = nil;
    self.ad = nil;
}

- (void)requestInterstitialAdWithParameter:(NSString * _Nullable)serverParameter
                                     label:(NSString * _Nullable)serverLabel
                                   request:(nonnull GADCustomEventRequest *)request
{
    if ([PNLiteDFPUtils areExtrasValid:serverParameter]) {
        self.ad = [[PNLiteAdCache sharedInstance] retrieveAdFromCacheWithZoneID:[PNLiteDFPUtils zoneID:serverParameter]];
        if (self.ad == nil) {
            [self invokeFailWithMessage:[NSString stringWithFormat:@"PubNativeLite - Error: Could not find an ad in the cache for zone id with key: %@", [PNLiteDFPUtils zoneID:serverParameter]]];
            return;
        }
        self.interstitalPresenterFactory = [[PNLiteInterstitialPresenterFactory alloc] init];
        self.interstitialPresenter = [self.interstitalPresenterFactory createInterstitalPresenterWithAd:self.ad withDelegate:self];
        if (self.interstitialPresenter == nil) {
            [self invokeFailWithMessage:@"PubNativeLite - Error: Could not create valid interstitial presenter"];
            return;
        } else {
            [self.interstitialPresenter load];
        }
    } else {
        [self invokeFailWithMessage:@"PubNativeLite - Error: Failed interstitial ad fetch. Missing required server extras."];
        return;
    }
}

- (void)presentFromRootViewController:(nonnull UIViewController *)rootViewController
{
    [self.delegate customEventInterstitialWillPresent:self];
    [self.interstitialPresenter show];
}

- (void)invokeFailWithMessage:(NSString *)message
{
    [self.delegate customEventInterstitial:self didFailAd:[NSError errorWithDomain:message code:0 userInfo:nil]];
}

#pragma mark - PNLiteInterstitialPresenterDelegate

- (void)interstitialPresenterDidLoad:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)interstitialPresenterDidShow:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    
}

- (void)interstitialPresenterDidClick:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.delegate customEventInterstitialWasClicked:self];
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)interstitialPresenterDidDismiss:(PNLiteInterstitialPresenter *)interstitialPresenter
{
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)interstitialPresenter:(PNLiteInterstitialPresenter *)interstitialPresenter didFailWithError:(NSError *)error
{
    [self invokeFailWithMessage:[NSString stringWithFormat:@"PubNativeLite - Internal Error: %@", error.localizedDescription]];
}

@end
