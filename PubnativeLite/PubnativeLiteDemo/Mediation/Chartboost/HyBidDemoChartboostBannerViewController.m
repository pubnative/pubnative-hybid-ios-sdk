// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoChartboostBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import <ChartboostSDK/Chartboost.h>

@interface HyBidDemoChartboostBannerViewController () <CHBBannerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bannerContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (nonatomic, strong) CHBBanner *banner;

@end

@implementation HyBidDemoChartboostBannerViewController

- (void)dealloc {
    self.banner = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chartboost Mediation Banner";
    [self.bannerLoaderIndicator stopAnimating];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearDebugTools];
    self.bannerContainer.hidden = YES;
    self.debugButton.hidden = YES;
    self.showAdButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.banner = [[CHBBanner alloc] initWithSize:CHBBannerSizeStandard location:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostBannerPositionKey] delegate:self];
    [self.banner cache];
}

- (IBAction)showBannerAdButtonTapped:(UIButton *)sender {
    if (self.banner.isCached) {
        [self.bannerContainer addSubview:self.banner];
        self.bannerContainer.hidden = NO;
        [self.banner showFromViewController:self];
    } else {
        NSLog(@"Tried to show a Banner ad before it is cached");
    }
}

#pragma mark - CHBBannerDelegate

- (void)didCacheAd:(CHBCacheEvent *)event error:(nullable CHBCacheError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didCacheAd: %@ %@", [event.ad class], [self statusWithError:error]]);
    if (error) {
        self.showAdButton.hidden = YES;
    } else {
        self.showAdButton.hidden = NO;
    }
    [self.bannerLoaderIndicator stopAnimating];
    self.debugButton.hidden = NO;
}

- (void)willShowAd:(CHBShowEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"willShowAd: %@", [event.ad class]]);
}

- (void)didShowAd:(CHBShowEvent *)event error:(nullable CHBShowError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didShowAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didClickAd:(CHBClickEvent *)event error:(nullable CHBClickError *)error {
    NSLog(@"%@", [NSString stringWithFormat:@"didClickAd: %@ %@", [event.ad class], [self statusWithError:error]]);
}

- (void)didRecordImpression:(CHBImpressionEvent *)event {
    NSLog(@"%@", [NSString stringWithFormat:@"didRecordImpression: %@", [event.ad class]]);
}

- (NSString *)statusWithError:(id)error {
    return error ? [NSString stringWithFormat:@"FAILED (%@)", error] : @"SUCCESS";
}
@end
