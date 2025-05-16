// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteInterstitialViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteInterstitialViewController () <HyBidInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *interstitialLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIButton *prepareButton;
@property (weak, nonatomic) IBOutlet UISwitch *adCachingSwitch;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showAdTopConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isUsingOpenRTB;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adFormatSwitch;

@end

@implementation PNLiteDemoPNLiteInterstitialViewController

- (void)dealloc {
    self.interstitialAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"HyBid Interstitial";
    [self.interstitialLoaderIndicator stopAnimating];
    self.showAdTopConstraint.constant = 8.0;
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.adFormatSwitch.accessibilityIdentifier = @"openRTBAdFormatSwitch";
    self.adFormatSwitch.hidden = YES;
}

- (IBAction)requestInterstitialTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.interstitialLoaderIndicator startAnimating];
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
    [self.interstitialAd setIsAutoCacheOnLoad: self.adCachingSwitch.isOn];
    if (self.isUsingOpenRTB.selectedSegmentIndex == 0) {
        [self.interstitialAd load];
    } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        if (self.adFormatSwitch.selectedSegmentIndex == 0) {
            [self.interstitialAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner];
        } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
            [self.interstitialAd setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdVideo];
        }
        [self.interstitialAd loadExchangeAd];
    }
}

- (IBAction)requestTypeChanged:(id)sender {
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1){
        self.adFormatSwitch.hidden = NO;
    } else{
        self.adFormatSwitch.hidden = YES;
    }
}

- (IBAction)showInterstitialAdButtonTapped:(UIButton *)sender {
    if (self.interstitialAd.isReady) {
        [self.interstitialAd show];
    }
}

- (IBAction)adCachingSwitchValueChanged:(UISwitch *)sender {
    self.prepareButton.hidden = sender.isOn;
    self.showAdTopConstraint.constant = sender.isOn ? 8.0 : 46.0;
    [self.showAdButton setNeedsDisplay];
}

- (IBAction)prepareButtonTapped:(UIButton *)sender {
    [self.interstitialAd prepare];
    self.prepareButton.enabled = NO;
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        [self setCreativeIDLabelWithString:self.interstitialAd.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.interstitialAd.ad.creativeID];
    }
    self.debugButton.hidden = NO;
    self.showAdButton.hidden = NO;
    self.prepareButton.enabled = !self.adCachingSwitch.isOn;
    self.showAdButton.enabled = YES;
    [self.interstitialLoaderIndicator stopAnimating];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    self.prepareButton.enabled = NO;
    self.showAdButton.enabled = NO;
    self.debugButton.hidden = NO;
    [self.interstitialLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)interstitialDidTrackClick {
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression {
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss {
    NSLog(@"Interstitial did dismiss");
    self.showAdButton.hidden = YES;
    self.showAdButton.enabled = NO;
    self.prepareButton.enabled = NO;
}

@end
