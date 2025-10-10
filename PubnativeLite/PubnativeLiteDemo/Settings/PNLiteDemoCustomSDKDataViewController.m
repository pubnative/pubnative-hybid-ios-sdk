// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteDemoCustomSDKDataViewController.h"
#import <HyBid/HyBid.h>

@interface PNLiteDemoCustomSDKDataViewController ()

@end

@implementation PNLiteDemoCustomSDKDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Custom SDK Data";
    NSString* customSDKData = [HyBid getCustomRequestSignalData: @"m"];
    NSString* encodedCustomSDKData = [HyBid getEncodedCustomRequestSignalData: @"m"];
    NSString* sdkVersionInfo = [HyBid getSDKVersionInfo];

    self.customSDKDataTextView.text = [NSString stringWithFormat:@"SDK Version Info:\n%@\n\nCustom Request Signal Data:\n%@\n\nEncoded Custom Request Signal Data:\n%@", sdkVersionInfo, customSDKData, encodedCustomSDKData];
}

@end
