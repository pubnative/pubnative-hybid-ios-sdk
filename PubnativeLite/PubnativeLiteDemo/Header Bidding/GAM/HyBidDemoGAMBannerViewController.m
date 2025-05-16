// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGAMBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGAMBannerViewController () <HyBidAdRequestDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) GAMBannerView *gamBannerView;
@property (nonatomic, strong) HyBidAdRequest *bannerAdRequest;

@end

@implementation HyBidDemoGAMBannerViewController

- (void)dealloc {
    self.gamBannerView = nil;
    self.bannerAdRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GAM Banner";
    
    [self.bannerLoaderIndicator stopAnimating];
    self.gamBannerView = [[GAMBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.gamBannerView.delegate = self;
    self.gamBannerView.adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGAMBannerAdUnitIDKey];
    self.gamBannerView.rootViewController = self;
    [self.bannerContainer addSubview:self.gamBannerView];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdRequest = [[HyBidAdRequest alloc] init];
    self.bannerAdRequest.adSize = HyBidAdSize.SIZE_320x50;
    [self.bannerAdRequest requestAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    if (self.gamBannerView == bannerView) {
        self.bannerContainer.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.gamBannerView == bannerView) {
        [self.bannerLoaderIndicator stopAnimating];
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
    
    if (request == self.bannerAdRequest) {
        self.debugButton.hidden = NO;
        GAMRequest *request = [GAMRequest request];
        request.customTargeting = [HyBidHeaderBiddingUtils createHeaderBiddingKeywordsDictionaryWithAd:ad];
        [self.gamBannerView loadRequest:request];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    if (request == self.bannerAdRequest) {
        self.debugButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

@end
