// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteNativeAdViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "HyBidSKAdNetworkViewController.h"

@interface PNLiteDemoPNLiteNativeAdViewController () <HyBidNativeAdLoaderDelegate, HyBidNativeAdDelegate, HyBidNativeAdFetchDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *nativeAdContainer;
@property (weak, nonatomic) IBOutlet UIView *nativeAdContentInfo;
@property (weak, nonatomic) IBOutlet UIImageView *nativeAdIcon;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdTitle;
@property (weak, nonatomic) IBOutlet HyBidStarRatingView *nativeAdRating;
@property (weak, nonatomic) IBOutlet UIView *nativeAdBanner;
@property (weak, nonatomic) IBOutlet UILabel *nativeAdBody;
@property (weak, nonatomic) IBOutlet UIButton *nativeCallToAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nativeAdLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UILabel *creativeIdLabel;
@property (nonatomic, strong) HyBidNativeAdLoader *nativeAdLoader;
@property (nonatomic, strong) HyBidNativeAd *nativeAd;
@property (weak, nonatomic) IBOutlet UISwitch *autoRefreshSwitch;

@end

@implementation PNLiteDemoPNLiteNativeAdViewController

- (void)dealloc {
    [self.nativeAdLoader stopAutoRefresh];
    self.nativeAdLoader = nil;
    [self.nativeAd stopTracking];
    self.nativeAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HyBid Native Ad";
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (IBAction)requestNativeAdTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
    self.nativeAdContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.nativeAdLoaderIndicator startAnimating];
    self.nativeAdLoader = [[HyBidNativeAdLoader alloc] init];
    [self.nativeAdLoader loadNativeAdWithDelegate:self withZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey]];
}

- (IBAction)autoRefreshSwitchValueChanged:(UISwitch *)sender {
    if (self.nativeAdLoader == nil) {
        [sender setOn: !sender.isOn];
        return;
    }
    if (sender.isOn) {
        self.nativeAdLoader.autoRefreshTimeInSeconds = 30;
    } else {
        [self.nativeAdLoader stopAutoRefresh];
    }
}

- (void)setCreativeIDLabelWithString:(NSString *)string {
    self.creativeIdLabel.text = [NSString stringWithFormat:@"%@", string];
    self.creativeIdLabel.accessibilityValue = [NSString stringWithFormat:@"%@", string];
}

#pragma mark - HyBidNativeAdLoaderDelegate

- (void)nativeLoaderDidLoadWithNativeAd:(HyBidNativeAd *)nativeAd {
    NSLog(@"Native Ad: %@ did load",nativeAd);
    self.debugButton.hidden = NO;
    self.nativeAd = nativeAd;
    if (self.nativeAd.ad.isUsingOpenRTB) {
        [self setCreativeIDLabelWithString:self.nativeAd.ad.openRTBCreativeID];
    } else {
        [self setCreativeIDLabelWithString:self.nativeAd.ad.creativeID];
    }
    [self.nativeAd fetchNativeAdAssetsWithDelegate:self];
}

- (void)nativeLoaderDidFailWithError:(NSError *)error {
    NSLog(@"Native Ad did fail with error: %@",error.localizedDescription);
    self.debugButton.hidden = NO;
    [self.nativeAdLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)nativeLoaderWillRefresh {
    [self setCreativeIDLabelWithString:@"_"];
    [self clearDebugTools];
}

#pragma mark - HyBidNativeAdFetchDelegate

- (void)nativeAdDidFinishFetching:(HyBidNativeAd *)nativeAd {
    HyBidNativeAdRenderer *renderer = [[HyBidNativeAdRenderer alloc] init];
    renderer.contentInfoView = self.nativeAdContentInfo;
    renderer.iconView = self.nativeAdIcon;
    renderer.titleView = self.nativeAdTitle;
    renderer.starRatingView = self.nativeAdRating;
    renderer.bannerView = self.nativeAdBanner;
    renderer.bodyView = self.nativeAdBody;
    renderer.callToActionView = self.nativeCallToAction;
    
    [self.nativeAd renderAd:renderer];
    self.nativeAdContainer.hidden = NO;
    [self.nativeAd startTrackingView:self.nativeAdContainer withDelegate:self];
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (void)nativeAd:(HyBidNativeAd *)nativeAd didFailFetchingWithError:(NSError *)error {
    NSLog(@"Native Ad did fail with error: %@",error.localizedDescription);
    [self.nativeAdLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

#pragma mark - HyBidNativeAdDelegate

- (void)nativeAd:(HyBidNativeAd *)nativeAd impressionConfirmedWithView:(UIView *)view {
    NSLog(@"Native Ad did track impression:");
}

- (void)nativeAdDidClick:(HyBidNativeAd *)nativeAd {
    NSLog(@"Native Ad did track click:");
}

- (void)displaySkAdNetworkViewController:(NSDictionary *)productParameters
{
    dispatch_async(dispatch_get_main_queue(), ^{
        HyBidSKAdNetworkViewController *skAdnetworkViewController = [[HyBidSKAdNetworkViewController alloc] initWithProductParameters: productParameters delegate: self];
        [skAdnetworkViewController presentSKStoreProductViewController:^(BOOL success) {
           
        }];
    });
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {}
@end
