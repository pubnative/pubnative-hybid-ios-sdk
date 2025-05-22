// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoSignalDataMainViewController.h"
#import "HyBidDemoSignalDataDetailViewController.h"
#import <HyBid/HyBid.h>
#import "SignalData.h"
#import "UITextView+KeyboardDismiss.h"

@interface HyBidDemoSignalDataMainViewController () <HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedButton;
@property (weak, nonatomic) IBOutlet UITextView *signalDataTextView;
@property (nonatomic, retain) NSNumber *placement;
@property (nonatomic, strong) SignalData *signalData;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;

@end

@implementation HyBidDemoSignalDataMainViewController

- (void)dealloc {
    self.signalData = nil;
    self.interstitialAd = nil;
    self.rewardedAd = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.signalDataTextView addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)clearSignalDataTextView:(UIButton *)sender {
    [self clearTextFrom: self.signalDataTextView];
}

- (IBAction)loadSignalDataTouchUpInside:(UIButton *)sender {
    [self requestAd];
}

- (BOOL)canRequestAd {
    if (self.signalDataTextView.text.length <= 0 || !self.signalDataTextView.text) {
        [self showAlertControllerWithMessage:@"Please input some signal data."];
        return NO;
    } else if (!self.placement){
        [self showAlertControllerWithMessage:@"Please choose a placement."];
        return NO;
    } else {
        self.signalData = [[SignalData alloc] initWithSignalDataText:self.signalDataTextView.text withAdPlacement:self.placement];
        return YES;
    }
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    if ([self canRequestAd]) {
        switch ([self.placement integerValue]) {
            case 0:
            case 1:
            case 2: {
                HyBidDemoSignalDataDetailViewController *signalDataDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignalDataDetailViewController"];
                signalDataDetailVC.signalData = self.signalData;
                signalDataDetailVC.debugButton = self.debugButton;
                [self.navigationController presentViewController:signalDataDetailVC animated:YES completion:nil];
                break;
            }
            case 3:
                self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.interstitialAd prepareAdWithContent:self.signalData.text];
                break;
            case 4:
                self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.rewardedAd prepareAdWithContent:self.signalData.text];
                break;
            default:
                break;
        }
    }
}

- (IBAction)bannerTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)mRectTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)leaderboardTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)interstitialTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

- (IBAction)rewardedTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    self.placement = [NSNumber numberWithInteger:sender.tag];
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    [self.interstitialAd show];
    self.debugButton.hidden = NO;
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

- (void)interstitialDidTrackClick {
    NSLog(@"Interstitial did track click");
}

- (void)interstitialDidTrackImpression {
    NSLog(@"Interstitial did track impression");
}

- (void)interstitialDidDismiss {
    NSLog(@"Interstitial did dismiss");
}

#pragma mark - HyBidRewardedAdDelegate

-(void)rewardedDidLoad {
    NSLog(@"Rewarded did load");
    [self.rewardedAd show];
    self.debugButton.hidden = NO;
}

-(void)rewardedDidFailWithError:(NSError *)error {
    NSLog(@"Rewarded did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
    self.debugButton.hidden = NO;
}

-(void)rewardedDidTrackClick {
    NSLog(@"Rewarded did track click");
}

-(void)rewardedDidTrackImpression {
    NSLog(@"Rewarded did track impression");
}

-(void)rewardedDidDismiss {
    NSLog(@"Rewarded did dismiss");
}

- (void)onReward {
    NSLog(@"Rewarded did reward");
}

@end
