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

@property (nonatomic, strong) PNLiteAd *ad;
@property (nonatomic, strong) PNLiteImpressionTracker *impressionTracker;
@property (nonatomic, strong) NSDictionary *trackingExtras;
@property (nonatomic, strong) NSMutableDictionary *fetchedAssets;
@property (nonatomic, strong) NSArray *clickableViews;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, weak) NSObject<PNLiteNativeAdDelegate> *delegate;
@property (nonatomic, weak) NSObject<PNLiteNativeAdFetchDelegate> *fetchDelegate;
@property (nonatomic, assign) BOOL isImpressionConfirmed;
@property (nonatomic, assign) NSInteger remainingFetchableAssets;

@end

@implementation PNLiteNativeAd

- (void)dealloc
{
    self.ad = nil;
    self.trackingExtras = nil;
    self.fetchedAssets = nil;
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    for (UIView *view in self.clickableViews) {
        [view removeGestureRecognizer:self.tapRecognizer];
    }
    self.tapRecognizer = nil;
    self.clickableViews = nil;
    [self.impressionTracker clear];
    self.impressionTracker = nil;
    self.bannerImageView = nil;
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

- (UIView *)banner
{
    if (self.bannerImageView == nil) {
        if(self.bannerUrl && self.bannerUrl.length > 0) {
            NSData *bannerData = self.fetchedAssets[[NSURL URLWithString:self.bannerUrl]];
            if(bannerData && bannerData.length > 0) {
                UIImage *bannerImage = [UIImage imageWithData:bannerData];
                if(bannerImage) {
                    self.bannerImageView = [[UIImageView alloc] initWithImage:bannerImage];
                    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
                }
            }
        }
    }
    return self.bannerImageView;
}

- (UIImage *)icon
{
    UIImage *result = nil;
    if(self.iconUrl && self.iconUrl.length > 0) {
        NSData *imageData = self.fetchedAssets[[NSURL URLWithString:self.iconUrl]];
        if(imageData && imageData.length > 0) {
            result = [UIImage imageWithData:imageData];
        }
    }
    return result;
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

#pragma mark Ad Rendering

- (void)renderAd:(PNLiteNativeAdRenderer *)renderer
{
    if(renderer.titleView) {
        renderer.titleView.text = self.title;
    }
    
    if(renderer.bodyView) {
        renderer.bodyView.text = self.body;
    }
    
    if(renderer.callToActionView) {
        if ([renderer.callToActionView isKindOfClass:[UIButton class]]) {
            [(UIButton *) renderer.callToActionView setTitle:self.callToActionTitle forState:UIControlStateNormal];
        } else if ([renderer.callToActionView isKindOfClass:[UILabel class]]) {
            [(UILabel *) renderer.callToActionView setText:self.callToActionTitle];
        }
    }
    
    if (renderer.starRatingView) {
        renderer.starRatingView.value = [self.rating floatValue];
    }
    
    if(renderer.iconView && self.icon) {
        renderer.iconView.image = self.icon;
    }
    
    UIView *banner = self.banner;
    if(renderer.bannerView && banner) {
        [renderer.bannerView addSubview:banner];
        banner.frame = renderer.bannerView.bounds;
    }
    
    UIView *contentInfo = self.contentInfo;
    if (renderer.contentInfoView && contentInfo) {
        [renderer.contentInfoView addSubview:contentInfo];
        contentInfo.frame = renderer.contentInfoView.bounds;
    }
}

#pragma mark Asset Fetching

- (void)fetchNativeAdAssetsWithDelegate:(NSObject<PNLiteNativeAdFetchDelegate> *)delegate
{
    NSMutableArray *assets = [NSMutableArray array];
    if (self.bannerUrl) {
        [assets addObject:self.bannerUrl];
    }
    if (self.iconUrl) {
        [assets addObject:self.iconUrl];
    }
    if (delegate) {
        self.fetchDelegate = delegate;
        [self fetchAssets:assets];
    } else {
        NSLog(@"PNLiteNativeAd - Error: Fetch asssets with delegate nil, dropping this call");
    }
}

- (void)fetchAssets:(NSArray<NSString *> *)assets
{
    if(assets && assets.count > 0) {
        self.remainingFetchableAssets = assets.count;
        for (NSString *assetURLString in assets) {
            [self fetchAsset:assetURLString];
        }
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"No assets to fetch" code:0 userInfo:nil]];
    }
}

- (void)fetchAsset:(NSString *)assetURLString
{
    if (assetURLString && assetURLString.length > 0) {
        __block NSURL *url = [NSURL URLWithString:assetURLString];
        __block PNLiteNativeAd *strongSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                [strongSelf cacheFetchedAssetData:data withURL:url];
                [strongSelf checkFetchProgress];
            } else {
                [strongSelf invokeFetchDidFailWithError:[NSError errorWithDomain:@"Asset can not be downloaded."
                                                                            code:0
                                                                        userInfo:nil]];
            }
            url = nil;
            strongSelf = nil;
        });
    } else {
        [self invokeFetchDidFailWithError:[NSError errorWithDomain:@"Asset URL is nil or empty"
                                                              code:0
                                                          userInfo:nil]];
    }
}

- (void)cacheFetchedAssetData:(NSData *)data withURL:(NSURL*)url
{
    if (self.fetchedAssets == nil) {
        self.fetchedAssets = [NSMutableDictionary dictionary];
    }
    
    if (url && data) {
        self.fetchedAssets[url] = data;
    }
}

- (void)checkFetchProgress
{
    self.remainingFetchableAssets --;
    if (self.remainingFetchableAssets == 0) {
        [self invokeFetchDidFinish];
    }
}

#pragma mark PNLiteImpressionTrackerDelegate

- (void)impressionDetectedWithView:(UIView *)view
{
    [self confirmBeaconsWithType:kPNLiteNativeAdBeaconImpression];
    [self invokeImpressionConfirmedWithView:view];
}

#pragma mark Callback Helpers

- (void)invokeFetchDidFinish
{
    __block NSObject<PNLiteNativeAdFetchDelegate> *delegate = self.fetchDelegate;
    __block PNLiteNativeAd *strongSelf = self;
    self.fetchDelegate = nil;
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(nativeAdDidFinishFetching:)]) {
                [delegate nativeAdDidFinishFetching:strongSelf];
            }
            delegate = nil;
            strongSelf = nil;
        });
    }
}

- (void)invokeFetchDidFailWithError:(NSError *)error
{
    __block NSError *blockError = error;
    __block PNLiteNativeAd *strongSelf = self;
    __block NSObject<PNLiteNativeAdFetchDelegate> *delegate = self.fetchDelegate;
    self.fetchDelegate = nil;
    if (delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(nativeAd:didFailFetchingWithError:)]) {
                [delegate nativeAd:strongSelf didFailFetchingWithError:blockError];
            }
            delegate = nil;
            blockError = nil;
            strongSelf = nil;
        });
    }
}

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
