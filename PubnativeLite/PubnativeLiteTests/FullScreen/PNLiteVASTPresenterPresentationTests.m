#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "PNLiteVASTInterstitialPresenter.h"
#import "PNLiteVASTRewardedPresenter.h"

@interface PNLiteVASTInterstitialPresenter (TestExpose)
- (void)setVastViewController:(UIViewController *)vastViewController;
@end

@interface PNLiteVASTRewardedPresenter (TestExpose)
- (void)setVastViewController:(UIViewController *)vastViewController;
@end

@interface PNLiteVASTPresentingSpyViewController : UIViewController
@property (nonatomic, assign) NSUInteger presentCount;
@property (nonatomic, weak) UIViewController *lastPresentedViewController;
@end

@implementation PNLiteVASTPresentingSpyViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    self.presentCount += 1;
    self.lastPresentedViewController = viewControllerToPresent;
    if (completion) { completion(); }
}

@end

@interface PNLiteVASTPresentedPlayerStubViewController : UIViewController
@property (nonatomic, strong) UIViewController *stubbedPresentingViewController;
@end

@implementation PNLiteVASTPresentedPlayerStubViewController

- (UIViewController *)presentingViewController {
    return self.stubbedPresentingViewController;
}

@end

@interface PNLiteVASTPresenterPresentationTests : XCTestCase
@end

@implementation PNLiteVASTPresenterPresentationTests

- (void)drainMainQueue {
    XCTestExpectation *drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [drained fulfill];
    });
    [self waitForExpectations:@[drained] timeout:1.0];
}

// MARK: - VMI-1668
// A repeated show resolves the already-presented VAST player as the "top" view controller,
// so presenting it again would ask UIKit to present that player on itself and crash with
// NSInvalidArgumentException.

- (void)test_interstitialShowFromViewController_whenTargetIsTheVideoPlayerItself_doesNotPresent {
    PNLiteVASTInterstitialPresenter *presenter = [[PNLiteVASTInterstitialPresenter alloc] initWithAd:nil
                                                                                      withSkipOffset:nil
                                                                                   withCloseOnFinish:NO];
    PNLiteVASTPresentingSpyViewController *player = [PNLiteVASTPresentingSpyViewController new];
    [presenter setVastViewController:player];

    [presenter showFromViewController:player];
    [self drainMainQueue];

    XCTAssertEqual(player.presentCount, 0);
}

- (void)test_interstitialShowFromViewController_whenVideoPlayerIsAlreadyPresented_doesNotPresent {
    PNLiteVASTInterstitialPresenter *presenter = [[PNLiteVASTInterstitialPresenter alloc] initWithAd:nil
                                                                                      withSkipOffset:nil
                                                                                   withCloseOnFinish:NO];
    PNLiteVASTPresentedPlayerStubViewController *player = [PNLiteVASTPresentedPlayerStubViewController new];
    player.stubbedPresentingViewController = [UIViewController new];
    [presenter setVastViewController:player];
    PNLiteVASTPresentingSpyViewController *host = [PNLiteVASTPresentingSpyViewController new];

    [presenter showFromViewController:host];
    [self drainMainQueue];

    XCTAssertEqual(host.presentCount, 0);
}

- (void)test_interstitialShowFromViewController_whenVideoPlayerIsNotPresented_presentsOnce {
    PNLiteVASTInterstitialPresenter *presenter = [[PNLiteVASTInterstitialPresenter alloc] initWithAd:nil
                                                                                      withSkipOffset:nil
                                                                                   withCloseOnFinish:NO];
    UIViewController *player = [UIViewController new];
    [presenter setVastViewController:player];
    PNLiteVASTPresentingSpyViewController *host = [PNLiteVASTPresentingSpyViewController new];

    [presenter showFromViewController:host];
    [self drainMainQueue];

    XCTAssertEqual(host.presentCount, 1);
    XCTAssertEqualObjects(host.lastPresentedViewController, player);
}

- (void)test_rewardedShowFromViewController_whenTargetIsTheVideoPlayerItself_doesNotPresent {
    PNLiteVASTRewardedPresenter *presenter = [[PNLiteVASTRewardedPresenter alloc] initWithAd:nil
                                                                           withCloseOnFinish:NO];
    PNLiteVASTPresentingSpyViewController *player = [PNLiteVASTPresentingSpyViewController new];
    [presenter setVastViewController:player];

    [presenter showFromViewController:player];
    [self drainMainQueue];

    XCTAssertEqual(player.presentCount, 0);
}

- (void)test_rewardedShowFromViewController_whenVideoPlayerIsAlreadyPresented_doesNotPresent {
    PNLiteVASTRewardedPresenter *presenter = [[PNLiteVASTRewardedPresenter alloc] initWithAd:nil
                                                                           withCloseOnFinish:NO];
    PNLiteVASTPresentedPlayerStubViewController *player = [PNLiteVASTPresentedPlayerStubViewController new];
    player.stubbedPresentingViewController = [UIViewController new];
    [presenter setVastViewController:player];
    PNLiteVASTPresentingSpyViewController *host = [PNLiteVASTPresentingSpyViewController new];

    [presenter showFromViewController:host];
    [self drainMainQueue];

    XCTAssertEqual(host.presentCount, 0);
}

- (void)test_rewardedShowFromViewController_whenVideoPlayerIsNotPresented_presentsOnce {
    PNLiteVASTRewardedPresenter *presenter = [[PNLiteVASTRewardedPresenter alloc] initWithAd:nil
                                                                           withCloseOnFinish:NO];
    UIViewController *player = [UIViewController new];
    [presenter setVastViewController:player];
    PNLiteVASTPresentingSpyViewController *host = [PNLiteVASTPresentingSpyViewController new];

    [presenter showFromViewController:host];
    [self drainMainQueue];

    XCTAssertEqual(host.presentCount, 1);
    XCTAssertEqualObjects(host.lastPresentedViewController, player);
}

@end
