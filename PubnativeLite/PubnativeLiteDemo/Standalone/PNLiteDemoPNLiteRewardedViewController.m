// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteRewardedViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteRewardedViewController () <HyBidRewardedAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rewardedLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isUsingOpenRTB;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adFormatSwitch;

@end

@implementation PNLiteDemoPNLiteRewardedViewController

- (void)dealloc {
    self.rewardedAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HyBid Rewarded";
    [self.rewardedLoaderIndicator stopAnimating];
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.adFormatSwitch.accessibilityIdentifier = @"openRTBAdFormatSwitch";
    self.adFormatSwitch.hidden = YES;
}

- (IBAction)requestRewardedTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)showRewardedAdButtonTapped:(id)sender {
    if (self.rewardedAd.isReady) {
        [self.rewardedAd show];
    }
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.rewardedLoaderIndicator startAnimating];
    
    self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    [self.rewardedAd setIsAutoCacheOnLoad: self.adCachingSwitch.isOn];
    if (self.isUsingOpenRTB.selectedSegmentIndex == 0) {
        [self.rewardedAd load];
    } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        if (self.adFormatSwitch.selectedSegmentIndex == 0){
            [self.rewardedAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner];
        } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
            [self.rewardedAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdVideo];
        }
        [self.rewardedAd loadExchangeAd];
    }
}

- (IBAction)requestTypeChanged:(id)sender {
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1){
        self.adFormatSwitch.hidden = NO;
    } else{
        self.adFormatSwitch.hidden = YES;
    }
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdTopConstraint.constant = sender.isOn ? 8.0 : 46.0;
    [self.showAdButton setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    [self.rewardedAd prepare];
    self.prepareButton.enabled = NO;
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidRewardedAdDelegate

- (void)rewardedDidLoad {
    NSLog(@"Rewarded did load");
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        [self setCreativeIDLabelWithString:self.rewardedAd.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.rewardedAd.ad.creativeID];
    }
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.rewardedLoaderIndicator stopAnimating];
}

- (void)rewardedDidFailWithError:(NSError *)error {
    NSLog(@"Rewarded did fail with error: %@",error.localizedDescription);
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    [self.rewardedLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)rewardedDidTrackClick {
    NSLog(@"Rewarded did track click");
}

- (void)rewardedDidTrackImpression {
    NSLog(@"Rewarded did track impression");
}

- (void)rewardedDidDismiss {
    NSLog(@"Rewarded did dismiss");
    self.showAdButton.hidden = YES;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
}

- (void)onReward {
    NSLog(@"Rewarded.");
}

@end
