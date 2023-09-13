//
//  Copyright © 2019 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteDemoMarkupMainViewController.h"
#import "PNLiteDemoMarkupDetailViewController.h"
#import "UITextView+KeyboardDismiss.h"

@interface PNLiteDemoMarkupMainViewController () <HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedButton;
@property (weak, nonatomic) IBOutlet UITextView *markupTextView;
@property (nonatomic) HyBidMarkupPlacement placement;
@property (nonatomic, strong) Markup *markup;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) NSString *creativeID;
@property (nonatomic, strong) NSString *creativeURL;
@property (weak, nonatomic) IBOutlet UISwitch *universalRenderingSwitch;
@property (nonatomic, strong) NSString *urTemplate;
@property (nonatomic, assign) BOOL urWrap;

@end

@implementation PNLiteDemoMarkupMainViewController

- (void)dealloc {
    [self cleanUpAllParams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.markupTextView addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loadMarkupTouchUpInside:(UIButton *)sender {
    [self setURTemplate];
    [self checkIfWrappedInUr];
    [self requestAd];
}

- (BOOL)canRequestAd {
    if (self.markupTextView.text.length <= 0 || !self.markupTextView.text) {
        [self showAlertControllerWithMessage:@"Please input some markup."];
        return NO;
    } else if (!(self.placement >= HyBidDemoAppPlacementBanner && self.placement <= HyBidDemoAppPlacementRewarded)){
        [self showAlertControllerWithMessage:@"Please choose a placement."];
        return NO;
    } else {
        self.markup = [[Markup alloc] initWithMarkupText:self.markupTextView.text withAdPlacement:self.placement];
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
                switch ([self.segmentedControl selectedSegmentIndex]){
                    case 0: {
                        [self loadCreativeWithMarkup: self.markup];
                        break;
                    }
                    case 1: {
                        [self loadCreativeWithURL: self.placement];
                        break;
                    }
                }
                break;
            case HyBidDemoAppPlacementInterstitial:
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                        [self.interstitialAd prepareCustomMarkupFrom:self.markup.text];
                        break;
                    }
                    case 1: {
                        [self loadCreativeWithURL:self.placement];
                        break;
                    }
                }
                break;
                        
            case HyBidDemoAppPlacementRewarded: {
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                        [self.rewardedAd prepareCustomMarkupFrom:self.markup.text];
                        break;
                    }
                    case 1: {
                        [self loadCreativeWithURL:self.placement];
                        break;
                    }
                }
                break;
            }
                
            default:
                break;
            }
        }
}

- (void)setURTemplate {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ur" ofType:@"txt"];
    NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    self.urTemplate = template;
}

- (void)checkIfWrappedInUr {
    if (self.universalRenderingSwitch.on){
        self.urWrap = YES;
    } else {
        self.urWrap = NO;
    }
}

- (void)loadCreativeWithURL:(HyBidMarkupPlacement)placement {
    NSString *urlString = [[self.markupTextView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    if ([urlString containsString:@"|"] || ([urlString containsString:@"<"] && ([urlString containsString:@">"]))){
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    self.creativeURL = urlString;
    [self requestWithUrlForPlacement:urlString forPlacement:placement];
}

- (void)requestWithUrlForPlacement:(NSString *)urlString forPlacement:(HyBidMarkupPlacement)placement {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: urlString]];
    NSMutableDictionary* newRequestHTTPHeader = [[NSMutableDictionary alloc] init];
    [urlRequest setAllHTTPHeaderFields: newRequestHTTPHeader];
    [urlRequest setHTTPMethod:@"GET"];
    [[[NSURLSession sharedSession] dataTaskWithRequest: urlRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
        if(!error){
            [self invokeFinishWithResponse:response placement: placement withData: data];
        } else {
            [self invokeFailWithError: error];
        }
    }] resume];
}

- (void)loadCreativeWithMarkup:(Markup*)markup {
    PNLiteDemoMarkupDetailViewController *markupDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MarkupDetailViewController"];
    markupDetailVC.markup = markup;
    markupDetailVC.urTemplate = self.urTemplate;
    if (self.creativeURL != nil){
        markupDetailVC.creativeURL = self.creativeURL;
        markupDetailVC.creativeID = self.creativeID;
    }
    markupDetailVC.urWrap = self.urWrap;
    markupDetailVC.debugButton = self.debugButton;
    [self cleanUpAllParams];
    if (markup.placement != HyBidDemoAppPlacementLeaderboard) {
        [self.navigationController presentViewController:markupDetailVC animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:markupDetailVC animated:YES];
    }
}

- (void)cleanUpAllParams {
    self.markup = nil;
    self.interstitialAd = nil;
    self.creativeID = nil;
    self.creativeURL = nil;
    self.urTemplate = nil;
    self.urWrap = nil;
}

- (IBAction)bannerTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementBanner;
}

- (IBAction)mRectTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementMRect;
}

- (IBAction)leaderboardTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementLeaderboard;
}

- (IBAction)interstitialTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementInterstitial;
}

- (IBAction)rewardedTouchUpInside:(UIButton *)sender {
    [self.bannerButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.mRectButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.leaderboardButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    [self.rewardedButton setBackgroundColor:[UIColor colorWithRed:0.49 green:0.12 blue:0.51 alpha:1.00]];
    [self.interstitialButton setBackgroundColor:[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1.00]];
    self.placement = HyBidDemoAppPlacementRewarded;
}

- (void)invokeFinishWithResponse:(NSURLResponse *)response placement:(HyBidMarkupPlacement)placement withData:(NSData*)data {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        self.creativeID = dictionary[@"Creative_id"];
    }
    NSString *adString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.markup = [[Markup alloc] initWithMarkupText: adString withAdPlacement:placement];
    [self loadCreativeWithMarkup: self.markup];
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
