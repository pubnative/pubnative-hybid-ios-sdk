//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "PNLiteDemoCreativeTesterViewController.h"
#import "PNLiteHttpRequest.h"
#import "Markup.h"
#import "PNLiteDemoMarkupDetailViewController.h"
#import "UITextField+KeyboardDismiss.h"

#import <HyBid/HyBid.h>

@interface PNLiteDemoCreativeTesterViewController () <PNLiteHttpRequestDelegate, HyBidInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UITextField *creativeIdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *adSizeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;

@property (strong, nonatomic) HyBidInterstitialAd *interstitialAd;
@property (nonatomic, strong) Markup *markup;

@end

@implementation PNLiteDemoCreativeTesterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Creative Tester";
    [self.creativeIdTextField addDismissKeyboardButtonWithTitle:@"Done" withTarget:self withSelector:@selector(dismissKeyboard)];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loadButtonTapped:(UIButton *)sender {
    [self requestAd];
}

- (void)requestAd
{
    [self clearDebugTools];
    self.debugButton.hidden = YES;
    if ([[self.creativeIdTextField text] length] > 0) {
        NSString *creativeID = [[self.creativeIdTextField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *urlString = [[NSString alloc] initWithFormat:@"https://docker.creative-serving.com/preview?cr=%@&type=adi", creativeID];
        
        [[PNLiteHttpRequest alloc] startWithUrlString:urlString withMethod:@"GET" delegate:self];
    } else {
        [self showAlertControllerWithMessage:@"Creative ID field cannot be empty."];
    }
}

-(void)deinit
{
    self.markup = nil;
    self.interstitialAd = nil;
}

// MARK: - Helper Methods

- (void)displayAd {
    switch ([self.adSizeSegmentedControl selectedSegmentIndex]) {
        case 0: // Banner
            [self displayAdModally:YES];
            break;
        case 1: // Medium
            [self displayAdModally:YES];
            break;
        case 2: { // Leaderboard
            [self displayAdModally:NO];
            break;
        }
        case 3: { // Interstitial
            self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
            [self.interstitialAd prepareCustomMarkupFrom:self.markup.text];
            break;
        }
    }
}

-(void) displayAdModally:(BOOL)modal {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Markup" bundle:[NSBundle mainBundle]];
    PNLiteDemoMarkupDetailViewController *markupDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"MarkupDetailViewController"];
    markupDetailVC.markup = self.markup;
    if (modal) {
        [self.navigationController presentViewController:markupDetailVC animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:markupDetailVC animated:YES];
    }
}

- (void)invokeDidFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    NSString *adString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([adString length] == 0) {
        [self showAlertControllerWithMessage:@"No content for the Creative ID received"];
        return;
    }
    
    self.markup = [[Markup alloc] initWithMarkupText:adString withAdPlacement: [NSNumber numberWithInteger:[self.adSizeSegmentedControl selectedSegmentIndex]]];
    [self displayAd];
    self.debugButton.hidden = NO;
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
    self.debugButton.hidden = NO;
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    [self.interstitialAd show];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
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

@end
