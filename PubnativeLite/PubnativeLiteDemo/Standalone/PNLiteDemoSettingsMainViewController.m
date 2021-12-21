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

#import "PNLiteDemoSettingsMainViewController.h"

#define GAD_APP_ID @"ca-app-pub-8741261465579918~3720290336"

@interface PNLiteDemoSettingsMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *demoAppVersionLabel;

@end

@implementation PNLiteDemoSettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.demoAppVersionLabel.text = [NSString stringWithFormat:@"HyBid Demo App v: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    self.demoAppVersionLabel.accessibilityValue = [NSString stringWithFormat:@"HyBid Demo App v: %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (IBAction)googleMediationTestSuiteTouchUpInside:(UIButton *)sender {
//    The presentWithAppID: method marked as deprecated from Google but still works and shows relevant information comparing to the presentForAdManagerOnViewController:
    [GoogleMobileAdsMediationTestSuite presentWithAppID:GAD_APP_ID onViewController:self delegate:nil];
//    [GoogleMobileAdsMediationTestSuite presentForAdManagerOnViewController:self delegate:nil];
}

@end
