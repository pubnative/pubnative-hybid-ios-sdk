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

#import "PNLiteNativeAd.h"
#import "PNLiteAsset.h"
#import "PNLiteDataModel.h"
#import "PNLiteTrackingManager.h"
#import "PNLiteImpressionTracker.h"

NSString * const kPNLiteNativeAdBeaconImpression = @"impression";
NSString * const kPNLiteNativeAdBeaconClick = @"click";

@interface PNLiteNativeAd () <PNLiteImpressionTrackerDelegate>

@property (nonatomic, strong)PNLiteAd *ad;
@property (nonatomic, strong)PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong)NSDictionary *trackingExtras;
@property (nonatomic, strong)NSArray *clickableViews;
@property (nonatomic, strong)UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, weak)NSObject<PNLiteNativeAdDelegate> *delegate;
@property (nonatomic, assign)BOOL isImpressionConfirmed;

@end

@implementation PNLiteNativeAd

- (void)dealloc
{
    self.ad = nil;
    self.trackingExtras = nil;
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
    self.tapRecognizer = nil;
    self.clickableViews = nil;
    [self.impressionTracker clear];
    self.impressionTracker = nil;
}

#pragma mark PNLiteNativeAd

- (instancetype)initWithAd:(PNLiteAd *)ad
{
    self = [super init];
    if (self) {
        self.ad = ad;
    }
    return self;
}

- (NSString *)title
{
    NSString *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.title];
    if (data) {
        result = data.text;
    }
    return nil;
}

- (NSString *)body
{
    NSString *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.body];
    if (data) {
        result = data.text;
    }
    return nil;
}

- (NSString *)callToActionTitle
{
    NSString *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.callToAction];
    if (data) {
        result = data.text;
    }
    return nil;
}

- (NSString *)iconUrl
{
    NSString *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.icon];
    if (data) {
        result = data.url;
    }
    return nil;
}

- (NSString *)bannerUrl
{
    NSString *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.banner];
    if (data) {
        result = data.url;
    }
    return nil;
}

- (NSString *)clickUrl
{
    NSString *result = nil;
    NSString *URLString = self.ad.link;
    if (URLString) {
        NSURL *clickURL = [NSURL URLWithString:URLString];
        result = [self injectExtrasWithUrl:clickURL].absoluteString;
    }
    return result;
}

- (NSNumber *)rating
{
    NSNumber *result = nil;
    PNLiteDataModel *data = [self.ad assetDataWithType:PNLiteAsset.rating];
    if (data) {
        result = data.number;
    }
    return nil;
}

- (UIView *)contentInfo
{
    UIView *result = nil;
    if (self.ad) {
        result = self.ad.contentInfo;
    }
    return result;
}

#pragma mark Tracking & Clicking

- (void)startTrackingView:(UIView *)view withDelegate:(NSObject<PNLiteNativeAdDelegate> *)delegate
{
    [self startTrackingView:view withClickableViews:nil withDelegate:delegate];
}

- (void)startTrackingView:(UIView *)view withClickableViews:(NSArray *)clickableViews withDelegate:(NSObject<PNLiteNativeAdDelegate> *)delegate
{
    [self startTrackingView:view withClickableViews:clickableViews withTrackingExtras:nil withDelegate:delegate];
}

- (void)startTrackingView:(UIView *)view withClickableViews:(NSArray *)clickableViews withTrackingExtras:(NSDictionary *)trackingExtras withDelegate:(NSObject<PNLiteNativeAdDelegate> *)delegate
{
    self.trackingExtras = trackingExtras;
    self.delegate = delegate;
    [self startTrackingImpressionWithView:view];
    [self startTrackingClicksWithView:view withClickableViews:clickableViews];
}

- (void)startTrackingImpressionWithView:(UIView *)view
{
    if (view == nil) {
        NSLog(@"PNLiteNativeAd - startTrackingImpression - Ad view is nil, cannot start tracking");
    } else if (self.isImpressionConfirmed) {
        NSLog(@"PNLiteNativeAd - startTrackingImpression - Impression is already confirmed, dropping impression tracking");
    } else {
        if(self.impressionTracker == nil) {
            self.impressionTracker = [[PNLiteImpressionTracker alloc] init];
            self.impressionTracker.delegate = self;
        }
        [self.impressionTracker addView:view];
    }
}

- (void)startTrackingClicksWithView:(UIView*)view withClickableViews:(NSArray*)clickableViews
{
    if (view == nil && clickableViews == nil) {
        NSLog(@"PNLiteNativeAd - startTrackingClicks - Error: click view is nil, clicks won't be tracked");
    } else if (!self.clickUrl || self.clickUrl.length == 0) {
        NSLog(@"PNLiteNativeAd - startTrackingClicks - Error: clickUrl is empty, clicks won't be tracked");
    } else {
        self.clickableViews = [clickableViews mutableCopy];
        if(self.clickableViews == nil) {
            self.clickableViews = [NSArray arrayWithObjects:view, nil];
        }
        if(self.tapRecognizer == nil) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        }
        for (UIView *clickableView in self.clickableViews) {
            clickableView.userInteractionEnabled=YES;
            [clickableView addGestureRecognizer:self.tapRecognizer];
        }
    }
}

- (void)stopTracking
{
    [self stopTrackingImpression];
    [self stopTrackingClicks];
}

- (void)stopTrackingImpression
{
    [self.impressionTracker clear];
    self.impressionTracker = nil;
}

- (void)stopTrackingClicks
{
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
{
        [self invokeDidClick];
        [self confirmBeaconsWithType:kPNLiteNativeAdBeaconClick];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.clickUrl]];
    }
}

#pragma Confirm Beacons

- (void)confirmBeaconsWithType:(NSString *)type
{
    if (self.ad == nil || self.ad.beacons == nil || self.ad.beacons.count == 0) {
        NSLog(@"PNLiteNativeAd - confirmBeaconsWithType: %@ - Ad beacons not found", type);
    } else {
        for (PNLiteDataModel *beacon in self.ad.beacons) {
            if ([beacon.type isEqualToString:type]) {
                NSString *beaconJs = [beacon stringFieldWithKey:@"js"];
                if (beacon.url && beacon.url.length > 0) {
                    NSURL *beaconUrl = [NSURL URLWithString:beacon.url];
                    NSURL *injectedUrl = [self injectExtrasWithUrl:beaconUrl];
                    [PNLiteTrackingManager trackWithURL:injectedUrl];
                } else if (beaconJs && beaconJs.length > 0) {
                    __block NSString *beaconJsBlock = [beacon stringFieldWithKey:@"js"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWebView *webView = [[UIWebView alloc] init];
                        webView.scalesPageToFit = YES;
                        webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
                        [webView stringByEvaluatingJavaScriptFromString:beaconJsBlock];
                    });
                }
            }
        }
    }
}

- (NSURL*)injectExtrasWithUrl:(NSURL*)url
{
    NSURL *result = url;
    if (self.trackingExtras != nil) {
        NSString *query = result.query;
        if(query == nil) {
            query = @"";
        }
        for (NSString *key in self.trackingExtras) {
            NSString *value = self.trackingExtras[key];
            query = [NSString stringWithFormat:@"%@&%@=%@", query, key, value];
        }
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        [urlComponents setQuery:query];
        result = urlComponents.URL;
    }
    return result;
}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view
{
    [self confirmBeaconsWithType:kPNLiteNativeAdBeaconImpression];
    [self invokeImpressionConfirmedWithView:view];
}

#pragma mark Callback Helpers

- (void)invokeImpressionConfirmedWithView:(UIView *)view
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAd:impressionConfirmedWithView:)]) {
        [self.delegate nativeAd:self impressionConfirmedWithView:view];
    }
}

- (void)invokeDidClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
}

@end
