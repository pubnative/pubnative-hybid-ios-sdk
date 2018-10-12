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

#import "PNLiteConsentPageViewController.h"
#import "HyBidUserDataManager.h"

NSString *const kPNLiteConsentAccept = @"https://pubnative.net/personalize-experience-yes/";
NSString *const kPNLiteConsentReject = @"https://pubnative.net/personalize-experience-no/";
NSString *const kPNLiteConsentClose = @"https://pubnative.net/";

@interface PNLiteConsentPageViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PNLiteConsentPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadConsentPage];
}

- (void)loadConsentPage
{
    NSURL *url = [NSURL URLWithString:[[HyBidUserDataManager sharedInstance] consentPageLink]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *absoluteUrlString = [url absoluteString];
    
    if ([absoluteUrlString isEqualToString:kPNLiteConsentAccept]) {
        [[HyBidUserDataManager sharedInstance] grantConsent];
    } else if ([absoluteUrlString isEqualToString:kPNLiteConsentReject]) {
        [[HyBidUserDataManager sharedInstance] denyConsent];
    } else if ([absoluteUrlString isEqualToString:kPNLiteConsentClose]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
    return YES;
}
@end
