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

typedef void(^PNLiteConsentPageViewControllerCompletion)(BOOL success, NSError *error);

NSString *const kPNLiteConsentAccept = @"https://pubnative.net/personalize-experience-yes/";
NSString *const kPNLiteConsentReject = @"https://pubnative.net/personalize-experience-no/";
NSString *const kPNLiteConsentClose = @"https://pubnative.net/";

@interface PNLiteConsentPageViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL finishedInitialLoad;
@property (nonatomic, copy) PNLiteConsentPageViewControllerCompletion didLoadCompletionBlock;
@property (nonatomic, copy) NSString *consentPageURL;

@end

@implementation PNLiteConsentPageViewController

#pragma mark - Initialization

- (instancetype)initWithConsentPageURL:(NSString *)consentPageURL {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _consentPageURL = consentPageURL;
        [self setUpWebView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self layoutWebView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(consentPageViewControllerWillDisappear:)]) {
        [self.delegate consentPageViewControllerWillDisappear:self];
    }
}

- (void)setUpWebView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)layoutWebView {
    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];
    
    // Set up autolayout constraints on iOS 11+. This web view should always stay within the safe area.
    if (@available(iOS 11.0, *)) {
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                                  [self.webView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                                  [self.webView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                                  [self.webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
                                                  ]];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Load Consent Page

- (void)loadConsentPageWithCompletion:(PNLiteConsentPageViewControllerCompletion)completion {
    self.finishedInitialLoad = NO;
    self.didLoadCompletionBlock = completion;
    NSURL *url = [NSURL URLWithString:self.consentPageURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.finishedInitialLoad) {
        self.finishedInitialLoad = YES;
        
        if (self.didLoadCompletionBlock) {
            self.didLoadCompletionBlock(YES, nil);
            self.didLoadCompletionBlock = nil;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!self.finishedInitialLoad) {
        self.finishedInitialLoad = YES;
        
        if (self.didLoadCompletionBlock) {
            self.didLoadCompletionBlock(NO, error);
            self.didLoadCompletionBlock = nil;
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    NSString *absoluteUrlString = [url absoluteString];
    
    if ([absoluteUrlString isEqualToString:kPNLiteConsentAccept]) {
        [[HyBidUserDataManager sharedInstance] grantConsent];
    } else if ([absoluteUrlString isEqualToString:kPNLiteConsentReject]) {
        [[HyBidUserDataManager sharedInstance] denyConsent];
    } else if ([absoluteUrlString isEqualToString:kPNLiteConsentClose]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(consentPageViewControllerDidDismiss:)]) {
                [self.delegate consentPageViewControllerDidDismiss:self];
            }
        }];
        return NO;
    } else {
        return YES;
    }
    return YES;
}
@end
