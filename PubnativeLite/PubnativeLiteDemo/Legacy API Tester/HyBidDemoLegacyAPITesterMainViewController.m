//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidDemoLegacyAPITesterMainViewController.h"
#import "HyBidDemoLegacyAPITesterDetailViewController.h"
#import <HyBid/HyBid.h>
#import "UITextView+KeyboardDismiss.h"
#import "HyBidDemo-Swift.h"

@interface HyBidDemoLegacyAPITesterMainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *mRectButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedButton;
@property (weak, nonatomic) IBOutlet UITextView *adReponseTextView;
@property (nonatomic) HyBidMarkupPlacement placement;
@property (nonatomic, strong) NSString *adResponse;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSDate *startTime;

@end

@implementation HyBidDemoLegacyAPITesterMainViewController

- (void)dealloc {
    [self cleanUpAllParams];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placement = -1;
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
    self.startTime = [NSDate date];
    if ([self canRequestAd]) {
        switch (self.placement) {
            case HyBidDemoAppPlacementBanner:
            case HyBidDemoAppPlacementMRect:
            case HyBidDemoAppPlacementLeaderboard: {
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        [self loadWithAdResponse: self.adResponse url:nil];
                        break;
                    }
                    case 1: {
                        [self loadWithURL:self.placement];
                        break;
                    }
                }
                break;
            }
            case HyBidDemoAppPlacementInterstitial:
                switch ([self.segmentedControl selectedSegmentIndex]) {
                    case 0: {
                        [self loadWithAdResponse: self.adResponse url:nil];
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
                        [self loadWithAdResponse: self.adResponse url:nil];
                        break;
                    }
                    case 1: {
                        [self loadWithURL:self.placement];
                        break;
                    }
                }
                break;
            default:
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

- (void)loadWithAdResponse:(NSString*)adResponse url:(NSString *)url {
    HyBidDemoLegacyAPITesterDetailViewController *legacyAPITesterDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HyBidDemoLegacyAPITesterDetailViewController"];
    legacyAPITesterDetailVC.adResponse = self.adResponse;
    legacyAPITesterDetailVC.placement = self.placement;
    legacyAPITesterDetailVC.debugButton = self.debugButton;
    
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:url
                                                               withResponse:adResponse
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate: self.startTime] * 1000.0]
                                                            withRequestBody:nil];
    
    NSArray* configs = [HyBidAdCustomizationUtility checkSavedHyBidAdSettings];
    if (configs.count > 0) {
        
        BOOL isFullScreen = self.placement == HyBidDemoAppPlacementInterstitial || self.placement == HyBidDemoAppPlacementRewarded;
        BOOL isBanner = self.placement == HyBidDemoAppPlacementBanner;
        BOOL isMRECT = self.placement == HyBidDemoAppPlacementMRect;

        int bannerWidth = isBanner ? 320 : 0;
        int bannerHeight = isBanner ? 50 : 0;
        int mrectWidth = isMRECT ? 300 : 0;
        int mrectHeight = isMRECT ? 250 : 0;
        
        [HyBidAdCustomizationUtility postConfigToSamplingEndoingWithAdFormat:@"html"
                                                                       width:isBanner ? bannerWidth : mrectWidth
                                                                      height:isBanner ? bannerHeight : mrectHeight
                                                                isFullscreen:isFullScreen
                                                                  isRewarded:self.placement == HyBidDemoAppPlacementRewarded
                                                                     admType:@"apiv3"
                                                                   adContent:self.adResponse
                                                                     configs:configs
                                                                  completion:^(BOOL success, NSString * _Nullable content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self cleanUpAllParams];
                dispatch_async(dispatch_get_main_queue(), ^{
                    legacyAPITesterDetailVC.adResponse = content;
                    if (self.placement != HyBidDemoAppPlacementLeaderboard) {
                        [self.navigationController presentViewController:legacyAPITesterDetailVC animated:YES completion:nil];
                    } else {
                        [self.navigationController pushViewController:legacyAPITesterDetailVC animated:YES];
                    }
                });
            });
        }];
        
    } else {
        [self cleanUpAllParams];
        if (self.placement != HyBidDemoAppPlacementLeaderboard) {
            [self.navigationController presentViewController:legacyAPITesterDetailVC animated:YES completion:nil];
        } else {
            [self.navigationController pushViewController:legacyAPITesterDetailVC animated:YES];
        }
    }
}

- (void)cleanUpAllParams {
    self.adResponse = nil;
    self.startTime = nil;
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
        [self loadWithAdResponse: adResponse url: response.URL.absoluteString];
    });
}

- (void)invokeFailWithError:(NSError *) error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}

@end

