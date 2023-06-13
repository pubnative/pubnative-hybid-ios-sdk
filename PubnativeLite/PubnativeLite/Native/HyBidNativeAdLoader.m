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

#import "HyBidNativeAdLoader.h"
#import "HyBidNativeAdRequest.h"
#import "HyBidIntegrationType.h"
#import "HyBidError.h"
#import "HyBidSignalDataProcessor.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidNativeAdLoader() <HyBidAdRequestDelegate, HyBidSignalDataProcessorDelegate>

@property (nonatomic, strong) HyBidNativeAdRequest *nativeAdRequest;
@property (nonatomic, weak) NSObject <HyBidNativeAdLoaderDelegate> *delegate;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;

@property (nonatomic, weak) NSTimer *autoRefreshTimer;
@property (nonatomic, assign) BOOL shouldRunAutoRefresh;

@end

@implementation HyBidNativeAdLoader

@synthesize autoRefreshTimeInSeconds = _autoRefreshTimeInSeconds;

- (void)dealloc {
    self.nativeAdRequest = nil;
    self.delegate = nil;
    self.zoneID = nil;
    self.appToken = nil;
    [self stopAutoRefresh];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nativeAdRequest = [[HyBidNativeAdRequest alloc] init];
    }
    return self;
}

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kIsUsingOpenRTB];
    [self loadNativeAdWithDelegate:delegate withZoneID:zoneID withAppToken:nil];
}

- (void)loadNativeExchangeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kIsUsingOpenRTB];
    [self loadNativeAdWithDelegate:delegate withZoneID:zoneID withAppToken:nil];
}

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken {
    self.delegate = delegate;
    self.zoneID = zoneID;
    self.appToken = appToken;
    [self requestAd];
}

- (void)prepareNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withContent:(NSString *)adContent {
    self.delegate = delegate;
    if (adContent && [adContent length] != 0) {
        [self processAdContent:adContent];
    } else {
        [self invokeDidFailWithError:[NSError hyBidInvalidAsset]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent];
}

- (void)requestAd {
    if (self.zoneID && [self.zoneID length] > 0) {
        [self.nativeAdRequest setIntegrationType:self.isMediation ? MEDIATION : STANDALONE withZoneID:self.zoneID withAppToken:self.appToken];
        [self.nativeAdRequest requestAdWithDelegate:self withZoneID:self.zoneID withAppToken:self.appToken];
        self.shouldRunAutoRefresh = YES;
        [self setupAutoRefreshTimerIfNeeded];
    }
}

- (void)setupAutoRefreshTimerIfNeeded {
    if (self.autoRefreshTimer == nil && self.autoRefreshTimeInSeconds > 0) {
        self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoRefreshTimeInSeconds target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

- (void)refresh {
    [self invokeWillRefresh];
    [self requestAd];
}

- (void)setAutoRefreshTimeInSeconds:(NSInteger)autoRefreshTimeInSeconds {
    _autoRefreshTimeInSeconds = autoRefreshTimeInSeconds;
    
    if (self.shouldRunAutoRefresh) {
        [self setupAutoRefreshTimerIfNeeded];
    }
}

- (void)stopAutoRefresh {
    self.autoRefreshTimeInSeconds = 0;
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

- (void)invokeDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidLoadWithNativeAd:)]) {
        [self.delegate nativeLoaderDidLoadWithNativeAd:nativeAd];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];

    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidFailWithError:)]) {
        [self.delegate nativeLoaderDidFailWithError:error];
    }
}

- (void)invokeWillRefresh {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderWillRefresh)]) {
        [self.delegate nativeLoaderWillRefresh];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
    
    if ([HyBidSDKConfig sharedConfig].test == TRUE) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"You are using Verve HyBid SDK on test mode. Please disabled test mode before submitting your application for production."];
    }
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError hyBidNullAd]];
    } else {
        [self invokeDidLoadWithNativeAd:[[HyBidNativeAd alloc] initWithAd:ad]];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Signal data loaded with ad: %@", ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError hyBidNullAd]];
    } else {
        [self invokeDidLoadWithNativeAd:[[HyBidNativeAd alloc] initWithAd:ad]];
    }
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

@end
