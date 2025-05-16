// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteStickyBannerViewController.h"

#import "PNLiteDemoSettings.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteDemoPNLiteStickyBannerViewController () <HyBidAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isUsingOpenRTB;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adFormatSwitch;

@property (nonatomic, strong) HyBidAdView *bannerAdView;
@property (nonatomic) HyBidBannerPosition bannerPosition;

@end

@implementation PNLiteDemoPNLiteStickyBannerViewController

- (void)dealloc {
    self.bannerAdView = nil;
    self.bannerLoaderIndicator = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bannerLoaderIndicator stopAnimating];
    self.navigationItem.title = @"HyBid Sticky Banner";
    self.bannerAdView = [[HyBidAdView alloc] initWithSize:[PNLiteDemoSettings sharedInstance].adSize];
    self.bannerPosition = BANNER_POSITION_TOP;
    self.adFormatSwitch.accessibilityIdentifier = @"openRTBAdFormatSwitch";
    self.adFormatSwitch.hidden = YES;
}

- (IBAction)requestedAdFormat:(id)sender {
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1){
        self.adFormatSwitch.hidden = NO;
    } else {
        self.adFormatSwitch.hidden = YES;
    }
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0: // TOP
            self.bannerPosition = BANNER_POSITION_TOP;
            break;
        case 1: // BOTTOM
            self.bannerPosition = BANNER_POSITION_BOTTOM;
            break;
    }
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.bannerAdView.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    if (self.isUsingOpenRTB.selectedSegmentIndex == 0) {
        [self.bannerAdView loadWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] withPosition:self.bannerPosition andWithDelegate:self];
    } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        if (self.adFormatSwitch.selectedSegmentIndex == 0) {
            [self.bannerAdView setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdBanner];
        } else if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
            [self.bannerAdView setOpenRTBAdTypeWithAdFormat:HyBidOpenRTBAdVideo];
        }
        [self.bannerAdView loadExchangeAdWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] withPosition:self.bannerPosition andWithDelegate:self];
    }
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    if (self.isUsingOpenRTB.selectedSegmentIndex == 1) {
        [self setCreativeIDLabelWithString:self.bannerAdView.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.bannerAdView.ad.creativeID];
    }
    self.bannerAdView.hidden = NO;
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

@end
