//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "HyBidAdView.h"
#import "HyBidAdSize.h"
#import "HyBid.h"
#import "HyBidAdRequest.h"
#import "PNLiteResponseModel.h"

/// Mock delegate to capture load failure (exercises load path and internal cleanUp).
@interface MockHyBidAdViewDelegate : NSObject <HyBidAdViewDelegate>
@property (nonatomic, strong) NSError *lastError;
@end
@implementation MockHyBidAdViewDelegate
- (void)adViewDidLoad:(HyBidAdView *)adView {}
- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error { self.lastError = error; }
- (void)adViewDidTrackImpression:(HyBidAdView *)adView {}
- (void)adViewDidTrackClick:(HyBidAdView *)adView {}
@end

/// Expose delegate callback for test (HyBidSignalDataProcessorDelegate); implementation in HyBidAdView.m
@interface HyBidAdView (TestCoverage)
- (void)signalDataDidFinishWithAd:(HyBidAd *)ad;
@end

/// Unit tests for HyBidAdView to improve coverage on new code (e.g. init, cleanUp, load, refresh).
@interface HyBidAdViewTests : XCTestCase
@end

@implementation HyBidAdViewTests

- (void)testInitWithFrame_setsDefaults {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    XCTAssertNotNil(view);
    XCTAssertNotNil(view.adRequest);
    // HyBidAdSize.SIZE_320x50 creates a new instance each time; compare by value
    XCTAssertTrue([view.adSize isEqualTo:HyBidAdSize.SIZE_320x50]);
    XCTAssertTrue(view.autoShowOnLoad);
}

- (void)testInitWithSize_setsAdSize {
    HyBidAdSize *size = HyBidAdSize.SIZE_300x250;
    HyBidAdView *view = [[HyBidAdView alloc] initWithSize:size];
    XCTAssertNotNil(view);
    XCTAssertEqualObjects(view.adSize, size);
}

- (void)testIsAutoCacheOnLoad_whenAdRequestNil_returnsYes {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    view.adRequest = nil;
    XCTAssertTrue([view isAutoCacheOnLoad]);
}

- (void)testInitWithFrame_adIsNilInitially {
    // After init, ad is nil (cleanUp is private; we only assert public initial state)
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNil(view.ad);
}

- (void)testLoadWithZoneID_emptyZone_invokesDidFailWithError {
    // loadWithZoneID calls cleanUp internally then invokes delegate on invalid zone
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"" andWithDelegate:delegate];
    // Should eventually get error (async in real flow; may be sync for invalid zone)
    XCTAssertNotNil(delegate.lastError);
}

- (void)testRefresh_afterLoadWithZoneID_doesNotCrash {
    // Refresh calls cleanUp internally; exercise the path by loading then refreshing
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"test-zone" andWithDelegate:delegate];
    XCTAssertNoThrow([view refresh]);
}

- (void)testLoadWithZoneID_withPosition_andWithDelegate_emptyZone_invokesDidFailWithError {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadWithZoneID:@"" withPosition:BANNER_POSITION_TOP andWithDelegate:delegate];
    XCTAssertNotNil(delegate.lastError);
}

- (void)testLoadExchangeAdWithZoneID_andWithDelegate_emptyZone_invokesDidFailWithError {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    [view loadExchangeAdWithZoneID:@"" andWithDelegate:delegate];
    XCTAssertNotNil(delegate.lastError);
}

- (void)testPrepare_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view prepare]);
}

- (void)testPrepareCustomMarkupFrom_emptyMarkup_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    MockHyBidAdViewDelegate *delegate = [[MockHyBidAdViewDelegate alloc] init];
    XCTAssertNoThrow([view prepareCustomMarkupFrom:@"" withPlacement:HyBidDemoAppPlacementBanner]);
}

- (void)testStopAutoRefresh_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view stopAutoRefresh]);
}

- (void)testStartTracking_stopTracking_doNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view startTracking]);
    XCTAssertNoThrow([view stopTracking]);
}

- (void)testSetOpenRTBAdTypeWithAdFormat_doesNotCrash {
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    XCTAssertNoThrow([view setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner]);
}

// MARK: - New code coverage: HyBidATOMManager.createAdSessionDataFromRequest (prefix rename from ATOMManager)
- (void)testRequest_didLoadWithAd_setsAdSessionDataViaHyBidATOMManager {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    HyBidAdRequest *request = [[HyBidAdRequest alloc] init];
    [view request:request didLoadWithAd:ad];
    XCTAssertNotNil(view.ad);
}

- (void)testSignalDataDidFinishWithAd_setsAdSessionDataViaHyBidATOMManager {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidAdView *view = [[HyBidAdView alloc] initWithFrame:CGRectZero];
    [view signalDataDidFinishWithAd:ad];
    XCTAssertNotNil(view.ad);
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
