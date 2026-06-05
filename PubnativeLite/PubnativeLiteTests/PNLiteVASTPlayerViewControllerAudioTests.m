//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import "PNLiteVASTPlayerViewController.h"
#import <objc/runtime.h>

@interface PNLiteVASTPlayerViewController (AudioTesting)
- (void)configureAudioSessionForAdPlayback;
- (void)activateAudioSession:(BOOL)activate;
@end

// --- Mock that does NOT subclass AVAudioSession (avoids class-cluster init returning real singleton) ---
@class MockAVAudioSession;
static MockAVAudioSession *gTestSession = nil;

@interface MockAVAudioSession : NSObject
@property (nonatomic, copy) NSString *lastSetCategory;
@property (nonatomic, assign) BOOL lastSetActive;
@property (nonatomic, assign) NSUInteger setCategoryCallCount;
@property (nonatomic, assign) NSUInteger setActiveCallCount;
@end

@implementation MockAVAudioSession
- (BOOL)setCategory:(AVAudioSessionCategory)category error:(NSError * _Nullable *)outError {
    _lastSetCategory = category;
    _setCategoryCallCount++;
    return YES;
}
- (BOOL)setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError * _Nullable *)outError {
    _lastSetCategory = category;
    _setCategoryCallCount++;
    return YES;
}
- (BOOL)setActive:(BOOL)active error:(NSError * _Nullable *)outError {
    _lastSetActive = active;
    _setActiveCallCount++;
    return YES;
}
@end

// --- Swizzle sharedInstance to return our test session ---
static id (*OriginalSharedInstance)(id, SEL) = NULL;
static Method gSharedInstanceMethod = NULL;

static id SwizzledSharedInstance(id self, SEL _cmd) {
    if (gTestSession) return gTestSession;
    return OriginalSharedInstance(self, _cmd);
}

@interface PNLiteVASTPlayerViewControllerAudioTests : XCTestCase
@property (nonatomic, strong) MockAVAudioSession *testSession;
@end

@implementation PNLiteVASTPlayerViewControllerAudioTests

+ (void)setUp {
    [super setUp];
    if (!gSharedInstanceMethod) {
        gSharedInstanceMethod = class_getClassMethod([AVAudioSession class], @selector(sharedInstance));
        if (gSharedInstanceMethod) {
            OriginalSharedInstance = (id (*)(id, SEL))method_getImplementation(gSharedInstanceMethod);
        }
    }
}

- (void)setUp {
    [super setUp];
    _testSession = [[MockAVAudioSession alloc] init];
    gTestSession = _testSession;
    if (gSharedInstanceMethod && OriginalSharedInstance) {
        method_setImplementation(gSharedInstanceMethod, (IMP)SwizzledSharedInstance);
    }
}

- (void)tearDown {
    gTestSession = nil;
    if (gSharedInstanceMethod && OriginalSharedInstance) {
        method_setImplementation(gSharedInstanceMethod, (IMP)OriginalSharedInstance);
    }
    [super tearDown];
}

- (void)test_configureAudioSessionForAdPlayback_setsCategoryToAmbient {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    [vc configureAudioSessionForAdPlayback];

    XCTAssertEqualObjects(self.testSession.lastSetCategory, AVAudioSessionCategoryAmbient);
    XCTAssertTrue(self.testSession.lastSetActive);
    XCTAssertGreaterThanOrEqual(self.testSession.setCategoryCallCount, 1u);
    XCTAssertGreaterThanOrEqual(self.testSession.setActiveCallCount, 1u);
}

- (void)test_configureAudioSessionForAdPlayback_activatesSession {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    [vc configureAudioSessionForAdPlayback];

    XCTAssertTrue(self.testSession.lastSetActive);
}

- (void)test_activateAudioSessionYES_setsCategoryToAmbient {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    [vc activateAudioSession:YES];

    XCTAssertEqualObjects(self.testSession.lastSetCategory, AVAudioSessionCategoryAmbient);
    XCTAssertTrue(self.testSession.lastSetActive);
}

- (void)test_activateAudioSessionNO_deactivatesSession {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    [vc activateAudioSession:NO];

    XCTAssertFalse(self.testSession.lastSetActive);
    XCTAssertGreaterThanOrEqual(self.testSession.setActiveCallCount, 1u);
    XCTAssertGreaterThanOrEqual(self.testSession.setCategoryCallCount, 1u);
}

- (void)test_activateAudioSession_stillSetsCategoryBeforeActive {
    PNLiteVASTPlayerViewController *vc = [[PNLiteVASTPlayerViewController alloc] init];
    [vc activateAudioSession:YES];

    XCTAssertEqualObjects(self.testSession.lastSetCategory, AVAudioSessionCategoryAmbient);
}

@end

