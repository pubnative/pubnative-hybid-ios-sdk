// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoGADMRectViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@import GoogleMobileAds;

@interface HyBidDemoGADMRectViewController () <GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) GADBannerView *gadMRect;

@end

@implementation HyBidDemoGADMRectViewController

- (void)dealloc {
    self.gadMRect = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"GAD MRect";
    
    [self.mRectLoaderIndicator stopAnimating];
    self.gadMRect = [[GADBannerView alloc] initWithAdSize:GADAdSizeMediumRectangle];
    self.gadMRect.delegate = self;
    self.gadMRect.adUnitID = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidGADMRectAdUnitIDKey];
    self.gadMRect.rootViewController = self;
    [self.mRectContainer addSubview:self.gadMRect];
    
    [self.mRectContainer setIsAccessibilityElement:NO];
    [self.mRectContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
}

- (IBAction)requestMRectTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.mRectContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    [self.gadMRect loadRequest:[GADRequest request]];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    if (self.gadMRect == bannerView) {
        self.mRectContainer.hidden = NO;
        self.debugButton.hidden = NO;
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    if (self.gadMRect == bannerView) {
        self.debugButton.hidden = NO;
        [self.mRectLoaderIndicator stopAnimating];
        [self showAlertControllerWithMessage:error.localizedDescription];
    }
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidDismissScreen");
}

@end
