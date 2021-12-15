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
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"
#import "HyBidError.h"
#import "HyBidRemoteConfigFeature.h"
#import "HyBidRemoteConfigManager.h"

@interface HyBidNativeAdLoader() <HyBidAdRequestDelegate>

@property (nonatomic, strong) HyBidNativeAdRequest *nativeAdRequest;
@property (nonatomic, weak) NSObject <HyBidNativeAdLoaderDelegate> *delegate;

@end

@implementation HyBidNativeAdLoader

- (void)dealloc {
    self.nativeAdRequest = nil;
    self.delegate = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nativeAdRequest = [[HyBidNativeAdRequest alloc] init];
    }
    return self;
}

- (void)loadNativeAdWithDelegate:(NSObject<HyBidNativeAdLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID {
    NSString *nativeString = [HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_NATIVE];
    
    if (![[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:nativeString]) {
        [self invokeDidFailWithError:[NSError hyBidDisabledFormatError]];
    } else {
        self.delegate = delegate;
        [self.nativeAdRequest setIntegrationType:self.isMediation ? MEDIATION : STANDALONE withZoneID:zoneID];
        [self.nativeAdRequest requestAdWithDelegate:self withZoneID:zoneID];
    }
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

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
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

@end
