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

#import "PNLiteDemoPNLiteBannerSizeSelectionViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "PNLiteDemoPNLiteBannerViewController.h"

@interface PNLiteDemoPNLiteBannerSizeSelectionViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIPickerView *bannerSizePickerView;

@end

@implementation PNLiteDemoPNLiteBannerSizeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Banner Size Selection";

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
        HyBidAdSize *adSize = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        [pickerLabel setText:[NSString stringWithFormat:@"%ldx%ld",adSize.width, adSize.height]];
    }
    return pickerLabel;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([[[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row] isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@",[PNLiteDemoSettings sharedInstance].bannerSizesArray[row]];
    } else {
        HyBidAdSize *adSize = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        return [NSString stringWithFormat:@"%ldx%ld",adSize.width, adSize.height];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([[[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row] isKindOfClass:[NSString class]]) {
        self.continueButton.hidden = YES;
    } else {
        self.continueButton.hidden = NO;
        HyBidAdSize *adSize = [[PNLiteDemoSettings sharedInstance].bannerSizesArray objectAtIndex:row];
        [PNLiteDemoSettings sharedInstance].adSize = adSize;
    }
}

@end
