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
#import "PNLiteNativeLoader.h"
#import "PNLiteNativeAdRequest.h"

@interface PNLiteNativeLoader() <PNLiteAdRequestDelegate>

@property (nonatomic, strong) PNLiteNativeAdRequest *nativeAdRequest;
@property (nonatomic, weak) NSObject <PNLiteNativeLoaderDelegate> *delegate;

@end

@implementation PNLiteNativeLoader

- (void)dealloc
{
    self.nativeAdRequest = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.nativeAdRequest = [[PNLiteNativeAdRequest alloc] init];
    }
    return self;
}

- (void)loadNativeAdWithDelegate:(NSObject<PNLiteNativeLoaderDelegate> *)delegate withZoneID:(NSString *)zoneID
{
    self.delegate = delegate;
    [self.nativeAdRequest requestAdWithDelegate:self withZoneID:zoneID];
}

- (void)invokeDidLoadWithNativeAd:(PNLiteNativeAd *)nativeAd
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidLoadWithNativeAd:)]) {
        [self.delegate nativeLoaderDidLoadWithNativeAd:nativeAd];
    }
}

- (void)invokeDidFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeLoaderDidFailWithError:)]) {
        [self.delegate nativeLoaderDidFailWithError:error];
    }
}

#pragma mark PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    if (ad == nil) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad" code:0 userInfo:nil]];
    } else {
        [self invokeDidLoadWithNativeAd:[[PNLiteNativeAd alloc] initWithAd:ad]];
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFailWithError:error];
}

@end
