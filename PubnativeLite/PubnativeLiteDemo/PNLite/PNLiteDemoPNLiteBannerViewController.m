//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "PNLiteDemoPNLiteBannerViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteBannerViewController () <HyBidAdViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerLoaderIndicator;
@property (weak, nonatomic) IBOutlet HyBidAdView *bannerAdView;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIPickerView *bannerSizePickerView;

@end

@implementation PNLiteDemoPNLiteBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HyBid Banner";
    [self.bannerLoaderIndicator stopAnimating];
}

- (IBAction)requestBannerTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.bannerAdView.hidden = YES;
    self.bannerHeightConstraint.constant = [PNLiteDemoSettings sharedInstance].adSize.height;
    self.bannerWidthConstraint.constant = [PNLiteDemoSettings sharedInstance].adSize.width;
    self.inspectRequestButton.hidden = YES;
    [self.bannerLoaderIndicator startAnimating];
    self.bannerAdView.adSize = [PNLiteDemoSettings sharedInstance].adSize;
    [self.bannerAdView loadWithZoneID:[PNLiteDemoSettings sharedInstance].zoneID andWithDelegate:self];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [PNLiteDemoSettings sharedInstance].bannerSizesArray.count;
}

#pragma mark UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    if ([[[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row] isKindOfClass:[NSString class]]) {
        [pickerLabel setText:[NSString stringWithFormat:@"%@",[PNLiteDemoSettings sharedInstance].bannerSizesArray[row]]];
    } else {
        HyBidAdSize structValue;
        NSValue *value = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        [value getValue:&structValue];
        [pickerLabel setText:[NSString stringWithFormat:@"%ldx%ld",structValue.width, structValue.height]];
    }
    return pickerLabel;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([[[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row] isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@",[PNLiteDemoSettings sharedInstance].bannerSizesArray[row]];
    } else {
        HyBidAdSize structValue;
        NSValue *value = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        [value getValue:&structValue];
        return [NSString stringWithFormat:@"%ldx%ld",structValue.width, structValue.height];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([[[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row] isKindOfClass:[NSString class]]) {
        self.loadAdButton.hidden = YES;
        self.bannerAdView.hidden = YES;
    } else {
        self.loadAdButton.hidden = NO;
        self.bannerAdView.hidden = NO;
        
        HyBidAdSize structValue;
        NSValue *value = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        [value getValue:&structValue];
        [PNLiteDemoSettings sharedInstance].adSize = structValue;
    }
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did load:");
    self.bannerAdView.hidden = NO;
    self.inspectRequestButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"Banner Ad View did fail with error: %@",error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
    [self.bannerLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"Banner Ad View did track impression:");
}

@end
