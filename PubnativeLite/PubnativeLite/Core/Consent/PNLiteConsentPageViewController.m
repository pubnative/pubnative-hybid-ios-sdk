// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteConsentPageViewController.h"
#import "HyBidUserDataManager.h"
#import <WebKit/WebKit.h>

typedef void(^PNLiteConsentPageViewControllerCompletion)(BOOL success, NSError *error);

NSString *const PNLiteConsentAccept = @"https://cdn.pubnative.net/static/consent/GDPR-consent-dialog-accept.html";
NSString *const PNLiteConsentReject = @"https://cdn.pubnative.net/static/consent/GDPR-consent-dialog-reject.html";
NSString *const PNLiteConsentClose = @"https://pubnative.net/";

@interface PNLiteConsentPageViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
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
    if ([NSThread isMainThread]) {
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        });
    }
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
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

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!self.finishedInitialLoad) {
        self.finishedInitialLoad = YES;
        
        if (self.didLoadCompletionBlock) {
            self.didLoadCompletionBlock(YES, nil);
            self.didLoadCompletionBlock = nil;
        }
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (!self.finishedInitialLoad) {
        self.finishedInitialLoad = YES;
        
        if (self.didLoadCompletionBlock) {
            self.didLoadCompletionBlock(NO, error);
            self.didLoadCompletionBlock = nil;
        }
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = [navigationAction.request URL];
    NSString *absoluteUrlString = [url absoluteString];
    
    if ([absoluteUrlString isEqualToString:PNLiteConsentAccept]) {
        [[HyBidUserDataManager sharedInstance] grantConsent];
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([absoluteUrlString isEqualToString:PNLiteConsentReject]) {
        [[HyBidUserDataManager sharedInstance] denyConsent];
        decisionHandler(WKNavigationActionPolicyAllow);
    } else if ([absoluteUrlString isEqualToString:PNLiteConsentClose]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(consentPageViewControllerDidDismiss:)]) {
                [self.delegate consentPageViewControllerDidDismiss:self];
            }
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
