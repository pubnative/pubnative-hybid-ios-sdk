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

#import "PNLiteBrowser.h"
#import "PNLiteLogger.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// Features
NSString * const kPNLiteBrowserFeatureDisableStatusBar = @"disableStatusBar";
NSString * const kPNLiteBrowserFeatureScalePagesToFit = @"scalePagesToFit";
NSString * const kPNLiteBrowserFeatureSupportInlineMediaPlayback = @"supportInlineMediaPlayback";
NSString * const kPNLiteBrowserTelPrefix = @"tel://";

@interface PNLiteBrowser () <UIWebViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    PNLiteBrowserControlsView *browserControlsView;
    NSURLRequest *currrentRequest;
    UIViewController *currentViewController;
    NSArray *pubnativeBrowserFeatures;
    UIWebView *browserWebView;
    UIActivityIndicatorView *loadingIndicator;
    BOOL disableStatusBar;
    BOOL scalePagesToFit;
    BOOL statusBarHidden;
    BOOL supportInlineMediaPlayback;
}

@end

@implementation PNLiteBrowser

#pragma mark - Init & dealloc

// designated initializer
- (id)initWithDelegate:(id<PNLiteBrowserDelegate>)delegate withFeatures:(NSArray *)p_pubnativeBrowserFeatures
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _delegate = delegate;
        pubnativeBrowserFeatures = p_pubnativeBrowserFeatures;
        
        if (p_pubnativeBrowserFeatures != nil && [p_pubnativeBrowserFeatures count] > 0)
        {
            for (NSString *feature in p_pubnativeBrowserFeatures)
            {
                if ([feature isEqualToString:kPNLiteBrowserFeatureDisableStatusBar]) {
                    disableStatusBar = YES;
                }
                else if ([feature isEqualToString:kPNLiteBrowserFeatureSupportInlineMediaPlayback]) {
                    supportInlineMediaPlayback = YES;
                }
                else if ([feature isEqualToString:kPNLiteBrowserFeatureScalePagesToFit]) {
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithNibName:bundle: is not a valid initializer for the class PubnativeBrowser"
                                 userInfo:nil];
    return nil;
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!browserWebView) {
        browserWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
        browserWebView.delegate = self;
        browserWebView.scalesPageToFit = scalePagesToFit;
        browserWebView.allowsInlineMediaPlayback = supportInlineMediaPlayback;
        browserWebView.mediaPlaybackRequiresUserAction = NO;
        browserWebView.autoresizesSubviews=YES;
        browserWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:browserWebView];
        browserControlsView = [[PNLiteBrowserControlsView  alloc] initWithPubnativeBrowser:self];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    if (disableStatusBar && SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (disableStatusBar && SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationNone];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return disableStatusBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

#pragma mark - PubnativeBrowser public methods

- (void)loadRequest:(NSURLRequest *)request
{
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

- (void)getTelPermission:(NSString *)telString
{
    if ([self.delegate respondsToSelector:@selector(pubnativeTelPopupOpen:)]) {
        [self.delegate pubnativeTelPopupOpen:self];
    }
    
    telString = [telString stringByReplacingOccurrencesOfString:kPNLiteBrowserTelPrefix withString:@""];
    
    UIAlertView *telPermissionAlert = [[UIAlertView alloc] initWithTitle:telString
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Call",nil];
    
    [telPermissionAlert show];
}

#pragma mark - Telephone call permission AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonLabel = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([self.delegate respondsToSelector:@selector(pubnativeTelPopupClosed:)]) {
        [self.delegate pubnativeTelPopupClosed:self];
    }

    if([buttonLabel isEqualToString:@"Call"])
    {
        // Notify listener
        if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
            [self.delegate pubnativeBrowserWillExitApp:self];
        }
        
        // Parse phone number and dial
        NSString *toCall = [kPNLiteBrowserTelPrefix stringByAppendingString:alertView.title];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:toCall]];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSString *absUrlString = [url absoluteString];
    
    // Ignore about:blank
    if (![absUrlString isEqualToString:@"about:blank"]) {
        
        BOOL openSystemBrowserDirectly = NO;
        if ([absUrlString hasPrefix:@"tel"]) {
            [self getTelPermission:absUrlString];
            return NO;
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
                return NO;
            } else {
                [self dismiss];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    browserControlsView.backButton.enabled = [webView canGoBack];
    browserControlsView.forwardButton.enabled = [webView canGoForward];
    [loadingIndicator stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [loadingIndicator startAnimating];
}

#pragma mark -
#pragma mark PubnativeBrowserControlsView actions

- (void)back
{
    if([browserWebView canGoBack]) {
        [browserWebView goBack];
    }
}

- (void)dismiss
{
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

- (void)forward
{
    if([browserWebView canGoForward]) {
        [browserWebView goForward];
    }
}

#define ACTION_SHEET_TOOLBAR_ACTION 32000
- (void)launchSafari
{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Launch Safari",nil];
        actionSheet.tag = ACTION_SHEET_TOOLBAR_ACTION;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
}

- (void)refresh
{
     [browserWebView reload];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
    
#define ACTION_LAUNCH_SAFARI 0
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == ACTION_SHEET_TOOLBAR_ACTION) {
        if (buttonIndex == 0) {
            NSURL *currentRequestURL = [browserWebView.request URL];
            if ([self.delegate respondsToSelector:@selector(pubnativeBrowserWillExitApp:)]) {
                [self.delegate pubnativeBrowserWillExitApp:self];
            }
            [self dismiss];
            [[UIApplication sharedApplication] openURL:currentRequestURL];
        }
    }
}

@end
