// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGAMLeaderboardViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGAMLeaderboardViewController () <HyBidAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *leaderboardContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *leaderboardLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) GAMBannerView *gamLeaderboardView;
@property (nonatomic, strong) HyBidAdRequest *leaderboardAdRequest;

@end

@implementation HyBidDemoGAMLeaderboardViewController

- (void)dealloc {
    self.gamLeaderboardView = nil;
    self.leaderboardAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GAM Leaderboard";
    
    [self.leaderboardLoaderIndicator stopAnimating];
    self.gamLeaderboardView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeLeaderboard];
    self.gamLeaderboardView.delegate = self;
    self.gamLeaderboardView.adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMLeaderboardAdUnitIDKey];
    self.gamLeaderboardView.rootViewController = self;
    [self.leaderboardContainer addSubview:self.gamLeaderboardView];
}

- (IBAction)requestLeaderboardTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.leaderboardContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.leaderboardLoaderIndicator startAnimating];
    self.leaderboardAdRequest = [[HyBidAdRequest alloc] init];
    self.leaderboardAdRequest.adSize = HyBidAdSize.SIZE_728x90;
    [self.leaderboardAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    if (self.gamLeaderboardView == bannerView) {
        self.leaderboardContainer.hidden = NO;
        [self.leaderboardLoaderIndicator stopAnimating];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.gamLeaderboardView == bannerView) {
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

#pragma mark - HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    NSLog(@"Request %@ started:",request);
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    NSLog(@"Request loaded with ad: %@",ad);
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", ad.creativeID];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", ad.creativeID];
    
    if (request == self.leaderboardAdRequest) {
        self.debugButton.hidden = NO;
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [self.gamLeaderboardView loadRequest:request];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    if (request == self.leaderboardAdRequest) {
        self.debugButton.hidden = NO;
        [self.leaderboardLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

@end
