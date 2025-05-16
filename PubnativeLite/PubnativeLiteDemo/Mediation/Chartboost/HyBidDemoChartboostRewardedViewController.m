// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoChartboostRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import <ChartboostSDK/Chartboost.h>

@interface HyBidDemoChartboostRewardedViewController () <CHBRewardedDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;
@property (nonatomic, strong) CHBRewarded *rewarded;

@end

@implementation HyBidDemoChartboostRewardedViewController

- (void)dealloc {
    self.rewarded = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chartboost Mediation Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    self.rewarded = [[CHBRewarded alloc] initWithLocation:self.videoSwitch.isOn ? [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostRewardedVideoPositionKey] : [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostRewardedHTMLPositionKey] delegate:self];
    [self.rewarded cache];
}

- (IBAction)showRewardedAdButtonTapped:(UIButton *)sender {
    if (self.rewarded.isCached) {
        [self.rewarded showFromViewController:self];
    } else {
        NSLog(@"Tried to show a rewarded ad before it is cached");
    }
}

#pragma mark - CHBRewardedDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didCacheAd: %@ %@", [event.ad class], [self statusWithError:error]]);
    if (error) {
        self.showAdButton.hidden = YES;
    } else {
        self.showAdButton.hidden = NO;
    }
    [self.rewardedLoaderIndicator stopAnimating];
    self.debugButton.hidden = NO;
}

- (void)willShowAd:(CHBShowEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"willShowAd: %@", [event.ad class]]);
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didShowAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didDismissAd:(CHBDismissEvent *)event {
    self.showAdButton.hidden = NO;
    NSLog(@"%@", [NSString stringWithFormat:@"didDismissAd: %@", [event.ad class]]);
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didClickAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didRecordImpression:(CHBImpressionEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"didRecordImpression: %@", [event.ad class]]);
}

- (void)didEarnReward:(CHBRewardEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"didEarnReward: %ld", (long)event.reward]);
}

- (NSString *)statusWithError:(id)error {
    return error ? [NSString stringWithFormat:@"FAILED (%@)", error] : @"SUCCESS";
}

@end
