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
#import "HyBidAdExperienceManager.h"
#import "HyBid.h"

@interface HyBidAdExperienceManagerTests : XCTestCase
@end

@implementation HyBidAdExperienceManagerTests

- (HyBidAd *)adWithAssetGroupID:(NSNumber *)assetGroupID adExperience:(NSString *)adExperience {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (assetGroupID) {
        dictionary[@"assetgroupid"] = assetGroupID;
    }
    if (adExperience) {
        dictionary[@"meta"] = @[@{@"type": @"adexperience", @"data": @{@"text": adExperience}}];
    }
    HyBidAdModel *model = [[HyBidAdModel alloc] initWithDictionary:dictionary];
    return [[HyBidAd alloc] initWithData:model withZoneID:@"1"];
}

- (NSArray<NSNumber *> *)compatibleAssetGroupIDs {
    return @[@(VAST_INTERSTITIAL), @(MRAID_320x480), @(MRAID_480x320), @(MRAID_768x1024), @(MRAID_1024x768), @(MRAID_300x600)];
}

- (NSArray<NSNumber *> *)incompatibleAssetGroupIDs {
    return @[@(NON_DEFINED), @(VAST_MRECT), @(MRAID_300x250), @(MRAID_320x50), @(MRAID_300x50), @(MRAID_728x90), @(MRAID_160x600), @(MRAID_250x250), @(MRAID_320x100)];
}

- (void)testCompatibleAssetGroups {
    for (NSNumber *assetGroupID in [self compatibleAssetGroupIDs]) {
        HyBidAd *ad = [self adWithAssetGroupID:assetGroupID adExperience:nil];
        XCTAssertTrue([HyBidAdExperienceManager isBrandCompatible:ad], @"asset group %@ should be brand compatible", assetGroupID);
        XCTAssertTrue([HyBidAdExperienceManager isPerformanceCompatible:ad], @"asset group %@ should be performance compatible", assetGroupID);
    }
}

- (void)testIncompatibleAssetGroups {
    for (NSNumber *assetGroupID in [self incompatibleAssetGroupIDs]) {
        HyBidAd *ad = [self adWithAssetGroupID:assetGroupID adExperience:nil];
        XCTAssertFalse([HyBidAdExperienceManager isBrandCompatible:ad], @"asset group %@ should not be brand compatible", assetGroupID);
        XCTAssertFalse([HyBidAdExperienceManager isPerformanceCompatible:ad], @"asset group %@ should not be performance compatible", assetGroupID);
    }
}

// Pre-existing state recorded in VMI-1686: the brand and performance
// compatibility sets are identical for every asset group id.
- (void)testBrandAndPerformanceCompatibilitySetsAreIdentical {
    for (int assetGroupID = 0; assetGroupID <= 30; assetGroupID++) {
        HyBidAd *ad = [self adWithAssetGroupID:@(assetGroupID) adExperience:nil];
        XCTAssertEqual([HyBidAdExperienceManager isBrandCompatible:ad],
                       [HyBidAdExperienceManager isPerformanceCompatible:ad],
                       @"compatibility sets diverged at asset group %d", assetGroupID);
    }
}

- (void)testHyBidAdCompatibilityAccessorsMatchManager {
    for (int assetGroupID = 0; assetGroupID <= 30; assetGroupID++) {
        HyBidAd *ad = [self adWithAssetGroupID:@(assetGroupID) adExperience:nil];
        XCTAssertEqual(ad.isBrandCompatible, [HyBidAdExperienceManager isBrandCompatible:ad]);
    }
}

- (void)testIsBrandAdMatrix {
    for (NSNumber *assetGroupID in [self compatibleAssetGroupIDs]) {
        XCTAssertTrue([HyBidAdExperienceManager isBrandAd:[self adWithAssetGroupID:assetGroupID adExperience:@"brand"]]);
        XCTAssertFalse([HyBidAdExperienceManager isBrandAd:[self adWithAssetGroupID:assetGroupID adExperience:@"performance"]]);
        XCTAssertFalse([HyBidAdExperienceManager isBrandAd:[self adWithAssetGroupID:assetGroupID adExperience:nil]]);
    }
    for (NSNumber *assetGroupID in [self incompatibleAssetGroupIDs]) {
        XCTAssertFalse([HyBidAdExperienceManager isBrandAd:[self adWithAssetGroupID:assetGroupID adExperience:@"brand"]]);
    }
}

- (void)testIsPerformanceAdMatrix {
    for (NSNumber *assetGroupID in [self compatibleAssetGroupIDs]) {
        XCTAssertTrue([HyBidAdExperienceManager isPerformanceAd:[self adWithAssetGroupID:assetGroupID adExperience:@"performance"]]);
        XCTAssertFalse([HyBidAdExperienceManager isPerformanceAd:[self adWithAssetGroupID:assetGroupID adExperience:@"brand"]]);
        XCTAssertFalse([HyBidAdExperienceManager isPerformanceAd:[self adWithAssetGroupID:assetGroupID adExperience:nil]]);
    }
    for (NSNumber *assetGroupID in [self incompatibleAssetGroupIDs]) {
        XCTAssertFalse([HyBidAdExperienceManager isPerformanceAd:[self adWithAssetGroupID:assetGroupID adExperience:@"performance"]]);
    }
}

- (void)testExperienceChecksWithUnknownValues {
    HyBidAd *unknownExperienceAd = [self adWithAssetGroupID:@(VAST_INTERSTITIAL) adExperience:@"unknown_experience"];
    XCTAssertNil(unknownExperienceAd.adExperience);
    XCTAssertFalse([HyBidAdExperienceManager hasBrandExperience:unknownExperienceAd]);
    XCTAssertFalse([HyBidAdExperienceManager hasPerformanceExperience:unknownExperienceAd]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandAd:unknownExperienceAd]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceAd:unknownExperienceAd]);
}

- (void)testExperienceValueChecks {
    XCTAssertTrue([HyBidAdExperienceManager isBrandExperienceValue:HyBidAdExperienceBrandValue]);
    XCTAssertTrue([HyBidAdExperienceManager isPerformanceExperienceValue:HyBidAdExperiencePerformanceValue]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandExperienceValue:HyBidAdExperiencePerformanceValue]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceExperienceValue:HyBidAdExperienceBrandValue]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandExperienceValue:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceExperienceValue:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandExperienceValue:@""]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceExperienceValue:@""]);
}

- (void)testNilAd {
    XCTAssertFalse([HyBidAdExperienceManager hasBrandExperience:nil]);
    XCTAssertFalse([HyBidAdExperienceManager hasPerformanceExperience:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandCompatible:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceCompatible:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isBrandAd:nil]);
    XCTAssertFalse([HyBidAdExperienceManager isPerformanceAd:nil]);
}

@end
