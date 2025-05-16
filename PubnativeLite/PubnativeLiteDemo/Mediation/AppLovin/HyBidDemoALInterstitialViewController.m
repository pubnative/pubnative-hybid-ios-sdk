// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoALInterstitialViewController.h"
#import "PNLiteDemoSettings.h"
#import <AppLovinSDK/AppLovinSDK.h>

@interface HyBidDemoALInterstitialViewController () <MAAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;

@end

@implementation HyBidDemoALInterstitialViewController

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"AppLovin Mediation Interstitial";
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
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidALMediationInterstitialAdUnitIDKey]];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if ([self.interstitialAd isReady]) {
        [self.interstitialAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad {
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Interstitial did fail to load with message:%@", error.message]];
}

- (void)didDisplayAd:(nonnull MAAd *)ad {
    NSLog(@"didDisplayAd");
}

- (void)didHideAd:(nonnull MAAd *)ad {
    NSLog(@"didHideAd");
}

- (void)didClickAd:(MAAd *)ad {
    NSLog(@"didClickAd");
}

- (void)didFailToDisplayAd:(MAAd *)ad withError:(MAError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"AppLovin Interstitial did fail to display with message:%@", error.message]];
}

@end
