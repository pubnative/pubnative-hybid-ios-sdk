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

#import "PNLiteDemoRequestInspectorViewController.h"
#import "PNLiteRequestInspector.h"

@interface PNLiteDemoRequestInspectorViewController ()

@property (weak, nonatomic) IBOutlet UITextView *requestTextView;
@property (weak, nonatomic) IBOutlet UITextView *latencyTextView;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end

@implementation PNLiteDemoRequestInspectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Request Inspector";
    self.requestTextView.text = [PNLiteRequestInspector sharedInstance].lastInspectedRequest.url;
    self.latencyTextView.text = [NSString stringWithFormat:@"%@",[PNLiteRequestInspector sharedInstance].lastInspectedRequest.latency];
    self.responseTextView.text = [PNLiteRequestInspector sharedInstance].lastInspectedRequest.response;
}

- (void)viewDidLayoutSubviews {
    [self.requestTextView setContentOffset:CGPointZero animated:NO];
    [self.latencyTextView setContentOffset:CGPointZero animated:NO];
    [self.responseTextView setContentOffset:CGPointZero animated:NO];
}

- (IBAction)dismissButtonTouchUpInside:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
