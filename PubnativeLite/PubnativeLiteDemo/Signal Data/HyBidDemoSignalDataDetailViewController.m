// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//


#import "HyBidDemoSignalDataDetailViewController.h"
#import <HyBid/HyBid.h>

@interface HyBidDemoSignalDataDetailViewController () <HyBidAdViewDelegate>

@property (weak, nonatomic) IBOutlet HyBidAdView *bannerAdView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdViewContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdViewContainerHeightConstraint;

@end

@implementation HyBidDemoSignalDataDetailViewController

- (void)dealloc {
    self.signalData = nil;
    self.debugButton = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch ([self.signalData.placement integerValue]) {
        case 0: {
            self.bannerAdViewContainerWidthConstraint.constant = 380;
            self.bannerAdViewContainerHeightConstraint.constant = 80;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_320x50;
            break;
        }
        case 1: {
            self.bannerAdViewContainerWidthConstraint.constant = 350;
            self.bannerAdViewContainerHeightConstraint.constant = 350;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_300x250;
            break;
        }
        case 2: {
            self.bannerAdViewContainerWidthConstraint.constant = 728;
            self.bannerAdViewContainerHeightConstraint.constant = 90;
            self.bannerAdView.adSize = HyBidAdSize.SIZE_728x90;
            break;
        }
        default:
            break;
    }
    
    [self.bannerAdView renderAdWithContent:self.signalData.text withDelegate:self];

}


- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    self.bannerAdView.hidden = NO;
    self.debugButton.hidden = NO;
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

@end
