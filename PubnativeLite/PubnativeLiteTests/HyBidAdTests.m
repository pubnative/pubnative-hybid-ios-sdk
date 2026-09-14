//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import "HyBidAd.h"
#import "HyBidAdModel.h"
#import "PNLIteResponseModel.h"
#import "HyBidError.h"
#import "HyBidAd+Internal.h"

@interface HyBidAdTests : XCTestCase
@end

@implementation HyBidAdTests

- (HyBidAd *)adWithRemoteConfigs:(NSDictionary *)jsondata {
    NSDictionary *adDictionary = @{
        @"assetgroupid": @15,
        @"assets": @[],
        @"meta": @[ @{@"type": @"remoteconfigs", @"data": @{@"jsondata": jsondata}} ]
    };
    HyBidAdModel *adModel = [[HyBidAdModel alloc] initWithDictionary:adDictionary];
    return [[HyBidAd alloc] initWithData:adModel withZoneID:@"1"];
}

// VMI-1678: the base rewarded_html_skip_offset key (no adexperience routing) is only
// reachable when the ad is not performance-compatible; covers that branch directly.
- (void)test_rewardedHtmlSkipOffset_noAdExperience_readsBaseKey {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"rewarded_html_skip_offset": @40}];

    XCTAssertEqualObjects(ad.rewardedHtmlSkipOffset, @40);
}

// VMI-1709: skip offsets written as numeric strings are coerced like Android's
// org.json read, (int) Double.parseDouble(value), for every skip-offset key.
- (void)test_skipOffsets_numericString_isCoercedForEveryKey {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"30",
                                              @"pc_video_skip_offset": @"30",
                                              @"bc_video_skip_offset": @"30",
                                              @"rewarded_video_skip_offset": @"30",
                                              @"pc_rewarded_video_skip_offset": @"30",
                                              @"bc_rewarded_video_skip_offset": @"30",
                                              @"html_skip_offset": @"30",
                                              @"pc_html_skip_offset": @"30",
                                              @"rewarded_html_skip_offset": @"30",
                                              @"pc_rewarded_html_skip_offset": @"30"}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @30);
    XCTAssertEqualObjects(ad.pcVideoSkipOffset, @30);
    XCTAssertEqualObjects(ad.bcVideoSkipOffset, @30);
    XCTAssertEqualObjects(ad.rewardedVideoSkipOffset, @30);
    XCTAssertEqualObjects(ad.pcRewardedVideoSkipOffset, @30);
    XCTAssertEqualObjects(ad.bcRewardedVideoSkipOffset, @30);
    XCTAssertEqualObjects(ad.interstitialHtmlSkipOffset, @30);
    XCTAssertEqualObjects(ad.pcInterstitialHtmlSkipOffset, @30);
    XCTAssertEqualObjects(ad.rewardedHtmlSkipOffset, @30);
    XCTAssertEqualObjects(ad.pcRewardedHtmlSkipOffset, @30);
}

- (void)test_skipOffsets_decimalString_truncatesTowardZero {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"30.7"}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @30);
}

- (void)test_skipOffsets_stringWithSurroundingWhitespace_isCoerced {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @" 30 "}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @30);
}

- (void)test_skipOffsets_fractionalStringBelowOne_truncatesToZero {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"0.9"}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @0);
}

- (void)test_skipOffsets_outOfInt32RangeString_saturatesLikeAndroid {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"4294967296",
                                              @"pc_video_skip_offset": @"-4294967296"}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @(INT32_MAX));
    XCTAssertEqualObjects(ad.pcVideoSkipOffset, @(INT32_MIN));
}

- (void)test_skipOffsets_negativeString_isCoercedToNegativeNumber {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"-5"}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @(-5));
}

- (void)test_skipOffsets_nonNumericString_returnsNilNotZero {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @"ninety",
                                              @"pc_video_skip_offset": @"",
                                              @"bc_video_skip_offset": @"30s"}];

    XCTAssertNil(ad.videoSkipOffset);
    XCTAssertNil(ad.pcVideoSkipOffset);
    XCTAssertNil(ad.bcVideoSkipOffset);
}

- (void)test_skipOffsets_plainNumber_isHonouredUnchanged {
    HyBidAd *ad = [self adWithRemoteConfigs:@{@"video_skip_offset": @25}];

    XCTAssertEqualObjects(ad.videoSkipOffset, @25);
}

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

- (HyBidAd *)adWithExperience:(NSString *)experience remoteConfigs:(NSDictionary *)remoteConfigs {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"adResponse" ofType:@"txt"];
    XCTAssertNotNil(path);

    NSData *data = [NSData dataWithContentsOfFile:path];
    XCTAssertNotNil(data);
    NSMutableDictionary *json = [[self createDictionaryFromData:data] mutableCopy];
    XCTAssertTrue([json isKindOfClass:[NSMutableDictionary class]]);

    NSMutableDictionary *adDictionary = json[@"ads"][0];
    XCTAssertTrue([adDictionary isKindOfClass:[NSMutableDictionary class]]);
    NSMutableArray *metadata = adDictionary[@"meta"];
    XCTAssertTrue([metadata isKindOfClass:[NSMutableArray class]]);

    NSMutableDictionary *experienceEntry = nil;
    NSMutableDictionary *remoteConfigsEntry = nil;
    for (NSMutableDictionary *entry in metadata) {
        if ([entry[@"type"] isEqualToString:@"adexperience"]) {
            experienceEntry = entry;
        } else if ([entry[@"type"] isEqualToString:@"remoteconfigs"]) {
            remoteConfigsEntry = entry;
        }
    }
    XCTAssertNotNil(experienceEntry);
    XCTAssertNotNil(remoteConfigsEntry);

    if (experience) {
        experienceEntry[@"data"][@"text"] = experience;
    } else {
        [metadata removeObject:experienceEntry];
    }

    NSMutableDictionary *fixtureConfigs = remoteConfigsEntry[@"data"][@"jsondata"];
    XCTAssertTrue([fixtureConfigs isKindOfClass:[NSMutableDictionary class]]);
    [fixtureConfigs removeObjectsForKeys:@[@"click_through_timer", @"pc_click_through_timer", @"bc_click_through_timer"]];
    [fixtureConfigs addEntriesFromDictionary:remoteConfigs];

    PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:json];
    XCTAssertEqual(response.ads.count, 1);
    HyBidAdModel *adModel = response.ads.firstObject;
    XCTAssertEqual(adModel.assetgroupid.integerValue, 15);
    return [[HyBidAd alloc] initWithData:adModel withZoneID:@"4"];
}

- (void)test_clickThroughTimer_routesExperienceVariantsWithoutBaseFallback {
    NSDictionary *configs = @{
        @"click_through_timer": @20,
        @"pc_click_through_timer": @12,
        @"bc_click_through_timer": @28
    };

    XCTAssertEqual([self adWithExperience:@"performance" remoteConfigs:configs].clickThroughTimer.integerValue, 12);
    XCTAssertEqual([self adWithExperience:@"brand" remoteConfigs:configs].clickThroughTimer.integerValue, 28);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:configs].clickThroughTimer.integerValue, 20);
    XCTAssertNil([self adWithExperience:@"performance" remoteConfigs:@{@"click_through_timer": @20}].clickThroughTimer);
    XCTAssertNil([self adWithExperience:@"brand" remoteConfigs:@{@"click_through_timer": @20}].clickThroughTimer);
}

- (void)test_clickThroughTimer_clampsOutOfRangeValuesAndKeepsBoundaries {
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @(-10)}].clickThroughTimer.integerValue, 5);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @0}].clickThroughTimer.integerValue, 5);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @1}].clickThroughTimer.integerValue, 5);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @5}].clickThroughTimer.integerValue, 5);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @35}].clickThroughTimer.integerValue, 35);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @99}].clickThroughTimer.integerValue, 35);
}

- (void)test_clickThroughTimer_whenKeyIsAbsent_returnsNil {
    XCTAssertNil([self adWithExperience:nil remoteConfigs:@{}].clickThroughTimer);
}

- (void)test_clickThroughTimer_coercesNumericStringsLikeAndroid {
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @"20"}].clickThroughTimer.integerValue, 20);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @" 20 "}].clickThroughTimer.integerValue, 20);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @"+20"}].clickThroughTimer.integerValue, 20);
    // Truncates toward zero, exactly like (int) Double.parseDouble.
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @"20.7"}].clickThroughTimer.integerValue, 20);
    // Still clamped after coercion.
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @"1"}].clickThroughTimer.integerValue, 5);
    XCTAssertEqual([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": @"99"}].clickThroughTimer.integerValue, 35);
    // Routing still applies to coerced strings.
    XCTAssertEqual([self adWithExperience:@"performance"
                            remoteConfigs:@{@"pc_click_through_timer": @"12"}].clickThroughTimer.integerValue, 12);
}

// Non-numeric and non-finite values stay nil so the feature stays off rather than guessing.
- (void)test_clickThroughTimer_rejectsNonNumericStrings {
    for (NSString *bad in @[@"ninety", @"", @"20s", @"20,7", @"1_000", @"NaN", @"Infinity"]) {
        XCTAssertNil([self adWithExperience:nil remoteConfigs:@{@"click_through_timer": bad}].clickThroughTimer,
                     @"expected nil for %@", bad);
    }
}

@end
