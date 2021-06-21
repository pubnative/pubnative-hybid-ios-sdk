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

#import "PNLiteDemoBaseViewController.h"
#import "PNLiteRequestInspector.h"
#if DEBUG
#import "FLEXManager.h"
#endif

@interface PNLiteDemoBaseViewController ()

@end

@implementation PNLiteDemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *flexButton =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gearIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFLEX)];
    [self.navigationItem setRightBarButtonItem:flexButton];
}

- (void)toggleFLEX {
#if DEBUG
    [[FLEXManager sharedManager] toggleExplorer];
#endif
}

- (void)requestAd {
    
}

- (void)clearLastInspectedRequest {
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:@"No request URL available..."  withResponse:@"No response available..." withLatency:nil];
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"I have a bad feeling about this... 🙄"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestAd];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reportEvent:(NSString *)eventType adFormat:(NSString *)adFormat properties:(NSDictionary<NSString *,NSString *> *)properties {
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:eventType adFormat:adFormat properties:properties];
    [[HyBid reportingManager]reportEventFor:reportingEvent];
}

@end
