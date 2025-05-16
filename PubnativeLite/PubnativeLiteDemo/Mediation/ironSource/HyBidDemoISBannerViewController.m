// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoISBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "IronSource/IronSource.h"

@interface HyBidDemoISBannerViewController () <LPMBannerAdViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (nonatomic, strong) LPMBannerAdView *bannerAd;

@end

@implementation HyBidDemoISBannerViewController

- (void)dealloc {
    if (self.bannerAd) {
        [self.bannerAd destroy];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"IS Banner";
    
    LPMInitRequestBuilder *requestBuilder = [[LPMInitRequestBuilder alloc] initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey]];
    LPMInitRequest *initRequest = [requestBuilder build];
    [LevelPlay initWithRequest:initRequest completion:^(LPMConfiguration * _Nullable config, NSError * _Nullable error) {
        if(error) {
            // There was an error on initialization. Take necessary actions or retry
        } else {
            // Initialization was successful. You can now create ad objects and load ads or perform other tasks
        }
    }];
    
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self destroyBanner];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    if (self.bannerAd) {
        [self destroyBanner];
    }
    [self requestAd];
}

- (void)destroyBanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.bannerAd) {
            [self.bannerAd destroy];
            self.bannerAd = nil;
        }
    });
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    
    self.bannerAd = [[LPMBannerAdView alloc] initWithAdUnitId:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISBannerAdUnitIdKey]];
    LPMAdSize *bannerSize = [LPMAdSize bannerSize];
    [self.bannerAd setAdSize: bannerSize];
    [self.bannerAd setDelegate: self];
    [self.bannerAd loadAdWithViewController: self];
}

#pragma mark - LPMBannerAdViewDelegate

- (void)didLoadAdWithAdInfo:(LPMAdInfo *)adInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bannerAd.frame = CGRectMake(0, 0, self.bannerContainer.frame.size.width, self.bannerContainer.frame.size.height);
        self.bannerContainer.hidden = NO;
        self.debugButton.hidden = NO;
        [self.bannerLoaderIndicator stopAnimating];
        [self.bannerContainer addSubview:self.bannerAd];

        [self.bannerContainer setIsAccessibilityElement: NO];
        [self.bannerContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
    });
}

- (void)didFailToLoadAdWithAdUnitId:(NSString *)adUnitId error:(NSError *)error {
    self.debugButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:[NSString stringWithFormat:@"IronSource Banner did fail to load with message:%@", error.localizedDescription]];
}

- (void)didClickAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didClickAdWithAdInfo");
}

- (void)didDisplayAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didDisplayAdWithAdInfo");
}

- (void)didFailToDisplayAdWithAdInfo:(LPMAdInfo *)adInfo error:(NSError *)error {
    NSLog(@"Failed to show rewarded ad with error: %@", [error localizedDescription]);
}

- (void)didLeaveAppWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didLeaveAppWithAdInfo");
}

- (void)didExpandAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didExpandAdWithAdInfo");
}

- (void)didCollapseAdWithAdInfo:(LPMAdInfo *)adInfo {
    NSLog(@"didCollapseAdWithAdInfo");
}

@end
