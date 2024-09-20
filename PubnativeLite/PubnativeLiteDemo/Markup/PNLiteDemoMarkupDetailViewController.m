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

// This class is used for showing details for both Markup(Banner and MRect) and URL(Interstitial and Rewarded)
#import "PNLiteDemoMarkupDetailViewController.h"
#import "HyBidAdView.h"
#import "HyBidMarkupUtils.h"
#import "HyBidDemo-Swift.h"

NSString *const baseUrl = @"https://creative-sampler.herokuapp.com/creatives/";
NSString *const ADM_MACRO = @"{[{ .Adm | base64EncodeString | safeHTML }]}";

@interface PNLiteDemoMarkupDetailViewController () <HyBidAdViewDelegate, HyBidInterstitialAdDelegate, HyBidRewardedAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *markupContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markupContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markupContainerHeightConstraint;
@property (nonatomic, strong) HyBidAdView *adView;
@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) HyBidRewardedAd *rewardedAd;
@property (weak, nonatomic) IBOutlet UILabel *creativeIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIButton *openBrowserButton;
@property (nonatomic, strong) NSString *urlString;

@end

@implementation PNLiteDemoMarkupDetailViewController

- (void)dealloc {
    self.markup = nil;
    self.adView = nil;
    self.debugButton = nil;
    self.interstitialAd = nil;
    self.rewardedAd = nil;
    self.creativeID = nil;
    self.urWrap = nil;
    self.urTemplate = nil;
    self.creativeURL = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.markup.placement) {
        case HyBidDemoAppPlacementBanner: {
            self.markupContainerWidthConstraint.constant = 320;
            self.markupContainerHeightConstraint.constant = 50;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_320x50];
            break;
        }
        case HyBidDemoAppPlacementMRect: {
            self.markupContainerWidthConstraint.constant = 300;
            self.markupContainerHeightConstraint.constant = 250;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_300x250];
            break;
        }
        case HyBidDemoAppPlacementLeaderboard: {
            self.markupContainerWidthConstraint.constant = 728;
            self.markupContainerHeightConstraint.constant = 90;
            self.adView = [[HyBidAdView alloc] initWithSize:HyBidAdSize.SIZE_728x90];
            break;
        }
        case HyBidDemoAppPlacementInterstitial:
        case HyBidDemoAppPlacementRewarded: {
            [self.showAdButton setHidden: NO];
            break;
        }
        default:
            break;
    }

    if (self.creativeID != nil){
        self.creativeIDLabel.text = [self.creativeIDLabel.text stringByAppendingString: self.creativeID];
        [self.creativeIDLabel setAccessibilityIdentifier:@"creativeID"];
        [self.creativeIDLabel setAccessibilityLabel:self.creativeID];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(creativeIDLabelTapped)];
        [self.creativeIDLabel addGestureRecognizer:tapGesture];
        self.creativeIDLabel.userInteractionEnabled = YES;
    } else {
        [self.creativeIDLabel setHidden: YES];
        [self.openBrowserButton setHidden:YES];
    }
    
    self.adView.delegate = self;
    [self.markupContainer addSubview:self.adView];
    [self.adView setAccessibilityIdentifier:@"customMarkupAdView"];
    if (self.markup.placement != HyBidDemoAppPlacementInterstitial && self.markup.placement != HyBidDemoAppPlacementRewarded) {
        if (self.urWrap && self.urTemplate != NULL){
            NSString *encodedAdm = [self encodeStringTo64: self.markup.text];
            [self prepareAdForPlacement:self.markup.placement withMarkup: [self wrapInUr: encodedAdm]];
        } else {
            [self prepareAdForPlacement:self.markup.placement withMarkup: self.markup.text];
        }
    }
}

- (IBAction)openCreativeInBrowser:(id)sender {
    if ([self.creativeURL containsString:@"crid"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self.creativeURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
    } else {
        NSString *placementString;
        switch (self.markup.placement) {
            case HyBidDemoAppPlacementBanner:
                placementString = @"banner";
                break;
            case HyBidDemoAppPlacementMRect:
                placementString = @"mrect";
                break;
            case HyBidDemoAppPlacementLeaderboard: {
                placementString = @"leaderboard";
                break;
            }
            case HyBidDemoAppPlacementInterstitial: {
                placementString = @"fullscreen";
                break;
            }
            case HyBidDemoAppPlacementRewarded:
                placementString = @"rewarded";
                break;
        }
        self.urlString = [[NSString alloc] initWithFormat:@"%@%@?crid=%@", baseUrl, placementString, self.creativeID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)wrapInUr:(NSString *)adMarkup {
    self.urTemplate = [self.urTemplate stringByReplacingOccurrencesOfString: ADM_MACRO withString: adMarkup];
    return self.urTemplate;
}

- (NSString*)encodeStringTo64:(NSString*)fromString {
    NSData *someString = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([someString respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [someString base64EncodedStringWithOptions:kNilOptions];
    }
    return base64String;
}

- (void)prepareAdForPlacement:(HyBidMarkupPlacement)placement withMarkup:(NSString *)markupText {

    if (markupText != nil) {
        
        NSArray* configs = [HyBidAdCustomizationUtility checkSavedHyBidAdSettings];
        
        if (configs.count > 0) {
            
            BOOL isFullScreen = placement == HyBidDemoAppPlacementInterstitial || placement == HyBidDemoAppPlacementRewarded;
            BOOL isBanner = placement == HyBidDemoAppPlacementBanner;
            BOOL isMRECT = placement == HyBidDemoAppPlacementMRect;

            int bannerWidth = isBanner ? 320 : 0;
            int bannerHeight = isBanner ? 50 : 0;
            int mrectWidth = isMRECT ? 300 : 0;
            int mrectHeight = isMRECT ? 250 : 0;
            
            [HyBidMarkupUtils isVastXml:markupText completion:^(BOOL isVAST, HyBidVASTParserError* error) {
                [HyBidAdCustomizationUtility postConfigToSamplingEndoingWithAdFormat:isVAST ? @"video" : @"html"
                                                                               width:isBanner ? bannerWidth : mrectWidth
                                                                              height:isBanner ? bannerHeight : mrectHeight
                                                                        isFullscreen:isFullScreen
                                                                          isRewarded:placement == HyBidDemoAppPlacementRewarded
                                                                             admType:@"markup"
                                                                           adContent:markupText
                                                                             configs:configs
                                                                          completion:^(BOOL success, NSString * _Nullable content) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (placement == HyBidDemoAppPlacementInterstitial) {
                            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                            [self.interstitialAd prepareAdWithAdReponse:content];
                        } else if (placement == HyBidDemoAppPlacementRewarded) {
                            self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                            [self.rewardedAd prepareAdWithAdReponse:content];
                        } else {
                            [self.adView renderAdWithAdResponse:content withDelegate:self];
                        }
                        [self.showAdButton setEnabled:NO];
                    });
                }];
                
            }];
            
        } else {
            if (placement == HyBidDemoAppPlacementInterstitial) {
                self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.interstitialAd prepareCustomMarkupFrom:markupText];
            } else if (placement == HyBidDemoAppPlacementRewarded) {
                self.rewardedAd = [[HyBidRewardedAd alloc] initWithZoneID:nil andWithDelegate:self];
                [self.rewardedAd prepareCustomMarkupFrom:markupText];
            } else {
                [self.adView prepareCustomMarkupFrom:markupText withPlacement:placement];
            }
            
            [self.showAdButton setEnabled:NO];
        }
    }
}

- (IBAction)showButtonTouchUpInside:(UIButton *)sender {
    switch (self.markup.placement) {
        case HyBidDemoAppPlacementBanner:
        case HyBidDemoAppPlacementMRect:
        case HyBidDemoAppPlacementLeaderboard:
            break;
        case HyBidDemoAppPlacementInterstitial:
        case HyBidDemoAppPlacementRewarded:
            [self prepareAdForPlacement:self.markup.placement withMarkup:self.markup.text];
            break;
    }
}

- (BOOL)isModal {
     if([self presentingViewController])
         return YES;
     if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
         return YES;
     if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
         return YES;

    return NO;
 }

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
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


- (void)creativeIDLabelTapped {
    // Show toast
    [self showToastWithText:@"Creative ID copied"];
    // Copy text
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.creativeIDLabel.text;
}

- (void)showToastWithText:(NSString *)text {
    // Create and show toast
    UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:toast animated:YES completion:nil];
    // Dismiss toast after 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissViewControllerAnimated:YES completion:nil];
    });
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
