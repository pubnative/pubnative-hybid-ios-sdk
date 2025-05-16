// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADLeaderboardViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADLeaderboardViewController () <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *leaderboardContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leaderboardLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) GADBannerView *gadLeaderboard;

@end

@implementation HyBidDemoGADLeaderboardViewController

- (void)dealloc {
    self.gadLeaderboard = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GAD Leaderboard";
    
    [self.leaderboardLoaderIndicator stopAnimating];
    self.gadLeaderboard = [[GADBannerView alloc] initWithAdSize:GADAdSizeLeaderboard];
    self.gadLeaderboard.delegate = self;
    self.gadLeaderboard.adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADLeaderboardAdUnitIDKey];
    self.gadLeaderboard.rootViewController = self;
    [self.leaderboardContainer addSubview:self.gadLeaderboard];
    
    [self.leaderboardContainer setIsAccessibilityElement:NO];
    [self.leaderboardContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
}

- (IBAction)requestLeaderboardTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.leaderboardContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.leaderboardLoaderIndicator startAnimating];
    [self.gadLeaderboard loadRequest:[GADRequest request]];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    if (self.gadLeaderboard == bannerView) {
        self.leaderboardContainer.hidden = NO;
        self.debugButton.hidden = NO;
        [self.leaderboardLoaderIndicator stopAnimating];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.gadLeaderboard == bannerView) {
        self.debugButton.hidden = NO;
        [self.leaderboardLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidDismissScreen");
}

@end
