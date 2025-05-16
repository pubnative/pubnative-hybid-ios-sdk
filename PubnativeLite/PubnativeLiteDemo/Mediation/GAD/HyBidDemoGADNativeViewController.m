// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADNativeViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADNativeViewController () <GADNativeAdLoaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *nativeAdContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nativeAdLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property(nonatomic, strong) GADAdLoader *adLoader;
@property(nonatomic, strong) GADNativeAdView *nativeAdView;

@end

@implementation HyBidDemoGADNativeViewController

- (void)dealloc {
    self.adLoader = nil;
    self.nativeAdView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"GAD Native";
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (IBAction)requestNativeAdTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.nativeAdContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.nativeAdLoaderIndicator startAnimating];
    
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADNativeAdUnitIDKey]
                                       rootViewController:self
                                                  adTypes:@[ GADAdLoaderAdTypeNative ]
                                                  options:@[ [[GADNativeAdViewAdOptions alloc] init] ]];
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}

#pragma mark GADNativeAdLoaderDelegate

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
    [self.nativeAdLoaderIndicator stopAnimating];
}

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveNativeAd:(nonnull GADNativeAd *)nativeAd {
    NSLog(@"Received native ad: %@", nativeAd);

    GADNativeAdView *nativeAdView = [[NSBundle mainBundle] loadNibNamed:@"HyBidDemoGADNativeView" owner:nil options:nil].firstObject;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nativeAdView;
    self.nativeAdView.frame = self.nativeAdContainer.bounds;
    [self.nativeAdContainer addSubview:self.nativeAdView];
    self.nativeAdContainer.hidden = NO;
    self.debugButton.hidden = NO;
    
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    [((UIButton *)nativeAdView.callToActionView)setTitle:nativeAd.callToAction
                                                forState:UIControlStateNormal];
    nativeAdView.callToActionView.userInteractionEnabled = NO;
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    ((UIImageView *)nativeAdView.imageView).image = nativeAd.images.firstObject.image;
    nativeAdView.nativeAd = nativeAd;
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    if (self.adLoader == adLoader) {
        self.debugButton.hidden = NO;
        [self.nativeAdLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}
@end
