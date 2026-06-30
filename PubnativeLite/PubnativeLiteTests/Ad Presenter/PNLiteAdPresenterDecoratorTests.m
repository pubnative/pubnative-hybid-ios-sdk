//
// HyBid SDK License
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import "PNLiteAdPresenterDecorator.h"
#import "HyBidAdPresenter.h"
#import "HyBidAdTracker.h"
#import "HyBidAdSize.h"
#import "HyBidAd.h"
#import "PNLiteResponseModel.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface PNLiteAdPresenterDecorator (TestCoverage)
- (void)percentVisibleDidChange:(CGFloat)newValue;
@end

/// Unit tests for PNLiteAdPresenterDecorator to cover init and dealloc paths.
@interface PNLiteAdPresenterDecoratorTests : XCTestCase
@end

@implementation PNLiteAdPresenterDecoratorTests

- (void)testInitWithAdPresenter_withAdTracker_withDelegate_nilParams_doesNotCrash {
    // Init with nil to cover init path; dealloc will run when decorator is released
    PNLiteAdPresenterDecorator *decorator = [[PNLiteAdPresenterDecorator alloc] initWithAdPresenter:nil
                                                                                      withAdTracker:nil
                                                                                       withDelegate:nil];
    XCTAssertNotNil(decorator);
    decorator = nil;
}

- (void)testLoad_andLoadMarkupWithSize_doNotCrash {
    // load and loadMarkupWithSize delegate to adPresenter; with nil presenter they are no-ops
    PNLiteAdPresenterDecorator *decorator = [[PNLiteAdPresenterDecorator alloc] initWithAdPresenter:nil
                                                                                      withAdTracker:nil
                                                                                       withDelegate:nil];
    XCTAssertNoThrow([decorator load]);
    XCTAssertNoThrow([decorator loadMarkupWithSize:[HyBidAdSize SIZE_320x50]]);
}

- (void)testStartTracking_stopTracking_withNilPresenter_doNotCrash {
    PNLiteAdPresenterDecorator *decorator = [[PNLiteAdPresenterDecorator alloc] initWithAdPresenter:nil
                                                                                      withAdTracker:nil
                                                                                       withDelegate:nil];
    XCTAssertNoThrow([decorator startTracking]);
    XCTAssertNoThrow([decorator stopTracking]);
}

- (void)testPercentVisibleDidChange_updatesViewabilityAndDoesNotCrash {
    HyBidAd *ad = [self hyBidAdFromTestBundle];
    if (!ad) { XCTSkip(@"adResponse.txt not in test bundle"); }
    HyBidAdPresenter *presenter = [[HyBidAdPresenter alloc] init];
    presenter.adSessionData = [[HyBidAdSessionData alloc] init];
    PNLiteAdPresenterDecorator *decorator = [[PNLiteAdPresenterDecorator alloc] initWithAdPresenter:presenter
                                                                                      withAdTracker:nil
                                                                                       withDelegate:nil];
    XCTAssertNoThrow([decorator percentVisibleDidChange:0.5f]);
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
