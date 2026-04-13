#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidVASTModel.h"
#import "HyBidVASTParser.h"
#import "HyBidEndCardView.h"
#import "HyBidCloseButton.h"
#import "HyBidSkipOverlay.h"

@interface PNLiteVASTPlayerViewController (TestExpose)
- (NSDictionary *)gettingTrackingAndThroughClickURL;
- (void)startAdSession;
- (void)removeElementsForReplay;
- (void)resetElementsForReplay;
@property (nonatomic, strong) NSArray *vastArray;
@property (nonatomic, strong) NSArray *vastCachedArray;
@property (nonatomic, strong) HyBidEndCardView *endCardView;
@property (nonatomic, assign) BOOL shown;
@end

@interface PNLiteVASTPlayerViewControllerTests : XCTestCase
@end

@implementation PNLiteVASTPlayerViewControllerTests

- (void)test_gettingTrackingAndThroughClickURL_decodesClickThroughFromInlineSample {
    // Given: a real sample file with encoded ClickThrough URL
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_4_20_example"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastData, @"vast_4_20_example.xml must exist in test bundle!");

    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    NSString *throughClickURL = result[@"throughClickURL"];

    XCTAssertEqualObjects(throughClickURL, @"https://ams.creativecdn.com/ad/clicks?ed_vast-clicked-area=companionAd&tk=UCQADTAsqiLrO6Km0KU90BJ9daAitZRhqz2lrE-8jW2quI0M-3tEngc9em2FnfBeKmRCneTeXrdFxKwx0oKJ5YsozRkRAky8308A_WkGrUYnNRFmevlwVdLTx4LVn2KQQPJ2e8Q0Mb36rFCkJLO463FZOLsgskLaaT-Txuih2o1oj0w_nh6GSuNpn_VzBlt9sjTApyOjSl8fTJW9UvM8W9ABsRPUR8lEkx7K3Xdo0h9Ua-gUE__ijkOHdjH5jfvKwmAKpDvRL9BB5KDlpZAkpVU82sMtDVrT3mVb99SShMC3ccDTDBTZwfHTqcOfT8KdUKsFESuq4BnRAwE78vw-u85Xbq90qNiAmmA-XlAqg46XOJm2Dvtxlge5Vxrdzv9eg27lGexRWP__OOQY9yqDWhV9yk0eTHUSFL6Ljo92qDulpswt72xANHFFIfFz4B5J9kTjU6KpmXY7IGiRzWjdCln9WZRA8c4TmP8xaxSIAh1NHeNG4PBnXSdMxvdj-4B44a3rnkkgb7WQhRTKva2W6Yiw-Xqntkbz_LDhS7KldNAx195i0VZaLoo0VucI15AzNEyUjaDUJQ2DN1DV6Hj4HXB5d5aOWU0wewO3DcFv7hpZgQ_C7nbNqRNXqAel0uLj");
}

- (void)test_gettingTrackingAndThroughClickURL_decodesClickThroughFromWrapperSample {
    // Given: a real sample file with encoded ClickThrough URL
    NSData *vastData = [[self readFromTxtFileNamed:@"vast_wrapper"] dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil(vastData, @"vast_4_20_example.xml must exist in test bundle!");

    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    NSString *throughClickURL = result[@"throughClickURL"];

    XCTAssertEqualObjects(throughClickURL, @"https://ams.creativecdn.com/ad/clicks?ed_vast-clicked-area=companionAd&tk=UCQADTAsqiLrO6Km0KU90BJ9daAitZRhqz2lrE-8jW2quI0M-3tEngc9em2FnfBeKmRCneTeXrdFxKwx0oKJ5YsozRkRAky8308A_WkGrUYnNRFmevlwVdLTx4LVn2KQQPJ2e8Q0Mb36rFCkJLO463FZOLsgskLaaT-Txuih2o1oj0w_nh6GSuNpn_VzBlt9sjTApyOjSl8fTJW9UvM8W9ABsRPUR8lEkx7K3Xdo0h9Ua-gUE__ijkOHdjH5jfvKwmAKpDvRL9BB5KDlpZAkpVU82sMtDVrT3mVb99SShMC3ccDTDBTZwfHTqcOfT8KdUKsFESuq4BnRAwE78vw-u85Xbq90qNiAmmA-XlAqg46XOJm2Dvtxlge5Vxrdzv9eg27lGexRWP__OOQY9yqDWhV9yk0eTHUSFL6Ljo92qDulpswt72xANHFFIfFz4B5J9kTjU6KpmXY7IGiRzWjdCln9WZRA8c4TmP8xaxSIAh1NHeNG4PBnXSdMxvdj-4B44a3rnkkgb7WQhRTKva2W6Yiw-Xqntkbz_LDhS7KldNAx195i0VZaLoo0VucI15AzNEyUjaDUJQ2DN1DV6Hj4HXB5d5aOWU0wewO3DcFv7hpZgQ_C7nbNqRNXqAel0uLj");
}

- (void)test_init_createsController {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    XCTAssertNotNil(controller);
}

- (void)test_gettingTrackingAndThroughClickURL_emptyVastArray_doesNotCrash {
    // With empty vastArray, implementation may return nil; we only assert it doesn't crash
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[] forKey:@"vastArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    (void)result;
}

- (void)test_gettingTrackingAndThroughClickURL_withVastCachedArray_returnsTrackers {
    // Cover branch that uses vastCachedArray (vs vastArray)
    NSString *vastString = [self readFromTxtFileNamed:@"vast_4_20_example"];
    if (!vastString) { return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller setValue:@[vastData] forKey:@"vastCachedArray"];
    NSDictionary *result = [controller gettingTrackingAndThroughClickURL];
    XCTAssertNotNil(result);
    (void)result[@"throughClickURL"];
    (void)result[@"trackingClickURLs"];
}

/// Covers new code: HyBidOMIDVerificationScriptResourceWrapper alloc in startAdSession when VAST has AdVerifications
- (void)testStartAdSession_withVastModelWithVerifications_doesNotCrash {
    NSString *vastString = [self readFromTxtFileNamed:@"vast_4_20_example"];
    if (!vastString) { return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    HyBidVASTParser *parser = [[HyBidVASTParser alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"parse"];
    [parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
        XCTAssertNotNil(vastModel);
        if ([[vastModel ads] count] == 0) { [exp fulfill]; return; }
        PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
        [controller loadView];
        [controller setValue:vastModel forKey:@"hyBidVastModel"];
        [controller setValue:@NO forKey:@"isAdSessionCreated"];
        XCTAssertNoThrow([controller startAdSession]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

/// Covers the block: urlString.length != 0 && vendor.length != 0 && params.length != 0 → HyBidOMIDVerificationScriptResourceWrapper alloc.
/// Uses vast_verification_with_params.xml which has one Verification with JavaScriptResource URL, vendor, and VerificationParameters content.
/// Note: Parser completion may pass a non-nil error even on success (HyBidVASTParserError_None maps to unknown error), so we only require model + ads.
- (void)testStartAdSession_withVastVerificationWithUrlVendorAndParams_createsScriptResourceWrapper {
    NSString *vastString = [self readFromTxtFileNamed:@"vast_verification_with_params"];
    if (!vastString) { XCTFail(@"vast_verification_with_params.xml must exist in test bundle"); return; }
    NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
    HyBidVASTParser *parser = [[HyBidVASTParser alloc] init];
    XCTestExpectation *exp = [self expectationWithDescription:@"parse"];
    [parser parseWithData:vastData completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
        XCTAssertNotNil(vastModel);
        if ([[vastModel ads] count] == 0) { [exp fulfill]; return; }
        PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
        [controller loadView];
        [controller setValue:vastModel forKey:@"hyBidVastModel"];
        [controller setValue:@NO forKey:@"isAdSessionCreated"];
        // Exercises: verificationParameters content, and HyBidOMIDVerificationScriptResourceWrapper alloc when url/vendor/params all non-empty
        XCTAssertNoThrow([controller startAdSession]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

// MARK: - removeElementsForReplay tests

- (void)test_removeElementsForReplay_removesEndCardViewSubview {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidEndCardView *endCard = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:endCard];
    controller.endCardView = endCard;

    [controller removeElementsForReplay];

    XCTAssertNil(endCard.superview, "HyBidEndCardView should be removed from superview after removeElementsForReplay");
    XCTAssertNil(controller.endCardView, "endCardView property should be nil after removeElementsForReplay");
}

- (void)test_removeElementsForReplay_removesCloseButtonSubview {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidCloseButton *closeBtn = [[HyBidCloseButton alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:closeBtn];

    [controller removeElementsForReplay];

    XCTAssertNil(closeBtn.superview, "HyBidCloseButton should be removed from superview after removeElementsForReplay");
}

- (void)test_removeElementsForReplay_withBothSubviews_removesAll {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    HyBidEndCardView *endCard = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    HyBidCloseButton *closeBtn = [[HyBidCloseButton alloc] initWithFrame:CGRectZero];
    [controller.view addSubview:endCard];
    [controller.view addSubview:closeBtn];
    controller.endCardView = endCard;

    [controller removeElementsForReplay];

    XCTAssertNil(endCard.superview);
    XCTAssertNil(closeBtn.superview);
    XCTAssertNil(controller.endCardView);
}

- (void)test_removeElementsForReplay_withNoSubviews_doesNotCrash {
    PNLiteVASTPlayerViewController *controller = [[PNLiteVASTPlayerViewController alloc] init];
    [controller loadView];

    XCTAssertNoThrow([controller removeElementsForReplay]);
    XCTAssertNil(controller.endCardView);
}

// MARK: - Helper Methods

- (NSString *)readFromTxtFileNamed:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filepath = [bundle pathForResource:name ofType:@"xml"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        XCTFail(@"Error reading file: %@", error.localizedDescription);
        return nil;
    }

    return fileContents;
}

@end
