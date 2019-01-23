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

#import "HyBidBrowser.h"
#import "PNLiteLogger.h"
#import "UIApplication+PNLiteTopViewController.h"
#import <WebKit/WebKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// Features
NSString * const PNLiteBrowserFeatureDisableStatusBar = @"disableStatusBar";
NSString * const PNLiteBrowserFeatureScalePagesToFit = @"scalePagesToFit";
NSString * const PNLiteBrowserFeatureSupportInlineMediaPlayback = @"supportInlineMediaPlayback";
NSString * const PNLiteBrowserTelPrefix = @"tel://";

@interface HyBidBrowser () <WKNavigationDelegate> {
    HyBidBrowserControlsView *browserControlsView;
    NSURLRequest *currrentRequest;
    UIViewController *currentViewController;
    NSArray *pubnativeBrowserFeatures;
    WKWebView *browserWebView;
    UIActivityIndicatorView *loadingIndicator;
    BOOL disableStatusBar;
    BOOL scalePagesToFit;
    BOOL statusBarHidden;
    BOOL supportInlineMediaPlayback;
}

@end

@implementation HyBidBrowser

#pragma mark - Init & dealloc

// designated initializer
- (id)initWithDelegate:(id<HyBidBrowserDelegate>)delegate withFeatures:(NSArray *)p_pubnativeBrowserFeatures {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _delegate = delegate;
        pubnativeBrowserFeatures = p_pubnativeBrowserFeatures;
        
        if (p_pubnativeBrowserFeatures != nil && [p_pubnativeBrowserFeatures count] > 0)
        {
            for (NSString *feature in p_pubnativeBrowserFeatures)
            {
                if ([feature isEqualToString:PNLiteBrowserFeatureDisableStatusBar]) {
                    disableStatusBar = YES;
                }
                else if ([feature isEqualToString:PNLiteBrowserFeatureSupportInlineMediaPlayback]) {
                    supportInlineMediaPlayback = YES;
                }
                else if ([feature isEqualToString:PNLiteBrowserFeatureScalePagesToFit]) {
                    scalePagesToFit = YES;
                }
                
                [PNLiteLogger debug:@"PNBrowser" withMessage:[NSString stringWithFormat:@"Requesting PubnativeBrowser feature: %@", feature]];
            }
        }
    }
    return self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class PubnativeBrowser"
                                 userInfo:nil];
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithNibName:bundle: is not a valid initializer for the class PubnativeBrowser"
                                 userInfo:nil];
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!browserWebView) {
        WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
        webConfiguration.allowsInlineMediaPlayback = supportInlineMediaPlayback;
        webConfiguration.requiresUserActionForMediaPlayback = NO;
        if (scalePagesToFit) {
            NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
            WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            WKUserContentController *wkUController = [[WKUserContentController alloc] init];
            [wkUController addUserScript:wkUScript];
            webConfiguration.userContentController = wkUController;
        }
        browserWebView = [[WKWebView alloc] initWithFrame: self.view.bounds configuration:webConfiguration];
        browserWebView.navigationDelegate = self;
        browserWebView.autoresizesSubviews = YES;
        browserWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:browserWebView];
        browserControlsView = [[HyBidBrowserControlsView  alloc] initWithPubnativeBrowser:self];
        browserControlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;
        
        // screenSize is ALWAYS for portrait orientation, so we need to figure out the
        // actual interface orientation.
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            browserControlsView.frame  = CGRectMake(0, self.view.frame.size.height-browserControlsView.frame.size.height, self.view.frame.size.width,browserControlsView.frame.size.height);
        } else {
            if (isLandscape) {
                browserControlsView.frame  = CGRectMake(0, self.view.frame.size.width-browserControlsView.frame.size.width, self.view.frame.size.height,browserControlsView.frame.size.width);
            } else {
                browserControlsView.frame  = CGRectMake(0, self.view.frame.size.height-browserControlsView.frame.size.height, self.view.frame.size.width,browserControlsView.frame.size.height);
            }
        }
        
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.frame = CGRectMake(0,0,30,30);
        loadingIndicator.hidesWhenStopped = YES;
        [browserControlsView.loadingIndicator.customView addSubview:loadingIndicator];
        [self.view addSubview:browserControlsView];
        [browserWebView loadRequest:currrentRequest];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return disableStatusBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

#pragma mark - PubnativeBrowser public methods

- (void)loadRequest:(NSURLRequest *)request {
    currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (currentViewController.presentedViewController) {
        currentViewController = currentViewController.presentedViewController;
    }
    
    self.view.frame = currentViewController.view.bounds;
    
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSString *absUrlString = [url absoluteString];
    
    BOOL openSystemBrowserDirectly = NO;
    if ([absUrlString hasPrefix:@"tel"]) {
        [self getTelPermission:absUrlString];
        return;
    } else if ([host isEqualToString:@"itunes.apple.com"] || [host isEqualToString:@"phobos.apple.com"] || [host isEqualToString:@"maps.google.com"]) {
        // Handle known URL hosts
        openSystemBrowserDirectly = YES;
    } else if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        // Deep Links
        openSystemBrowserDirectly = YES;
    }
    
    if (openSystemBrowserDirectly) {
        // Notify the callers that the app will exit
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
                [self.delegate pubnativeBrowserWillExitApp:self];
            }
            
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        currrentRequest = request;
        [PNLiteLogger debug:@"PNBrowser" withMessage:[NSString stringWithFormat:@"presenting browser from viewController: %@", currentViewController]];
        
        if ([currentViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            // used if running >= iOS 6
            [currentViewController presentViewController:self animated:YES completion:nil];
        } else {
            // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [currentViewController presentModalViewController:self animated:YES];
#pragma clang diagnostic pop
        }
    }
}

#pragma mark - Telephone call permission AlertView

- (void)getTelPermission:(NSString *)telString {
    if ([self.delegate respondsToSelector:@selector(pubnativeTelPopupOpen:)]) {
        [self.delegate pubnativeTelPopupOpen:self];
    }
    
    telString = [telString stringByReplacingOccurrencesOfString:PNLiteBrowserTelPrefix withString:@""];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:telString
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       if ([self.delegate respondsToSelector:@selector(pubnativeTelPopupClosed:)]) {
                                           [self.delegate pubnativeTelPopupClosed:self];
                                       }
                                   }];
    
    UIAlertAction *callAction = [UIAlertAction
                                 actionWithTitle:@"Call"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     if ([self.delegate respondsToSelector:@selector(pubnativeTelPopupClosed:)]) {
                                         [self.delegate pubnativeTelPopupClosed:self];
                                     }
                                     
                                     // Notify listener
                                     if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
                                         [self.delegate pubnativeBrowserWillExitApp:self];
                                     }
                                     
                                     // Parse phone number and dial
                                     NSString *toCall = [PNLiteBrowserTelPrefix stringByAppendingString:telString];
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:toCall]];
                                 }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:callAction];
    
    [[UIApplication sharedApplication].topViewController presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = [navigationAction.request URL];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSString *absUrlString = [url absoluteString];
    
    // Ignore about:blank
    if (![absUrlString isEqualToString:@"about:blank"]) {
        
        BOOL openSystemBrowserDirectly = NO;
        if ([absUrlString hasPrefix:@"tel"]) {
            [self getTelPermission:absUrlString];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([host isEqualToString:@"itunes.apple.com"] || [host isEqualToString:@"phobos.apple.com"] || [host isEqualToString:@"maps.google.com"]) {
            // Handle known URL hosts
            openSystemBrowserDirectly = YES;
        } else if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
            // Deep Links
            openSystemBrowserDirectly = YES;
        }
        
        if (openSystemBrowserDirectly) {
            // Notify the callers that the app will exit
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
                    [self.delegate pubnativeBrowserWillExitApp:self];
                }
                [self dismiss];
                [[UIApplication sharedApplication] openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            } else {
                [self dismiss];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    browserControlsView.backButton.enabled = [webView canGoBack];
    browserControlsView.forwardButton.enabled = [webView canGoForward];
    [loadingIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [loadingIndicator startAnimating];
}

#pragma mark -
#pragma mark PubnativeBrowserControlsView actions

- (void)back {
    if([browserWebView canGoBack]) {
        [browserWebView goBack];
    }
}

- (void)dismiss {
    [PNLiteLogger debug:@"PNBrowser" withMessage:@"Dismissing PubnativeBrowser"];
    if ([self.delegate respondsToSelector:@selector(pubnativeBrowserClosed:)]) {
        [self.delegate pubnativeBrowserClosed:self];
    }
    
    self.delegate = nil;
    browserWebView = nil;
    browserControlsView = nil;
    currrentRequest = nil;
    loadingIndicator = nil;
    pubnativeBrowserFeatures = nil;
    
    [currentViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)forward {
    if([browserWebView canGoForward]) {
        [browserWebView goForward];
    }
}

- (void)launchSafari {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    UIAlertAction *launchSafariAction = [UIAlertAction
                                         actionWithTitle:@"Launch Safari"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             NSURL *currentRequestURL = browserWebView.URL;
                                             if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
                                                 [self.delegate pubnativeBrowserWillExitApp:self];
                                             }
                                             [self dismiss];
                                             [[UIApplication sharedApplication] openURL:currentRequestURL];
                                         }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:launchSafariAction];
    
    [[UIApplication sharedApplication].topViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)refresh {
    [browserWebView reload];
}

@end
