//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidJSBeaconLoader.h"
#import <WebKit/WebKit.h>

static NSTimeInterval const HyBidJSBeaconLoaderTimeout = 10.0;

@interface HyBidJSBeaconLoader () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) void (^completion)(NSError * _Nullable error);

@end

@implementation HyBidJSBeaconLoader

+ (void)loadBeacon:(NSString *)payload completion:(void (^)(NSError * _Nullable error))completion {
    HyBidJSBeaconLoader *loader = [HyBidJSBeaconLoader new];
    loader.completion = completion;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[WKWebViewConfiguration new]];
    webView.navigationDelegate = loader;
    loader.webView = webView;
    NSString *html = [NSString stringWithFormat:@"<html><body>%@</body></html>", payload];
    // Non-nil origin so protocol-relative "//host" URLs resolve, same as HyBidMRAIDView.
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://example.com"]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(HyBidJSBeaconLoaderTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loader finishWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]];
    });
}

- (void)finishWithError:(NSError * _Nullable)error {
    void (^completion)(NSError * _Nullable) = self.completion;
    if (!completion) { return; }
    self.completion = nil;
    self.webView.navigationDelegate = nil;
    completion(error);
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self finishWithError:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self finishWithError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self finishWithError:error];
}

@end
