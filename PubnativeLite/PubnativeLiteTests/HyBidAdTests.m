//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidAd.h"
#import "PNLIteResponseModel.h"
#import "HyBidError.h"

@interface HyBidAdTests : XCTestCase
@end

@implementation HyBidAdTests

- (void)testInitWithDataAndZoneID_SetsParams {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data);
    
    NSDictionary *jsonDictionary = [self createDictionaryFromData:data];
    if (!jsonDictionary) {
        XCTAssertThrows(NSError.hyBidNullAd);
    }
    
    HyBidAd *ad;
    PNLiteResponseModel  *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictionary];
    for (HyBidAdModel *adModel in response.ads) {
        ad = [[HyBidAd alloc] initWithData:adModel withZoneID:@"4"];
    }
    XCTAssertNotNil(ad);
    
    XCTAssertTrue([ad.skOverlayEnabled isKindOfClass:[NSNumber class]]);
    XCTAssertEqual(ad.skOverlayEnabled.boolValue, YES);
    XCTAssertEqual(ad.pcSKoverlayEnabled.boolValue, YES);
    XCTAssertEqual(ad.fullscreenClickability.boolValue, YES);
    
    XCTAssertTrue([ad.sdkAutoStorekitEnabled isKindOfClass:[NSNumber class]]);
    XCTAssertEqual(ad.sdkAutoStorekitEnabled.boolValue, YES); //pcSDKAutoStorekitEnabled is true
    
    XCTAssertTrue([ad.pcSDKAutoStorekitEnabled isKindOfClass:[NSNumber class]]);
    XCTAssertEqual(ad.pcSDKAutoStorekitEnabled.boolValue, YES);
    
    XCTAssertTrue([ad.audioState isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(ad.audioState, @"on");
    
    XCTAssertTrue([ad.impressionTrackingMethod isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(ad.impressionTrackingMethod, @"viewable");
    XCTAssertEqualObjects(ad.creativeID, @"test_creative");
    XCTAssertEqualObjects(ad.adExperience, @"performance");
    XCTAssertEqualObjects(ad.beacons.firstObject.type, @"impression");
    XCTAssertEqualObjects(ad.beacons.firstObject.data[@"url"], @"https://got.eu-west4gcp1.pubnative.net");


    XCTAssertEqual(ad.closeRewardedAfterFinish.boolValue, NO);
    XCTAssertEqual(ad.closeInterstitialAfterFinish.boolValue, NO);
    XCTAssertEqual(ad.creativeAutoStorekitEnabled.boolValue, YES);
    
    XCTAssertEqual(ad.landingPage, YES);
    XCTAssertEqualObjects(ad.navigationMode, @"internal");
    
    XCTAssertEqualObjects(ad.contentInfoDisplay, @"inapp");
    XCTAssertEqualObjects(ad.contentInfoIconClickAction, @"expand");
    XCTAssertEqualObjects(ad.contentInfoIconURL, @"https://cdn.pubnative.net/static/adserver/contentinfo.png");
    XCTAssertEqualObjects(ad.contentInfoURL, @"https://feedback.verve.com/index.html");
    
    XCTAssertEqual(ad.endcardEnabled.boolValue, NO); //pc_endcardenabled is false
    XCTAssertEqual(ad.customEndcardEnabled.boolValue, YES);
    XCTAssertEqual(ad.endcardCloseDelay.integerValue, 5);
    
    XCTAssertEqual(ad.pcEndcardEnabled.boolValue, NO);
    XCTAssertEqual(ad.pcEndcardCloseDelay.integerValue, 5);
    
    XCTAssertEqual(ad.bcEndcardCloseDelay.integerValue, 0);
    
    XCTAssertEqual(ad.customCtaEnabled.boolValue, YES);
    
    XCTAssertEqual(ad.videoSkipOffset.integerValue, 8);
    XCTAssertEqual(ad.rewardedVideoSkipOffset.integerValue, 30);
    XCTAssertEqual(ad.interstitialHtmlSkipOffset.integerValue, 5);
    XCTAssertEqual(ad.rewardedHtmlSkipOffset.integerValue, 30);
    
    XCTAssertEqual(ad.pcVideoSkipOffset.integerValue, 8);
    XCTAssertEqual(ad.pcRewardedVideoSkipOffset.integerValue, 30);
    XCTAssertEqual(ad.pcRewardedHtmlSkipOffset.integerValue, 30);
    
    XCTAssertEqual(ad.bcVideoSkipOffset.integerValue, 8);
    XCTAssertEqual(ad.bcRewardedVideoSkipOffset.integerValue, 30);
    
    XCTAssertEqual(ad.minVisiblePercent.integerValue, 0);
    XCTAssertEqual(ad.minVisibleTime.integerValue, 0);
    
    XCTAssertEqual(ad.closeInterstitialAfterFinish.boolValue, NO);
    XCTAssertEqual(ad.closeRewardedAfterFinish.boolValue, NO);
    
    XCTAssertEqual(ad.fullscreenClickability.boolValue, YES);
    XCTAssertEqual(ad.hideControls, YES);
    
    XCTAssertEqual(ad.iconSizeReduced, NO);
}

- (NSDictionary *)createDictionaryFromData:(NSData *)data {
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        return nil;
    } else {
        return jsonDictonary;
    }
}

@end
