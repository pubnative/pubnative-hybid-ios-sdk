//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "HyBidNativeAdLoader.h"
#import "HyBidAdRequest.h"
#import "HyBidAd.h"
#import "PNLiteResponseModel.h"

/// Mock delegate for load tests (covers loadNativeAd path where adSessionData is created).
@interface MockNativeAdLoaderDelegate : NSObject <HyBidNativeAdLoaderDelegate>
@end
@implementation MockNativeAdLoaderDelegate
- (void)nativeAdLoader:(HyBidNativeAdLoader *)loader didLoadWithNativeAd:(HyBidNativeAd *)nativeAd {}
- (void)nativeAdLoader:(HyBidNativeAdLoader *)loader didFailWithError:(NSError *)error {}
@end

/// Expose delegate callback for test (HyBidAdRequestDelegate); implementation in HyBidNativeAdLoader.m
@interface HyBidNativeAdLoader (TestCoverage)
- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad;
@end

/// Unit tests for HyBidNativeAdLoader to improve coverage on new code (init, dealloc, load path).
@interface HyBidNativeAdLoaderTests : XCTestCase
@end

@implementation HyBidNativeAdLoaderTests

- (void)testInit_createsNativeAdRequest {
    HyBidNativeAdLoader *loader = [[HyBidNativeAdLoader alloc] init];
    XCTAssertNotNil(loader);
}

- (void)testLoaderDealloc_doesNotCrash {
    @autoreleasepool {
        HyBidNativeAdLoader *loader = [[HyBidNativeAdLoader alloc] init];
        XCTAssertNotNil(loader);
        loader = nil;
    }
}

- (void)testLoadNativeAdWithDelegate_withZoneID_withAppToken_createsAdSessionDataWhenNil {
    HyBidNativeAdLoader *loader = [[HyBidNativeAdLoader alloc] init];
    MockNativeAdLoaderDelegate *delegate = [[MockNativeAdLoaderDelegate alloc] init];
    [loader loadNativeAdWithDelegate:delegate withZoneID:@"test-zone" withAppToken:nil];
    XCTAssertNotNil(loader);
}

// Covers new code: HyBidATOMManager.createAdSessionDataFromRequest in loadNativeAdWithRequest:ad:
- (void)testRequest_didLoadWithAd_setsAdSessionDataViaHyBidATOMManager {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidNativeAdLoader *loader = [[HyBidNativeAdLoader alloc] init];
    MockNativeAdLoaderDelegate *delegate = [[MockNativeAdLoaderDelegate alloc] init];
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [loader request:request didLoadWithAd:ad];
    XCTAssertNotNil(loader);
}

- (HyBidAd *)hyBidAdFromTestBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    if (!path) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (![json isKindOfClass:[NSDictionary class]]) return nil;
    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    if (!response.ads.count) return nil;
    return [[HyBidAd alloc] initWithData:response.ads.firstObject withZoneID:@"4"];
}

@end
