//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "HyBid.h"
#import "HyBidURLDriller.h"
#import "HyBidDeeplinkHandler.h"
#import "HyBidAutomaticClickTrackingUtil.h"
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidEndCardView.h"
#import "HyBidEndCardView+Testing.h"
#import "HyBidEndCard.h"
#import "HyBidSkAdNetworkModel.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

static NSString *const kClickThroughURL = @"https://click.test/c";
static NSString *const kOpened = @"ClickThrough - opened";
static NSString *const kFailed = @"ClickThrough - failed";
static NSString *const kCompanionOpened = @"CompanionClickThrough - opened";
static NSString *const kCompanionFailed = @"CompanionClickThrough - failed";

// Unit tests run without a host app, so sharedApplication is nil; this stands in to answer openURL
@interface HyBidClickThroughFakeApplication : NSObject
@property (nonatomic, assign) BOOL openSucceeds;
@property (nonatomic, strong) NSMutableArray<NSURL *> *openedURLs;
@end

@implementation HyBidClickThroughFakeApplication

- (BOOL)canOpenURL:(NSURL *)url {
    return YES;
}

- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL success))completion {
    [self.openedURLs addObject:url];
    BOOL success = self.openSucceeds;
    if (completion) { dispatch_async(dispatch_get_main_queue(), ^{ completion(success); }); }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [super methodSignatureForSelector:selector] ?: [UIApplication instanceMethodSignatureForSelector:selector] ?: [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSUInteger length = invocation.methodSignature.methodReturnLength;
    if (length == 0) { return; }
    void *zero = calloc(1, length);
    [invocation setReturnValue:zero];
    free(zero);
}

@end

static HyBidClickThroughFakeApplication *gFakeApplication;
static IMP gOriginalSharedApplication;

static id HyBidClickThroughFakeSharedApplication(id self, SEL _cmd) {
    return gFakeApplication;
}

@interface HyBidURLDriller (ClickThroughTesting) <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) HyBidClickThroughType clickThroughType;
@end

@interface PNLiteVASTPlayerViewController (ClickThroughTesting)
- (void)openUrlInBrowser:(NSString *)url navigationType:(NSString *)navigationType clickThroughType:(HyBidClickThroughType)clickThroughType;
- (void)triggerClickFlowWith:(NSDictionary *)trackersDictionary;
@end

@interface HyBidEndCardView (ClickThroughTesting)
- (void)navigationToURL:(NSString *)url shouldOpenBrowser:(BOOL)shouldOpenBrowser navigationType:(NSString *)navigationType clickThroughType:(HyBidClickThroughType)clickThroughType;
- (void)triggerClickFlowWith:(HyBidEndCardType)endCardType url:(NSString *)url shouldOpenBrowser:(BOOL)shouldOpenBrowser;
@end

@interface HyBidClickThroughDrillerDelegate : NSObject <HyBidURLDrillerDelegate>
@end

@implementation HyBidClickThroughDrillerDelegate
@end

@interface HyBidClickThroughReportingTests : XCTestCase
@property (nonatomic, strong) NSArray *originalTrackers;
@property (nonatomic, assign) BOOL previousReporting;
@property (nonatomic, strong) HyBidClickThroughDrillerDelegate *drillerDelegate;
@end

@implementation HyBidClickThroughReportingTests

- (void)setUp {
    [super setUp];
    HyBidReportingManager *manager = [HyBidReportingManager sharedInstance];
    self.originalTrackers = [manager.vastTrackers copy];
    self.previousReporting = [HyBidSDKConfig sharedConfig].reporting;
    [HyBidSDKConfig sharedConfig].reporting = YES;
    manager.vastTrackers = [@[] mutableCopy];
    self.drillerDelegate = [[HyBidClickThroughDrillerDelegate alloc] init];
}

- (void)tearDown {
    if (gOriginalSharedApplication) {
        method_setImplementation(class_getClassMethod([UIApplication class], @selector(sharedApplication)), gOriginalSharedApplication);
        gOriginalSharedApplication = NULL;
        gFakeApplication = nil;
    }
    [HyBidSDKConfig sharedConfig].reporting = self.previousReporting;
    [HyBidReportingManager sharedInstance].vastTrackers = [self.originalTrackers mutableCopy];
    [super tearDown];
}

#pragma mark - Helpers

- (void)installFakeApplicationOpenSucceeds:(BOOL)openSucceeds {
    gFakeApplication = [[HyBidClickThroughFakeApplication alloc] init];
    gFakeApplication.openSucceeds = openSucceeds;
    gFakeApplication.openedURLs = [NSMutableArray array];
    Method sharedApplication = class_getClassMethod([UIApplication class], @selector(sharedApplication));
    gOriginalSharedApplication = method_setImplementation(sharedApplication, (IMP)HyBidClickThroughFakeSharedApplication);
}

- (NSArray<HyBidReportingVASTTracker *> *)clickThroughTrackers {
    return [[HyBidReportingManager sharedInstance].vastTrackers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(HyBidReportingVASTTracker *tracker, NSDictionary *bindings) {
        return [tracker.properties[@"type"] containsString:@"ClickThrough"];
    }]];
}

- (void)expectSingleClickThroughWithType:(NSString *)type url:(NSString *)url {
    NSPredicate *recorded = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        HyBidReportingVASTTracker *tracker = [self clickThroughTrackers].firstObject;
        return [tracker.properties[@"type"] isEqualToString:type] && [tracker.properties[@"data"][@"url"] isEqualToString:url];
    }];
    [self waitForExpectations:@[[[XCTNSPredicateExpectation alloc] initWithPredicate:recorded object:nil]] timeout:5.0];
    XCTAssertEqual([self clickThroughTrackers].count, 1);
}

- (void)expectNoClickThrough {
    XCTNSPredicateExpectation *recorded = [[XCTNSPredicateExpectation alloc] initWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        return [self clickThroughTrackers].count > 0;
    }] object:nil];
    recorded.inverted = YES;
    [self waitForExpectations:@[recorded] timeout:1.0];
}

#pragma mark - HyBidAutomaticClickTrackingUtil

- (void)test_reportClickThroughURL_recordsOpenedEntry {
    [HyBidAutomaticClickTrackingUtil reportClickThroughURL:kClickThroughURL type:HyBidClickThroughTypeVideo opened:YES];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_reportCompanionClickThroughURL_recordsCompanionEntry {
    [HyBidAutomaticClickTrackingUtil reportClickThroughURL:kClickThroughURL type:HyBidClickThroughTypeCompanion opened:NO];

    [self expectSingleClickThroughWithType:kCompanionFailed url:kClickThroughURL];
}

- (void)test_reportClickThroughURL_withTypeNone_recordsNothing {
    [HyBidAutomaticClickTrackingUtil reportClickThroughURL:kClickThroughURL type:HyBidClickThroughTypeNone opened:YES];

    [self expectNoClickThrough];
}

- (void)test_reportClickThroughURL_withEmptyURL_recordsNothing {
    [HyBidAutomaticClickTrackingUtil reportClickThroughURL:@"" type:HyBidClickThroughTypeVideo opened:YES];

    [self expectNoClickThrough];
}

- (void)test_reportClickThroughURL_whenReportingDisabled_recordsNothing {
    [HyBidSDKConfig sharedConfig].reporting = NO;

    [HyBidAutomaticClickTrackingUtil reportClickThroughURL:kClickThroughURL type:HyBidClickThroughTypeVideo opened:YES];

    [self expectNoClickThrough];
}

#pragma mark - HyBidURLDriller

- (void)test_clickThroughDrill_onRedirect_recordsOpenedOnce {
    HyBidURLDriller *driller = [[HyBidURLDriller alloc] init];
    driller.url = [NSURL URLWithString:kClickThroughURL];
    driller.clickThroughType = HyBidClickThroughTypeVideo;
    NSHTTPURLResponse *redirect = [[NSHTTPURLResponse alloc] initWithURL:driller.url statusCode:302 HTTPVersion:nil headerFields:nil];
    NSURLRequest *next = [NSURLRequest requestWithURL:[NSURL URLWithString:@"itms-apps://apps.apple.com/app/id1"]];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:driller.url];

    [driller URLSession:[NSURLSession sharedSession] task:task willPerformHTTPRedirection:redirect newRequest:next completionHandler:^(NSURLRequest *request) {}];
    [driller URLSession:[NSURLSession sharedSession] task:task willPerformHTTPRedirection:redirect newRequest:next completionHandler:^(NSURLRequest *request) {}];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_clickThroughDrill_whenRequestFails_recordsFailed {
    [[HyBidURLDriller alloc] startClickThroughDrillWithURLString:@"https://127.0.0.1:9/c" type:HyBidClickThroughTypeVideo delegate:self.drillerDelegate];

    [self expectSingleClickThroughWithType:kFailed url:@"https://127.0.0.1:9/c"];
}

- (void)test_drill_recordsNothing {
    [[HyBidURLDriller alloc] startDrillWithURLString:@"data:,ok" delegate:self.drillerDelegate];

    [self expectNoClickThrough];
}

#pragma mark - HyBidDeeplinkHandler

- (void)test_deeplinkClickThroughFallback_recordsResult {
    [self installFakeApplicationOpenSucceeds:NO];
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:@"vrvdl://?deeplinkUrl=myapp://item"];

    [handler openWithNavigationType:HyBidWebBrowserNavigationExternalValue clickthroughURL:kClickThroughURL clickThroughType:HyBidClickThroughTypeVideo];

    [self expectSingleClickThroughWithType:kFailed url:kClickThroughURL];
}

- (void)test_deeplinkClickThroughFallbackInAppBrowser_recordsOpened {
    [self installFakeApplicationOpenSucceeds:NO];
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:@"vrvdl://?deeplinkUrl=myapp://item"];

    [handler openWithNavigationType:HyBidWebBrowserNavigationInternalValue clickthroughURL:kClickThroughURL clickThroughType:HyBidClickThroughTypeVideo];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_deeplinkFallbackWithoutReporting_recordsNothing {
    [self installFakeApplicationOpenSucceeds:NO];
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:@"vrvdl://?deeplinkUrl=myapp://item"];

    [handler openWithNavigationType:HyBidWebBrowserNavigationExternalValue clickthroughURL:kClickThroughURL];

    [self expectNoClickThrough];
    XCTAssertEqualObjects(gFakeApplication.openedURLs.lastObject.absoluteString, kClickThroughURL);
}

- (void)test_deeplinkMetadataFallback_recordsNothing {
    [self installFakeApplicationOpenSucceeds:NO];
    HyBidDeeplinkHandler *handler = [[HyBidDeeplinkHandler alloc] initWithLink:@"vrvdl://?deeplinkUrl=myapp://item&fallbackUrl=https://fallback.test"];

    [handler openWithNavigationType:HyBidWebBrowserNavigationExternalValue clickthroughURL:kClickThroughURL clickThroughType:HyBidClickThroughTypeVideo];

    [self expectNoClickThrough];
    XCTAssertEqualObjects(gFakeApplication.openedURLs.lastObject.absoluteString, @"https://fallback.test");
}

#pragma mark - Player and end card

- (void)test_playerClickThrough_recordsResult {
    [self installFakeApplicationOpenSucceeds:YES];

    [[[PNLiteVASTPlayerViewController alloc] init] openUrlInBrowser:kClickThroughURL navigationType:HyBidWebBrowserNavigationExternalValue clickThroughType:HyBidClickThroughTypeVideo];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_playerCustomURL_recordsNothing {
    [self installFakeApplicationOpenSucceeds:YES];

    [[[PNLiteVASTPlayerViewController alloc] init] openUrlInBrowser:kClickThroughURL navigationType:HyBidWebBrowserNavigationExternalValue clickThroughType:HyBidClickThroughTypeNone];

    [self expectNoClickThrough];
    XCTAssertEqual(gFakeApplication.openedURLs.count, 1);
}

- (void)test_playerClickFlow_recordsClickThrough {
    [self installFakeApplicationOpenSucceeds:YES];

    [[[PNLiteVASTPlayerViewController alloc] init] triggerClickFlowWith:@{@"throughClickURL": kClickThroughURL}];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_playerClickFlowWithoutStoreKitParameters_recordsClickThrough {
    [self installFakeApplicationOpenSucceeds:YES];
    PNLiteVASTPlayerViewController *player = [[PNLiteVASTPlayerViewController alloc] init];
    [player setValue:[[HyBidSkAdNetworkModel alloc] init] forKey:@"skAdModel"];

    [player triggerClickFlowWith:@{@"throughClickURL": kClickThroughURL}];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_playerClickFlowWithCustomURL_recordsNothing {
    [self installFakeApplicationOpenSucceeds:YES];
    NSString *customURL = [NSString stringWithFormat:@"pnnativebrowser://open?url=%@", kClickThroughURL];

    [[[PNLiteVASTPlayerViewController alloc] init] triggerClickFlowWith:@{@"throughClickURL": customURL}];

    [self expectNoClickThrough];
    XCTAssertEqualObjects(gFakeApplication.openedURLs.firstObject.absoluteString, kClickThroughURL);
}

- (void)test_playerClickThroughInAppBrowser_recordsOpened {
    [[[PNLiteVASTPlayerViewController alloc] init] openUrlInBrowser:kClickThroughURL navigationType:HyBidWebBrowserNavigationInternalValue clickThroughType:HyBidClickThroughTypeVideo];

    [self expectSingleClickThroughWithType:kOpened url:kClickThroughURL];
}

- (void)test_endCardClickThrough_recordsResult {
    [self installFakeApplicationOpenSucceeds:NO];

    [[[HyBidEndCardView alloc] initWithFrame:CGRectZero] navigationToURL:kClickThroughURL shouldOpenBrowser:YES navigationType:HyBidWebBrowserNavigationExternalValue clickThroughType:HyBidClickThroughTypeCompanion];

    [self expectSingleClickThroughWithType:kCompanionFailed url:kClickThroughURL];
}

- (void)test_endCardClickThroughInAppBrowser_recordsOpened {
    [[[HyBidEndCardView alloc] initWithFrame:CGRectZero] navigationToURL:kClickThroughURL shouldOpenBrowser:YES navigationType:HyBidWebBrowserNavigationInternalValue clickThroughType:HyBidClickThroughTypeCompanion];

    [self expectSingleClickThroughWithType:kCompanionOpened url:kClickThroughURL];
}

- (void)test_endCardStaticClickFlow_recordsClickThrough {
    [self installFakeApplicationOpenSucceeds:YES];
    HyBidEndCardView *endCardView = [[HyBidEndCardView alloc] initWithFrame:CGRectZero];
    HyBidEndCard *endCard = [[HyBidEndCard alloc] init];
    endCard.clickThrough = kClickThroughURL;
    endCardView.endCard = endCard;

    [endCardView triggerClickFlowWith:HyBidEndCardType_STATIC url:nil shouldOpenBrowser:YES];

    [self expectSingleClickThroughWithType:kCompanionOpened url:kClickThroughURL];
}

- (void)test_endCardNavigation_recordsNothing {
    [self installFakeApplicationOpenSucceeds:YES];

    [[[HyBidEndCardView alloc] initWithFrame:CGRectZero] navigationToURL:kClickThroughURL shouldOpenBrowser:YES navigationType:HyBidWebBrowserNavigationExternalValue];

    [self expectNoClickThrough];
    XCTAssertEqual(gFakeApplication.openedURLs.count, 1);
}

@end
