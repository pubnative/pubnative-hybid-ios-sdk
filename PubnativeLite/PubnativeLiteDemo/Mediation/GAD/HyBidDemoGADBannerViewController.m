// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADBannerViewController () <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) GADBannerView *gadBanner;

@end

@implementation HyBidDemoGADBannerViewController

- (void)dealloc {
    self.gadBanner = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GAD Banner";
    
    [self.bannerLoaderIndicator stopAnimating];
    self.gadBanner = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.gadBanner.delegate = self;
    self.gadBanner.adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADBannerAdUnitIDKey];
    self.gadBanner.rootViewController = self;
    [self.bannerContainer addSubview:self.gadBanner];
    
    [self.bannerContainer setIsAccessibilityElement:NO];
    [self.bannerContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    [self.gadBanner loadRequest:[GADRequest request]];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    if (self.gadBanner == bannerView) {
        self.bannerContainer.hidden = NO;
        self.debugButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.gadBanner == bannerView) {
        self.debugButton.hidden = NO;
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

@end
