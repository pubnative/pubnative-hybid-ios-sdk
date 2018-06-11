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

#import "PNLiteDemoPNLiteMRectViewController.h"
#import <PubnativeLite/PubnativeLite.h>
#import "PNLiteDemoSettings.h"

@interface PNLiteDemoPNLiteMRectViewController () <PNLiteAdRequestDelegate, PNLiteMRectPresenterDelegate>

@property (weak, nonatomic) IBOutlet UIView *mRectContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (nonatomic, strong) PNLiteMRectAdRequest *mRectAdRequest;
@property (nonatomic, strong) PNLiteMRectPresenter *mRectPresenter;
@property (nonatomic, strong) PNLiteMRectPresenterFactory *mRectPresenterFactory;

@end

@implementation PNLiteDemoPNLiteMRectViewController

- (void)dealloc
{
    self.mRectAdRequest = nil;
    self.mRectPresenter = nil;
    self.mRectPresenterFactory = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"PNLite MRect";
    [self.mRectLoaderIndicator stopAnimating];
}

- (IBAction)requestMRectTouchUpInside:(id)sender
{
    self.mRectContainer.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    self.mRectAdRequest = [[PNLiteMRectAdRequest alloc] init];
    [self.mRectAdRequest requestAdWithDelegate:self withZoneID:[PNLiteDemoSettings sharedInstance].zoneID];
}

#pragma mark - PNLiteAdRequestDelegate

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
    
    if (request == self.mRectAdRequest) {
        self.mRectPresenterFactory = [[PNLiteMRectPresenterFactory alloc] init];
        self.mRectPresenter = [self.mRectPresenterFactory createMRectPresenterWithAd:ad withDelegate:self];
        if (self.mRectPresenter == nil) {
            NSLog(@"PubNativeLite - Error: Could not create valid mRect presenter");
            return;
        } else {
            [self.mRectPresenter load];
        }
    }
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"PNLite Demo"
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:dismissAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    if (request == self.mRectAdRequest) {
        [self.mRectLoaderIndicator stopAnimating];
    }
}

- (void)removeAllSubViewsFrom:(UIView *)view
{
    NSArray *viewsToRemove = [view subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

#pragma mark - PNLiteMRectPresenterDelegate

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didLoadWithMRect:(UIView *)mRect
{
    [self removeAllSubViewsFrom:self.mRectContainer];
    [self.mRectContainer addSubview:mRect];
    self.mRectContainer.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
}

- (void)mRectPresenter:(PNLiteMRectPresenter *)mRectPresenter didFailWithError:(NSError *)error
{
    NSLog(@"MRect Presenter %@ failed with error: %@",mRectPresenter,error.localizedDescription);
    [self.mRectLoaderIndicator stopAnimating];
}

- (void)mRectPresenterDidClick:(PNLiteMRectPresenter *)mRectPresenter
{
    NSLog(@"MRect Presenter %@ did click:",mRectPresenter);
}

@end
