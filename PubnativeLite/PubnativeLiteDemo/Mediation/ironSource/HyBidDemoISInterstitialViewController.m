// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoISInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISInterstitialViewController () <LPMInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) LPMInterstitialAd *interstitialAd;

@end

@implementation HyBidDemoISInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"IS Interstitial";
    
    LPMInitRequestBuilder *requestBuilder = [[LPMInitRequestBuilder alloc] initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey]];
    LPMInitRequest *initRequest = [requestBuilder build];
    [LevelPlay initWithRequest:initRequest completion:^(LPMConfiguration * _Nullable config, NSError * _Nullable error) {
        if(error) {
            // There was an error on initialization. Take necessary actions or retry
        } else {
            // Initialization was successful. You can now create ad objects and load ads or perform other tasks
        }
    }];
    
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
    
    self.interstitialAd = [[LPMInterstitialAd alloc] initWithAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISInterstitialAdUnitIdKey]];
    self.interstitialAd.delegate = self;
    
    [self.interstitialAd loadAd];
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if ([self.interstitialAd isAdReady]) {
        [self.interstitialAd showAdWithViewController: self placementName: NULL];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

#pragma mark - LPMInterstitialAdDelegate

- (void)didLoadAdWithAdInfo:(LPMAdInfo *)adInfo {
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)didFailToLoadAdWithAdUnitId:(NSString *)adUnitId error:(NSError *)error {
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"ironSource Interstitial did fail to load: %@", error.localizedDescription]];
}

- (void)didChangeAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didChangeAdInfo");
}

- (void)didDisplayAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didDisplayAdWithAdInfo");
}

- (void)didFailToDisplayAdWithAdInfo:(LPMAdInfo *)adInfo error:(NSError *)error {
    NSLog(@"Failed to show rewarded ad with error: %@", [error localizedDescription]);
}

- (void)didClickAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didClickAdWithAdInfo");
}

- (void)didCloseAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didCloseAdWithAdInfo");
    self.showAdButton.hidden = YES;
}

@end
