// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoPNLiteStickyBannerSizeSelectionViewController.h"

#import "PNLiteDemoSettings.h"
#import "PNLiteDemoPNLiteBannerViewController.h"

@interface PNLiteDemoPNLiteStickyBannerSizeSelectionViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIPickerView *bannerSizePickerView;

@end

@implementation PNLiteDemoPNLiteStickyBannerSizeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Sticky Banner Size Selection";
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
