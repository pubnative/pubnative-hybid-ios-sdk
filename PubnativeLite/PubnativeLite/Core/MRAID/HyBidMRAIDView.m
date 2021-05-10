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

#import "HyBidMRAIDView.h"
#import "PNLiteMRAIDOrientationProperties.h"
#import "PNLiteMRAIDResizeProperties.h"
#import "PNLiteMRAIDParser.h"
#import "PNLiteMRAIDModalViewController.h"
#import "HyBidMRAIDServiceDelegate.h"
#import "PNLiteMRAIDUtil.h"
#import "PNLiteMRAIDSettings.h"
#import "HyBidViewabilityManager.h"
#import "HyBidViewabilityWebAdSession.h"
#import "HyBidLogger.h"
#import "PNLiteCloseButton.h"
#import "HyBidSettings.h"

#import <WebKit/WebKit.h>
#import <OMSDK_Pubnativenet/OMIDAdSession.h>

#define kCloseEventRegionSize 50
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

CGFloat const kContentInfoViewHeight = 15.0f;
CGFloat const kContentInfoViewWidth = 15.0f;

typedef enum {
    PNLiteMRAIDStateLoading,
    PNLiteMRAIDStateDefault,
    PNLiteMRAIDStateExpanded,
    PNLiteMRAIDStateResized,
    PNLiteMRAIDStateHidden
} PNLiteMRAIDState;

@interface HyBidMRAIDView () <WKNavigationDelegate, WKUIDelegate, PNLiteMRAIDModalViewControllerDelegate, UIGestureRecognizerDelegate, HyBidContentInfoViewDelegate>
{
    PNLiteMRAIDState state;
    // This corresponds to the MRAID placement type.
    BOOL isInterstitial;
    BOOL isAdSessionCreated;
    
    OMIDPubnativenetAdSession *adSession;
    
    // The only property of the MRAID expandProperties we need to keep track of
    // on the native side is the useCustomClose property.
    // The width, height, and isModal properties are not used in MRAID v2.0.
    BOOL useCustomClose;
    
    NSInteger _skipOffset;
    
    PNLiteMRAIDOrientationProperties *orientationProperties;
    PNLiteMRAIDResizeProperties *resizeProperties;
    
    PNLiteMRAIDParser *mraidParser;
    PNLiteMRAIDModalViewController *modalVC;
    
    NSString *omSDKjs;
    
    NSURL *baseURL;
    
    NSArray *mraidFeatures;
    NSArray *supportedFeatures;
    
    WKWebView *webView;
    WKWebView *webViewPart2;
    WKWebView *currentWebView;
    
    UIButton *closeEventRegion;
    
    UIView *resizeView;
    UIButton *resizeCloseRegion;
    
    UIView *contentInfoViewContainer;
    HyBidContentInfoView *contentInfoView;
    
    CGSize previousMaxSize;
    CGSize previousScreenSize;
    
    UITapGestureRecognizer *tapGestureRecognizer;
    BOOL bonafideTapObserved;
    
    CGFloat adWidth;
    CGFloat adHeight;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification;

- (void)addCloseEventRegion;
- (void)showResizeCloseRegion;
- (void)removeResizeCloseRegion;
- (void)setResizeViewPosition;
- (void)addContentInfoViewToView:(UIView *)view;


// These methods provide the means for native code to talk to JavaScript code.
- (void)injectJavaScript:(NSString *)js;
// convenience methods to fire MRAID events
- (void)fireErrorEventWithAction:(NSString *)action message:(NSString *)message;
- (void)fireReadyEvent;
- (void)fireSizeChangeEvent;
- (void)fireStateChangeEvent;
- (void)fireViewableChangeEvent;
// setters
- (void)setDefaultPosition;
- (void)setMaxSize;
- (void)setScreenSize;

// internal helper methods
- (void)initWebView:(WKWebView *)wv;
- (void)parseCommandUrl:(NSString *)commandUrlString;

@end

@implementation HyBidMRAIDView

@synthesize isViewable=_isViewable;
@synthesize rootViewController = _rootViewController;

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithFrame is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithCoder is not a valid initializer for the class MRAIDView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString *)htmlData
        withBaseURL:(NSURL *)bsURL
  supportedFeatures:(NSArray *)features
      isInterstital:(BOOL)isInterstitial
           delegate:(id<HyBidMRAIDViewDelegate>)delegate
    serviceDelegate:(id<HyBidMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController
        contentInfo:(HyBidContentInfoView *)contentInfo
         skipOffset:(NSInteger)skipOffset {
    return [self initWithFrame:frame
                  withHtmlData:htmlData
                   withBaseURL:bsURL
                asInterstitial:isInterstitial
             supportedFeatures:features
                      delegate:delegate
               serviceDelegate:serviceDelegate
            rootViewController:rootViewController
                   contentInfo:contentInfo
                    skipOffset:skipOffset];
}

// designated initializer
- (id)initWithFrame:(CGRect)frame
       withHtmlData:(NSString*)htmlData
        withBaseURL:(NSURL*)bsURL
     asInterstitial:(BOOL)isInter
  supportedFeatures:(NSArray *)currentFeatures
           delegate:(id<HyBidMRAIDViewDelegate>)delegate
    serviceDelegate:(id<HyBidMRAIDServiceDelegate>)serviceDelegate
 rootViewController:(UIViewController *)rootViewController
        contentInfo:(HyBidContentInfoView *)contentInfo
         skipOffset:(NSInteger)skipOffset {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpTapGestureRecognizer];
        isInterstitial = isInter;
        adWidth = frame.size.width;
        adHeight = frame.size.height;
        _delegate = delegate;
        _serviceDelegate = serviceDelegate;
        _rootViewController = rootViewController;
        
        state = PNLiteMRAIDStateLoading;
        _isViewable = NO;
        useCustomClose = NO;
        _skipOffset = skipOffset;

        orientationProperties = [[PNLiteMRAIDOrientationProperties alloc] init];
        resizeProperties = [[PNLiteMRAIDResizeProperties alloc] init];
        
        contentInfoView = contentInfo;
        
        mraidParser = [[PNLiteMRAIDParser alloc] init];
        
        mraidFeatures = @[
                          PNLiteMRAIDSupportsSMS,
                          PNLiteMRAIDSupportsTel,
                          PNLiteMRAIDSupportsStorePicture,
                          PNLiteMRAIDSupportsInlineVideo,
                          ];
        
        
        if([self isValidFeatureSet:currentFeatures] && serviceDelegate) {
            supportedFeatures=currentFeatures;
        }
        
        webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) configuration:[self createConfiguration]];
        [self initWebView:webView];
        currentWebView = webView;
        [self addSubview:webView];
        
        previousMaxSize = CGSizeZero;
        previousScreenSize = CGSizeZero;
        
        [self addObserver:self forKeyPath:@"self.frame" options:NSKeyValueObservingOptionOld context:NULL];
        
        baseURL = bsURL;
        state = PNLiteMRAIDStateLoading;
        
        omSDKjs = [[HyBidViewabilityManager sharedInstance] getOMIDJS];
        if (omSDKjs) {
            [self injectJavaScript:omSDKjs];
        }
        
        if (baseURL != nil && [[baseURL absoluteString] length]!= 0) {
            __block NSString *htmlData = htmlData;
            [self htmlFromUrl:baseURL handler:^(NSString *html, NSError *error) {
                htmlData = [PNLiteMRAIDUtil processRawHtml:html];
                [self loadHTMLData:htmlData];
            }];
        } else {
            htmlData = [PNLiteMRAIDUtil processRawHtml:htmlData];
            [self loadHTMLData:htmlData];
        }
        
        if (isInter) {
            bonafideTapObserved = YES;  // no autoRedirect suppression for Interstitials
        }
    }
    return self;
}

- (void)htmlFromUrl:(NSURL *)url handler:(void (^)(NSString *html, NSError *error))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error;
        NSString *html = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (handler)
                handler(html, error);
        });
    });
}

- (void)loadHTMLData:(NSString *)htmlData {
    if (htmlData) {
        [currentWebView loadHTMLString:htmlData baseURL:baseURL];
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Ad HTML is invalid, cannot load."];
        if ([self.delegate respondsToSelector:@selector(mraidViewAdFailed:)]) {
            [self.delegate mraidViewAdFailed:self];
        }
    }
}

- (void)cancel {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"cancel"];
    [currentWebView stopLoading];
    currentWebView = nil;
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)dealloc {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    
    [self removeObserver:self forKeyPath:@"self.frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    
    webView = nil;
    webViewPart2 = nil;
    currentWebView = nil;
    
    mraidParser = nil;
    modalVC = nil;
    
    orientationProperties = nil;
    resizeProperties = nil;
    
    mraidFeatures = nil;
    supportedFeatures = nil;
    
    closeEventRegion = nil;
    resizeView = nil;
    resizeCloseRegion = nil;
    
    contentInfoViewContainer = nil;
    contentInfoView = nil;
    
    self.delegate = nil;
    self.serviceDelegate =nil;
}

- (BOOL)isValidFeatureSet:(NSArray *)features {
    NSArray *kFeatures = @[
                           PNLiteMRAIDSupportsSMS,
                           PNLiteMRAIDSupportsTel,
                           PNLiteMRAIDSupportsStorePicture,
                           PNLiteMRAIDSupportsInlineVideo,
                           ];
    
    // Validate the features set by the user
    for (id feature in features) {
        if (![kFeatures containsObject:feature]) {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"feature %@ is unknown, no supports set.", feature]];
            return NO;
        }
    }
    return YES;
}

- (void)setIsViewable:(BOOL)newIsViewable {
    if(newIsViewable!=_isViewable) {
        _isViewable=newIsViewable;
        [self fireViewableChangeEvent];
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"isViewable: %@", _isViewable?@"YES":@"NO"]];
}

- (BOOL)isViewable {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    return _isViewable;
}

- (void)setRootViewController:(UIViewController *)newRootViewController {
    if(newRootViewController!=_rootViewController) {
        _rootViewController=newRootViewController;
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"setRootViewController: %@", _rootViewController]];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    @synchronized (self) {
        [self setScreenSize];
        [self setMaxSize];
        [self setDefaultPosition];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!([keyPath isEqualToString:@"self.frame"])) {
        return;
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"self.frame has changed."];
    
    CGRect oldFrame = CGRectNull;
    CGRect newFrame = CGRectNull;
    if (change[@"old"] != [NSNull null]) {
        oldFrame = [change[@"old"] CGRectValue];
    }
    if ([object valueForKeyPath:keyPath] != [NSNull null]) {
        newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"old %@", NSStringFromCGRect(oldFrame)]];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"new %@", NSStringFromCGRect(newFrame)]];
    
    if (state == PNLiteMRAIDStateResized) {
        [self setResizeViewPosition];
    }
    [self setDefaultPosition];
    [self setMaxSize];
    [self fireSizeChangeEvent];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    currentWebView.backgroundColor = backgroundColor;
}

#pragma mark - interstitial support

- (void)showAsInterstitial {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self expand:nil supportVerve:NO];
    [self setIsViewable:YES];
}

- (void)showAsInterstitialFromViewController:(UIViewController *)viewController {
    [self setRootViewController:viewController];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self expand:nil supportVerve:NO];
    [self setIsViewable:YES];
}

- (void)hide {
    [self close];
}

#pragma mark - HyBidContentInfoViewDelegate

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width {
    contentInfoViewContainer.layer.frame = CGRectMake(contentInfoViewContainer.frame.origin.x, contentInfoViewContainer.frame.origin.y, [width floatValue], contentInfoViewContainer.frame.size.height);
}

#pragma mark - JavaScript --> native support

// These methods are (indirectly) called by JavaScript code.
// They provide the means for JavaScript code to talk to native code

- (void)close {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
    
    if (state == PNLiteMRAIDStateLoading ||
        (state == PNLiteMRAIDStateDefault && !isInterstitial) ||
        state == PNLiteMRAIDStateHidden) {
        // do nothing
        return;
    }
    
    if (state == PNLiteMRAIDStateResized) {
        [self closeFromResize];
        return;
    }
    
    if (modalVC) {
        [closeEventRegion removeFromSuperview];
        closeEventRegion = nil;
        [currentWebView removeFromSuperview];
        if ([modalVC respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            // used if running >= iOS 6
            [modalVC dismissViewControllerAnimated:NO completion:nil];
        } else {
            // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [modalVC dismissModalViewControllerAnimated:NO];
#pragma clang diagnostic pop
        }
    }
    
    modalVC = nil;
    
    if (webViewPart2) {
        // Clean up webViewPart2 if returning from 2-part expansion.
        webViewPart2.navigationDelegate = nil;
        webViewPart2.UIDelegate = nil;
        currentWebView = webView;
        webViewPart2 = nil;
    } else {
        // Reset frame of webView if returning from 1-part expansion.
        webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    [self addSubview:webView];
    
    if (!isInterstitial) {
        [self fireSizeChangeEvent];
    } else {
        self.isViewable = NO;
        [self fireViewableChangeEvent];
    }
    
    if (state == PNLiteMRAIDStateDefault && isInterstitial) {
        state = PNLiteMRAIDStateHidden;
    } else if (state == PNLiteMRAIDStateExpanded || state == PNLiteMRAIDStateResized) {
        state = PNLiteMRAIDStateDefault;
    }
    [self fireStateChangeEvent];
    
    if ([self.delegate respondsToSelector:@selector(mraidViewDidClose:)]) {
        [self.delegate mraidViewDidClose:self];
    }
}

// This is a helper method which is not part of the official MRAID API.
- (void)closeFromResize {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback helper %@", NSStringFromSelector(_cmd)]];
    [self removeResizeCloseRegion];
    state = PNLiteMRAIDStateDefault;
    [self fireStateChangeEvent];
    [webView removeFromSuperview];
    webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:webView];
    [resizeView removeFromSuperview];
    resizeView = nil;
    [self fireSizeChangeEvent];
    if ([self.delegate respondsToSelector:@selector(mraidViewDidClose:)]) {
        [self.delegate mraidViewDidClose:self];
    }
}

// Note: This method is also used to present an interstitial ad.
- (void)expand:(NSString *)urlString supportVerve:(BOOL)supportVerve{
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.expand() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), (urlString ? urlString : @"1-part")]];
    
    // The only time it is valid to call expand is when the ad is currently in either default or resized state.
    if (state != PNLiteMRAIDStateDefault && state != PNLiteMRAIDStateResized) {
        // do nothing
        return;
    }
    
    modalVC = [[PNLiteMRAIDModalViewController alloc] initWithOrientationProperties:orientationProperties];
    CGRect frame = [[UIScreen mainScreen] bounds];
    modalVC.view.frame = frame;
    modalVC.delegate = self;
    
    if (!urlString) {
        // 1-part expansion
        webView.frame = CGRectMake(frame.size.width/2 - adWidth/2, frame.size.height/2 - adHeight/2, adWidth, adHeight);
        [webView removeFromSuperview];
    } else {
        // 2-part expansion
        webViewPart2 = [[WKWebView alloc] initWithFrame:frame configuration:[self createConfiguration]];
        [self initWebView:webViewPart2];
        currentWebView = webViewPart2;
        bonafideTapObserved = YES; // by definition for 2 part expand a valid tap has occurred
        
        if (omSDKjs) {
            [self injectJavaScript:omSDKjs];
        }
        
        // Check to see whether we've been given an absolute or relative URL.
        // If it's relative, prepend the base URL.
        if (!supportVerve) {
            urlString = [urlString stringByRemovingPercentEncoding];
            if (![[NSURL URLWithString:urlString] scheme]) {
                // relative URL
                urlString = [[[baseURL absoluteString] stringByRemovingPercentEncoding] stringByAppendingString:urlString];
            }

            // Need to escape characters which are URL specific
            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        }

        NSError *error;
        NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            if (!supportVerve) {
                [webViewPart2 loadHTMLString:content baseURL:baseURL];
            } else {
                [webViewPart2 loadRequest:[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]]];
            }
        } else {
            // Error! Clean up and return.
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Could not load part 2 expanded content for URL: %@" ,urlString]];
            currentWebView = webView;
            webViewPart2.navigationDelegate = nil;
            webViewPart2.UIDelegate = nil;
            webViewPart2 = nil;
            modalVC = nil;
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mraidViewWillExpand:)]) {
        [self.delegate mraidViewWillExpand:self];
    }
    
    [modalVC.view addSubview:currentWebView];
    
    // always include the close event region
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _skipOffset * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self addCloseEventRegion];
    });
    
    if ([self.rootViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        // used if running >= iOS 6
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {  // respect clear backgroundColor
            self.rootViewController.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        } else {
            modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self.rootViewController presentViewController:modalVC animated:NO completion:nil];
    } else {
        // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.rootViewController presentModalViewController:modalVC animated:NO];
#pragma clang diagnostic pop
    }
    
    if (!isInterstitial) {
        state = PNLiteMRAIDStateExpanded;
        [self fireStateChangeEvent];
    }
    
    if (isInterstitial) {
        [self addContentInfoViewToView:webView];
    }
    
    [self fireSizeChangeEvent];
    self.isViewable = YES;
}

- (void)open:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.open() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    
    // Notify the callers
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceOpenBrowserWithUrlString:)]) {
        [self.serviceDelegate mraidServiceOpenBrowserWithUrlString:urlString];
    }
}

- (void)playVideo:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.playVideo() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServicePlayVideoWithUrlString:)]) {
        [self.serviceDelegate mraidServicePlayVideoWithUrlString:urlString];
    }
}

- (void)sendSMS:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.sendSMS() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceSendSMSWithUrlString:)]) {
        [self.serviceDelegate mraidServiceSendSMSWithUrlString:urlString];
    }
}

- (void)callNumber:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.callNumber() when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString = [urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceCallNumberWithUrlString:)]) {
        [self.serviceDelegate mraidServiceCallNumberWithUrlString:urlString];
    }
}

- (void)resize {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.resize when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
    // If our delegate doesn't respond to the mraidViewShouldResizeToPosition:allowOffscreen: message,
    // then we can't do anything. We need help from the app here.
    if (![self.delegate respondsToSelector:@selector(mraidViewShouldResize:toPosition:allowOffscreen:)]) {
        return;
    }
    
    CGRect resizeFrame = CGRectMake(resizeProperties.offsetX, resizeProperties.offsetY, resizeProperties.width, resizeProperties.height);
    // The offset of the resize frame is relative to the origin of the default banner.
    CGPoint bannerOriginInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
    resizeFrame.origin.x += bannerOriginInRootView.x;
    resizeFrame.origin.y += bannerOriginInRootView.y;
    
    if (![self.delegate mraidViewShouldResize:self toPosition:resizeFrame allowOffscreen:resizeProperties.allowOffscreen]) {
        return;
    }
    
    // resize here
    state = PNLiteMRAIDStateResized;
    [self fireStateChangeEvent];
    
    if (!resizeView) {
        resizeView = [[UIView alloc] initWithFrame:resizeFrame];
        [webView removeFromSuperview];
        [resizeView addSubview:webView];
        [self.rootViewController.view addSubview:resizeView];
    }
    
    resizeView.frame = resizeFrame;
    webView.frame = resizeView.bounds;
    [self showResizeCloseRegion];
    [self fireSizeChangeEvent];
}

- (void)setOrientationProperties:(NSDictionary *)properties; {
    BOOL allowOrientationChange = [[properties valueForKey:@"allowOrientationChange"] boolValue];
    NSString *forceOrientation = [properties valueForKey:@"forceOrientation"];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@ %@", NSStringFromSelector(_cmd), (allowOrientationChange ? @"YES" : @"NO"), forceOrientation]];
    orientationProperties.allowOrientationChange = allowOrientationChange;
    orientationProperties.forceOrientation = [PNLiteMRAIDOrientationProperties MRAIDForceOrientationFromString:forceOrientation];
    [modalVC forceToOrientation:orientationProperties];
}

- (void)setResizeProperties:(NSDictionary *)properties; {
    int width = [[properties valueForKey:@"width"] intValue];
    int height = [[properties valueForKey:@"height"] intValue];
    int offsetX = [[properties valueForKey:@"offsetX"] intValue];
    int offsetY = [[properties valueForKey:@"offsetY"] intValue];
    NSString *customClosePosition = [properties valueForKey:@"customClosePosition"];
    BOOL allowOffscreen = [[properties valueForKey:@"allowOffscreen"] boolValue];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %d %d %d %d %@ %@", NSStringFromSelector(_cmd), width, height, offsetX, offsetY, customClosePosition, (allowOffscreen ? @"YES" : @"NO")]];
    resizeProperties.width = width;
    resizeProperties.height = height;
    resizeProperties.offsetX = offsetX;
    resizeProperties.offsetY = offsetY;
    resizeProperties.customClosePosition = [PNLiteMRAIDResizeProperties MRAIDCustomClosePositionFromString:customClosePosition];
    resizeProperties.allowOffscreen = allowOffscreen;
}

- (void)storePicture:(NSString *)urlString {
    if(!bonafideTapObserved && PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Suppressing an attempt to programmatically call mraid.storePicture when no UI touch event exists."];
        return;  // ignore programmatic touches (taps)
    }
    
    urlString=[urlString stringByRemovingPercentEncoding];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), urlString]];
    
    if ([supportedFeatures containsObject:PNLiteMRAIDSupportsStorePicture]) {
        if ([self.serviceDelegate respondsToSelector:@selector(mraidServiceStorePictureWithUrlString:)]) {
            [self.serviceDelegate mraidServiceStorePictureWithUrlString:urlString];
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"No PNLiteMRAIDSupportsStorePicture feature has been included"]];
    }
}

- (void)useCustomClose:(NSString *)isCustomCloseString {
    BOOL isCustomClose = [isCustomCloseString boolValue];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@ %@", NSStringFromSelector(_cmd), (isCustomClose ? @"YES" : @"NO")]];
    useCustomClose = isCustomClose;
}

#pragma mark - JavaScript --> native support helpers

// These methods are helper methods for the ones above.
- (void)addContentInfoViewToView:(UIView *)view {
    contentInfoViewContainer = [[UIView alloc] init];
    [contentInfoViewContainer setAccessibilityLabel:@"Content Info Container View"];
    [contentInfoViewContainer setAccessibilityIdentifier:@"contentInfoContainerView"];
    contentInfoView.delegate = self;
    [view addSubview:contentInfoViewContainer];
    [contentInfoViewContainer addSubview:contentInfoView];
    
    [[HyBidViewabilityWebAdSession sharedInstance] addFriendlyObstruction:contentInfoViewContainer toOMIDAdSession:adSession withReason:@"This view is related to Content Info" isInterstitial:isInterstitial];

    if (@available(iOS 11.0, *)) {
        contentInfoViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.f
                                                                                constant:kContentInfoViewWidth],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.f
                                                                                constant:kContentInfoViewHeight],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:view.safeAreaLayoutGuide
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.f
                                                                                constant:0.f],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:view.safeAreaLayoutGuide
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1.f
                                                                                constant:0.f],]];
    } else {
        contentInfoViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.f
                                                                                constant:kContentInfoViewWidth],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.f
                                                                                constant:kContentInfoViewHeight],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:view
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.f
                                                                                constant:0.f],
                                                  [NSLayoutConstraint constraintWithItem:contentInfoViewContainer
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:view
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1.f
                                                                                constant:0.f],]];
    }
}

- (void)addCloseEventRegion {
    
    closeEventRegion = [UIButton buttonWithType:UIButtonTypeCustom];
    closeEventRegion.backgroundColor = [UIColor clearColor];
    [closeEventRegion addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    if (!useCustomClose) {
        // get button image from header file
        NSData* buttonData = [NSData dataWithBytesNoCopy:__PNLite_MRAID_CloseButton_png
                                                  length:__PNLite_MRAID_CloseButton_png_len
                                            freeWhenDone:NO];
        UIImage *closeButtonImage = [UIImage imageWithData:buttonData];
        [closeEventRegion setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
    }
    
    closeEventRegion.frame = CGRectMake(0, 0, kCloseEventRegionSize, kCloseEventRegionSize);
    CGRect frame = closeEventRegion.frame;
    
    // align on top right
    int x = CGRectGetWidth(modalVC.view.frame) - CGRectGetWidth(frame);
    frame.origin = CGPointMake(x, 0);
    closeEventRegion.frame = frame;
    // autoresizing so it stays at top right (flexible left and flexible bottom margin)
    closeEventRegion.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [modalVC.view addSubview:closeEventRegion];
}

- (void)showResizeCloseRegion {
    if (!resizeCloseRegion) {
        resizeCloseRegion = [UIButton buttonWithType:UIButtonTypeCustom];
        resizeCloseRegion.frame = CGRectMake(0, 0, kCloseEventRegionSize, kCloseEventRegionSize);
        resizeCloseRegion.backgroundColor = [UIColor clearColor];
        [resizeCloseRegion addTarget:self action:@selector(closeFromResize) forControlEvents:UIControlEventTouchUpInside];
        [resizeView addSubview:resizeCloseRegion];
    }
    
    // align appropriately
    int x;
    int y;
    UIViewAutoresizing autoresizingMask = UIViewAutoresizingNone;
    
    switch (resizeProperties.customClosePosition) {
        case PNLiteMRAIDCustomClosePositionTopLeft:
        case PNLiteMRAIDCustomClosePositionBottomLeft:
            x = 0;
            break;
        case PNLiteMRAIDCustomClosePositionTopCenter:
        case PNLiteMRAIDCustomClosePositionCenter:
        case PNLiteMRAIDCustomClosePositionBottomCenter:
            x = (CGRectGetWidth(resizeView.frame) - CGRectGetWidth(resizeCloseRegion.frame)) / 2;
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
        case PNLiteMRAIDCustomClosePositionTopRight:
        case PNLiteMRAIDCustomClosePositionBottomRight:
            x = CGRectGetWidth(resizeView.frame) - CGRectGetWidth(resizeCloseRegion.frame);
            autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            break;
    }
    
    switch (resizeProperties.customClosePosition) {
        case PNLiteMRAIDCustomClosePositionTopLeft:
        case PNLiteMRAIDCustomClosePositionTopCenter:
        case PNLiteMRAIDCustomClosePositionTopRight:
            y = 0;
            break;
        case PNLiteMRAIDCustomClosePositionCenter:
            y = (CGRectGetHeight(resizeView.frame) - CGRectGetHeight(resizeCloseRegion.frame)) / 2;
            autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
        case PNLiteMRAIDCustomClosePositionBottomLeft:
        case PNLiteMRAIDCustomClosePositionBottomCenter:
        case PNLiteMRAIDCustomClosePositionBottomRight:
            y = CGRectGetHeight(resizeView.frame) - CGRectGetHeight(resizeCloseRegion.frame);
            autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
            break;
    }
    
    CGRect resizeCloseRegionFrame = resizeCloseRegion.frame;
    resizeCloseRegionFrame.origin = CGPointMake(x, y);
    resizeCloseRegion.frame = resizeCloseRegionFrame;
    resizeCloseRegion.autoresizingMask = autoresizingMask;
}

- (void)removeResizeCloseRegion {
    if (resizeCloseRegion) {
        [resizeCloseRegion removeFromSuperview];
        resizeCloseRegion = nil;
    }
}

- (void)setResizeViewPosition {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    CGRect oldResizeFrame = resizeView.frame;
    CGRect newResizeFrame = CGRectMake(resizeProperties.offsetX, resizeProperties.offsetY, resizeProperties.width, resizeProperties.height);
    // The offset of the resize frame is relative to the origin of the default banner.
    CGPoint bannerOriginInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
    newResizeFrame.origin.x += bannerOriginInRootView.x;
    newResizeFrame.origin.y += bannerOriginInRootView.y;
    if (!CGRectEqualToRect(oldResizeFrame, newResizeFrame)) {
        resizeView.frame = newResizeFrame;
    }
}

#pragma mark - native -->  JavaScript support

- (void)injectJavaScript:(NSString *)js {
    [currentWebView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {}];
}

// convenience methods
- (void)fireErrorEventWithAction:(NSString *)action message:(NSString *)message {
    [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireErrorEvent('%@','%@');", message, action]];
}

- (void)fireReadyEvent {
    [self injectJavaScript:@"mraid.fireReadyEvent()"];
}

- (void)fireSizeChangeEvent {
    @synchronized(self) {
        int x;
        int y;
        int width;
        int height;
        if (state == PNLiteMRAIDStateExpanded || isInterstitial) {
            x = (int)currentWebView.frame.origin.x;
            y = (int)currentWebView.frame.origin.y;
            width = (int)currentWebView.frame.size.width;
            height = (int)currentWebView.frame.size.height;
        } else if (state == PNLiteMRAIDStateResized) {
            x = (int)resizeView.frame.origin.x;
            y = (int)resizeView.frame.origin.y;
            width = (int)resizeView.frame.size.width;
            height = (int)resizeView.frame.size.height;
        } else {
            // Per the MRAID spec, the current or default position is relative to the rectangle defined by the getMaxSize method,
            // that is, the largest size that the ad can resize to.
            CGPoint originInRootView = [self.rootViewController.view convertPoint:CGPointZero fromView:self];
            x = originInRootView.x;
            y = originInRootView.y;
            width = (int)self.frame.size.width;
            height = (int)self.frame.size.height;
        }
        
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
        BOOL adjustOrientationForIOS8 = isInterstitial &&  isLandscape && !SYSTEM_VERSION_LESS_THAN(@"8.0");
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setCurrentPosition(%d,%d,%d,%d);", x, y, adjustOrientationForIOS8?height:width, adjustOrientationForIOS8?width:height]];
    }
}

- (void)fireStateChangeEvent {
    @synchronized(self) {
        NSArray *stateNames = @[
                                @"loading",
                                @"default",
                                @"expanded",
                                @"resized",
                                @"hidden",
                                ];
        
        NSString *stateName = stateNames[state];
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireStateChangeEvent('%@');", stateName]];
    }
}

- (void)fireViewableChangeEvent {
    [self injectJavaScript:[NSString stringWithFormat:@"mraid.fireViewableChangeEvent(%@);", (self.isViewable ? @"true" : @"false")]];
}

- (void)setDefaultPosition {
    if (isInterstitial) {
        // For interstitials, we define defaultPosition to be the same as screen size, so set the value there.
        return;
    }
    
    // getDefault position from the parent frame if we are not directly added to the rootview
    if(self.superview != self.rootViewController.view) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(%f,%f,%f,%f);", self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height]];
    } else {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(%f,%f,%f,%f);", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height]];
    }
}

- (void)setMaxSize {
    if (isInterstitial) {
        // For interstitials, we define maxSize to be the same as screen size, so set the value there.
        return;
    }
    CGSize maxSize = self.rootViewController.view.bounds.size;
    if (!CGSizeEqualToSize(maxSize, previousMaxSize)) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setMaxSize(%d,%d);",
                                (int)maxSize.width,
                                (int)maxSize.height]];
        previousMaxSize = CGSizeMake(maxSize.width, maxSize.height);
    }
}

- (void)setScreenSize {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    // screenSize is ALWAYS for portrait orientation, so we need to figure out the
    // actual interface orientation to get the correct current screenRect.
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        screenSize = CGSizeMake(screenSize.width, screenSize.height);
    } else {
        if (isLandscape) {
            screenSize = CGSizeMake(screenSize.height, screenSize.width);
        }
    }
    if (!CGSizeEqualToSize(screenSize, previousScreenSize)) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setScreenSize(%d,%d);",
                                (int)screenSize.width,
                                (int)screenSize.height]];
        previousScreenSize = CGSizeMake(screenSize.width, screenSize.height);
        if (isInterstitial) {
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setMaxSize(%d,%d);",
                                    (int)screenSize.width,
                                    (int)screenSize.height]];
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setDefaultPosition(0,0,%d,%d);",
                                    (int)screenSize.width,
                                    (int)screenSize.height]];
        }
    }
}

- (void)setSupports:(NSArray *)currentFeatures {
    for (id aFeature in mraidFeatures) {
        [self injectJavaScript:[NSString stringWithFormat:@"mraid.setSupports('%@',%@);", aFeature,[currentFeatures containsObject:aFeature]?@"true":@"false"]];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    @synchronized(self) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
        
        if (webView.frame.size.height == CGSizeZero.height && webView.frame.size.width == CGSizeZero.width) {
            self.frame = CGRectMake(0, 0, webView.scrollView.contentSize.width, webView.scrollView.contentSize.height);
            CGRect frame = webView.frame;
            frame.size = self.frame.size;
            frame.origin = self.frame.origin;
            webView.frame = frame;
        }
        
        // If wv is webViewPart2, that means the part 2 expanded web view has just loaded.
        // In this case, state should already be PNLiteMRAIDStateExpanded and should not be changed.
        // if (wv != webViewPart2) {
        
        if (PNLite_ENABLE_JS_LOG) {
            [webView evaluateJavaScript:@"var enableLog = true" completionHandler:^(id result, NSError *error) {}];
        }
        
        if (PNLite_SUPPRESS_JS_ALERT) {
            [webView evaluateJavaScript:@"function alert(){}; function prompt(){}; function confirm(){}" completionHandler:^(id result, NSError *error) {}];
        }
        
        if (state == PNLiteMRAIDStateLoading) {
            state = PNLiteMRAIDStateDefault;
            [self injectJavaScript:[NSString stringWithFormat:@"mraid.setPlacementType('%@');", (isInterstitial ? @"interstitial" : @"inline")]];
            [self setSupports:supportedFeatures];
            [self setDefaultPosition];
            [self setMaxSize];
            [self setScreenSize];
            [self fireStateChangeEvent];
            [self fireSizeChangeEvent];
            [self fireReadyEvent];
            
            if ([self.delegate respondsToSelector:@selector(mraidViewAdReady:)]) {
                // Interstitials isViewable flag will be fired only when they are showing.
                if (!isInterstitial) {
                    self.isViewable = YES;
                }
                [self.delegate mraidViewAdReady:self];
            }
            
            if (!isInterstitial) {
                [self addContentInfoViewToView:self];
            }
            
            // Start monitoring device orientation so we can reset max Size and screenSize if needed.
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(deviceOrientationDidChange:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"JS callback %@", NSStringFromSelector(_cmd)]];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = [navigationAction.request URL];
    NSString *scheme = [url scheme];
    NSString *absUrlString = [url absoluteString];
    
    if ([scheme isEqualToString:@"mraid"]) {
        [self parseCommandUrl:absUrlString];
        
    } else if ([scheme isEqualToString:@"console-log"]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS console: %@",
                                                         [[absUrlString substringFromIndex:14] stringByRemovingPercentEncoding ]]];
    } else {
        [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Found URL %@ with type %@", absUrlString, @(navigationAction.navigationType)]];
        
        // Links, Form submissions
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            // For banner views
            if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS webview load: %@",
                                                                 [absUrlString stringByRemovingPercentEncoding]]];
                if ([absUrlString containsString:@"tags-prod.vrvm.com"]
                    && [absUrlString containsString:@"type=expandable"]
                    && self.isViewable) {
                    [self expand:absUrlString supportVerve:YES];
                } else {
                    [self.delegate mraidViewNavigate:self withURL:url];
                }
            }
        } else {
            // Need to let browser to handle rendering and other things
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyCancel);
    return;
}

#pragma mark - OM SDK Viewability

- (void)startAdSession {
    
    if (!isAdSessionCreated) {
        
        adSession = [[HyBidViewabilityWebAdSession sharedInstance] createOMIDAdSessionforWebView:currentWebView isVideoAd:NO];

        if (isInterstitial) {
            [[HyBidViewabilityWebAdSession sharedInstance] addFriendlyObstruction:closeEventRegion toOMIDAdSession:adSession withReason:@"" isInterstitial:isInterstitial];
        }
        [[HyBidViewabilityWebAdSession sharedInstance] startOMIDAdSession:adSession];
        isAdSessionCreated = YES;
        [[HyBidViewabilityWebAdSession sharedInstance] fireOMIDAdLoadEvent:adSession];
        [[HyBidViewabilityWebAdSession sharedInstance] fireOMIDImpressionOccuredEvent:adSession];
    }
     
}

- (void)stopAdSession {
    
    if (isAdSessionCreated) {
        [[HyBidViewabilityWebAdSession sharedInstance] stopOMIDAdSession:adSession];
        isAdSessionCreated = NO;
    }
     
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    // Open any links to new windows in the current WKWebView rather than create a new one
    if (!navigationAction.targetFrame.isMainFrame) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[UIApplication sharedApplication] openURL:[navigationAction.request URL]];
        if ([self.delegate respondsToSelector:@selector(mraidViewNavigate:withURL:)]) {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"JS webview load: %@",
                                                                                                                              [[[navigationAction.request URL] absoluteString] stringByRemovingPercentEncoding]]];
            [self.delegate mraidViewNavigate:self withURL:[navigationAction.request URL]];
        }
    }
    
    return nil;
}

#pragma mark - MRAIDModalViewControllerDelegate

- (void)mraidModalViewControllerDidRotate:(PNLiteMRAIDModalViewController *)modalViewController {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@", NSStringFromSelector(_cmd)]];
    [self setScreenSize];
    [self fireSizeChangeEvent];
}

#pragma mark - internal helper methods

- (WKWebViewConfiguration *)createConfiguration {
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webConfiguration.userContentController = wkUController;

    if ([supportedFeatures containsObject:PNLiteMRAIDSupportsInlineVideo]) {
        webConfiguration.allowsInlineMediaPlayback = YES;
        webConfiguration.requiresUserActionForMediaPlayback = NO;
    } else {
        webConfiguration.allowsInlineMediaPlayback = NO;
        webConfiguration.requiresUserActionForMediaPlayback = YES;
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"No inline video support has been included, videos will play full screen without autoplay."]];
    }
    
    return webConfiguration;
}

- (void)initWebView:(WKWebView *)wv {
    wv.navigationDelegate = self;
    wv.UIDelegate = self;
    wv.opaque = NO;
    wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    wv.autoresizesSubviews = YES;
    
    // disable scrolling
    UIScrollView *scrollView;
    if ([wv respondsToSelector:@selector(scrollView)]) {
        scrollView = [wv scrollView];
    } else {
        for (id subview in [self subviews]) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                scrollView = subview;
                break;
            }
        }
    }
    scrollView.scrollEnabled = NO;
    
    // disable selection
    NSString *js = @"window.getSelection().removeAllRanges();";
    [wv evaluateJavaScript:js completionHandler:^(id result, NSError *error) {}];
    
    // Alert suppression
    if (PNLite_SUPPRESS_JS_ALERT)
        [wv evaluateJavaScript:@"function alert(){}; function prompt(){}; function confirm(){}" completionHandler:^(id result, NSError *error) {}];
}

- (void)parseCommandUrl:(NSString *)commandUrlString {
    NSDictionary *commandDict = [mraidParser parseCommandUrl:commandUrlString];
    if (!commandDict) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"invalid command URL: %@", commandUrlString]];
        return;
    }
    
    NSString *command = [commandDict valueForKey:@"command"];
    NSObject *paramObj = [commandDict valueForKey:@"paramObj"];
    
    if ([command isEqualToString:@"expand:"]) {
        command = @"expand:supportVerve:";
    }
    SEL selector = NSSelectorFromString(command);
    
    // Turn off the warning "PerformSelector may cause a leak because its selector is unknown".
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    [self performSelector:selector withObject:paramObj];
    
#pragma clang diagnostic pop
}

#pragma mark - Gesture Methods

- (void)setUpTapGestureRecognizer {
    if(!PNLite_SUPPRESS_BANNER_AUTO_REDIRECT) {
        return;  // return without adding the GestureRecognizer if the feature is not enabled
    }
    // One finger, one tap
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerOneTap)];
    
    // Set up
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    
    // Add the gesture to the view
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)oneFingerOneTap {
    bonafideTapObserved=YES;
    tapGestureRecognizer.delegate=nil;
    tapGestureRecognizer=nil;
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture oneFingerTap observed"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == resizeCloseRegion || touch.view == closeEventRegion) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture 'shouldReceiveTouch'=NO"];
        return NO;
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"tapGesture 'shouldReceiveTouch'=YES"];
    return YES;
}

@end
