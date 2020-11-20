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

#import "PNLiteDemoVASTTestingViewController.h"
#import "HyBidLogger.h"
#import "HyBid.h"

@interface PNLiteDemoVASTTestingViewController () <HyBidInterstitialAdDelegate>

@property (weak, nonatomic) IBOutlet UITextField *vastTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@property (nonatomic, strong) HyBidInterstitialAd *interstitialAd;

@end

@implementation PNLiteDemoVASTTestingViewController

- (void)viewDidLoad
{
    [self setupUI];
}

- (void)setupUI
{
    [self setTitle:@"VAST Testing"];
    [self.segmentedControl setTitle:@"Interstitial" forSegmentAtIndex:0];
    [self.segmentedControl setTitle:@"MRect" forSegmentAtIndex:1];
}

- (IBAction)loadButtonTapped:(UIButton *)sender {
    if ([[self.vastTextField text] isEqualToString:@""]) {
        NSLog(@"The field is empty!");
        return;
    }
    
    switch ([self.segmentedControl selectedSegmentIndex]) {
        case 0:
            [self loadVASTTag];
        case 1:
            NSLog(@"MRect is not set up yet.");
        default: break;
    }
}

- (void)loadVASTTag
{
    NSString *vastURL = [self.vastTextField text];
    if ([vastURL length] == 0) {
        NSError *error = [NSError errorWithDomain:@"Please input some vast adserver URL" code:0 userInfo:nil];
        [self invokeDidFail:error];
    } else {
        [self loadVASTTagDirectlyFrom:vastURL];
    }
}

- (void)loadVASTTagDirectlyFrom:(NSString *)url
{
    self.interstitialAd = [[HyBidInterstitialAd alloc] initWithZoneID:nil andWithDelegate:self];
    [self.interstitialAd prepareVideoTagFrom:url];
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    });
}

#pragma mark - HyBidInterstitialAdDelegate

- (void)interstitialDidLoad {
    NSLog(@"Interstitial did load");
    [self.interstitialAd show];
}

- (void)interstitialDidFailWithError:(NSError *)error {
    NSLog(@"Interstitial did fail with error: %@",error.localizedDescription);
    [self showAlertControllerWithMessage:error.localizedDescription];
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
