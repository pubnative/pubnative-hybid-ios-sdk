// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADInterstitialViewController () <GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) GAMInterstitialAd *gadInterstitial;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoGADInterstitialViewController

- (void)dealloc {
    self.gadInterstitial = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    GAMRequest *request = [GAMRequest request];
    [GAMInterstitialAd loadWithAdManagerAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADInterstitialAdUnitIDKey]
                                         request:request
                               completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            self.debugButton.hidden = NO;
            [self.interstitialLoaderIndicator stopAnimating];
            [self showAlertControllerWithMessage:error.localizedDescription];
            return;
        }
        self.debugButton.hidden = NO;
        self.showAdButton.hidden = NO;
        [self.interstitialLoaderIndicator stopAnimating];
        self.gadInterstitial = ad;
        self.gadInterstitial.fullScreenContentDelegate = self;
    }];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.gadInterstitial) {
        [self.gadInterstitial presentFromRootViewController:self];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

#pragma mark GADFullScreenContentDelegate

- (void)adDidPresentFullScreenContent:(id)ad {
    NSLog(@"Ad did present full screen content.");
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSLog(@"Ad failed to present full screen content with error %@.", [error localizedDescription]);
}

- (void)adDidDismissFullScreenContent:(id)ad {
    NSLog(@"Ad did dismiss full screen content.");
    self.showAdButton.hidden = YES;
}

@end
