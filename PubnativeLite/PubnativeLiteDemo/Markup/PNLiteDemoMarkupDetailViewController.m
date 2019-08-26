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

#import "PNLiteDemoMarkupDetailViewController.h"

@interface PNLiteDemoMarkupDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *markupContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markupContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markupContainerHeightConstraint;

@end

@implementation PNLiteDemoMarkupDetailViewController

- (void)dealloc {
    self.markup = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch ([self.markup.placement integerValue]) {
        case 0: {
            self.markupContainerWidthConstraint.constant = 320;
            self.markupContainerHeightConstraint.constant = 50;
            break;
        }
        case 1: {
            self.markupContainerWidthConstraint.constant = 300;
            self.markupContainerHeightConstraint.constant = 250;
            break;
        }
        case 2: {
            self.markupContainerWidthConstraint.constant = 728;
            self.markupContainerHeightConstraint.constant = 90;
            break;
        }
        default:
            break;
    }
        [self.markupContainer addSubview:[self createMRAIDViewWithMarkup:self.markup
                                                               withWidth:self.markupContainerWidthConstraint.constant
                                                              withHeight:self.markupContainerHeightConstraint.constant
                                                          isInterstitial:NO]];
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
