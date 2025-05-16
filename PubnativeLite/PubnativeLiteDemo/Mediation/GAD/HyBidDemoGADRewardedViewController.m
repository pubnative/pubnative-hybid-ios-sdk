// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADRewardedViewController () <GADFullScreenContentDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) GADRewardedAd *gadRewarded;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@end

@implementation HyBidDemoGADRewardedViewController

- (void)dealloc {
    self.gadRewarded = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)showRewardedTouchUpInside:(id)sender {
    
    if (self.gadRewarded) {
        [self.gadRewarded presentFromRootViewController:self
                               userDidEarnRewardHandler:^ {
            NSLog(@"User did earn rewarded.");
        }];
    } else {
        NSLog(@"Ad wasn't ready");
    }
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADRewardedAdUnitIDKey]
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
            self.debugButton.hidden = NO;
            [self.rewardedLoaderIndicator stopAnimating];
            [self showAlertControllerWithMessage:error.localizedDescription];
            return;
        }
        
        self.gadRewarded = ad;
        NSLog(@"Rewarded ad loaded.");
        self.gadRewarded.fullScreenContentDelegate = self;
        self.debugButton.hidden = NO;
        self.showAdButton.hidden = NO;
        [self.rewardedLoaderIndicator stopAnimating];
    }];
}

#pragma mark GADFullscreenContentDelegate

- (void)adDidPresentFullScreenContent:(id)ad {
    NSLog(@"Rewarded ad presented.");
}

- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    NSLog(@"Rewarded ad failed to present with error: %@", [error localizedDescription]);
    self.debugButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adDidDismissFullScreenContent:(id)ad {
    NSLog(@"Rewarded ad dismissed.");
    self.showAdButton.hidden = YES;
}

@end
