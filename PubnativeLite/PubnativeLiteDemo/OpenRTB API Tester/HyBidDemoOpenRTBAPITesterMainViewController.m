// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidDemoOpenRTBAPITesterMainViewController.h"
#import "HyBidDemoOpenRTBAPITesterDetailViewController.h"
#import <HyBid/HyBid.h>
#import "UITextView+KeyboardDismiss.h"

@interface HyBidDemoOpenRTBAPITesterMainViewController () <HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedButton;
@property (weak, nonatomic) IBOutlet UITextView *adReponseTextView;
@property (nonatomic, strong) NSString *adResponse;
@property (nonatomic) HyBidMarkupPlacement placement;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation HyBidDemoOpenRTBAPITesterMainViewController

- (void)dealloc {
    [self cleanUpAllParams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.adReponseTextView addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)clearAdReponseTextView:(UIButton *)sender {
    [self clearTextFrom: self.adReponseTextView];
}

- (IBAction)loadAdReponseTouchUpInside:(UIButton *)sender {
    [self requestAd];
}

- (BOOL)canRequestAd {
    if (self.adReponseTextView.text.length <= 0 || !self.adReponseTextView.text) {
        [self showAlertControllerWithMessage:@"Please input some ad reponse data."];
        return NO;
    } else if (!(self.placement >= HyBidDemoAppPlacementBanner && self.placement <= HyBidDemoAppPlacementRewarded)){
        [self showAlertControllerWithMessage:@"Please choose a placement."];
        return NO;
    } else {
        self.adResponse = self.adReponseTextView.text;
        return YES;
    }
}

- (void)requestAd {
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    if ([self canRequestAd]) {
        switch (self.placement) {
                case HyBidDemoAppPlacementBanner:
                case HyBidDemoAppPlacementMRect:
                case HyBidDemoAppPlacementLeaderboard:
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        [self loadWithAdResponse: self.adResponse];
                        break;
                    }
                    case 1: {
                        [self loadWithURL:self.placement];
                        break;
                    }
                }
                break;
            case HyBidDemoAppPlacementInterstitial:
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                        [self.interstitialAd prepareExchangeAdWithAdReponse:self.adResponse];
                        break;
                    }
                    case 1: {
                        [self loadWithURL:self.placement];
                        break;
                    }
                }
                break;
            case HyBidDemoAppPlacementRewarded:
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                        [self.rewardedAd prepareExchangeAdWithAdReponse:self.adResponse];
                        break;
                    }
                    case 1: {
                        [self loadWithURL:self.placement];
                        break;
                    }
                }
                break;
        }
    }
}

- (void)loadWithURL:(HyBidMarkupPlacement)placement {
    NSString *urlString = [[self.adReponseTextView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    [self requestWithUrlForPlacement:urlString forPlacement:placement];
}

- (void)requestWithUrlForPlacement:(NSString *)urlString forPlacement:(HyBidMarkupPlacement)placement {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: urlString]];
    [urlRequest setHTTPMethod:@"GET"];
    [[[NSURLSession sharedSession] dataTaskWithRequest: urlRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        if(!error){
            [self invokeFinishWithResponse:response placement: placement withData: data];
        } else {
            [self invokeFailWithError: error];
        }
    }] resume];
}

- (void)loadWithAdResponse: (NSString*)adResponse {
    HyBidDemoOpenRTBAPITesterDetailViewController *openRTBAPITesterDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HyBidDemoOpenRTBAPITesterDetailViewController"];
    openRTBAPITesterDetailVC.adResponse = self.adResponse;
    openRTBAPITesterDetailVC.placement = self.placement;
    openRTBAPITesterDetailVC.debugButton = self.debugButton;
    [self cleanUpAllParams];
    if (self.placement != HyBidDemoAppPlacementLeaderboard) {
        [self.navigationController presentViewController:openRTBAPITesterDetailVC animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:openRTBAPITesterDetailVC animated:YES];
    }
}

- (void)cleanUpAllParams {
    self.adResponse = nil;
    self.interstitialAd = nil;
    self.rewardedAd = nil;
}

- (IBAction)bannerTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementBanner;
}

- (IBAction)mRectTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementMRect;
}

- (IBAction)leaderboardTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementLeaderboard;
}

- (IBAction)interstitialTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementInterstitial;
}

- (IBAction)rewardedTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementRewarded;
}

- (void)invokeFinishWithResponse:(NSURLResponse *)response placement:(HyBidMarkupPlacement)placement withData:(NSData*)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *adResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.adResponse = adResponse;
        [self loadWithAdResponse: adResponse];
    });
}

- (void)invokeFailWithError:(NSError *) error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
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

