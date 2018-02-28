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

#import "PNBrowserControlsView.h"
#import "PNBrowser.h"
#import "BackButton.h"
#import "ForwardButton.h"

static const float kControlsToobarHeight = 44.0;
static const float kControlsLoadingIndicatorWidthHeight = 30.0;

@interface PNBrowserControlsView ()
{
    // backButton is a property
    UIBarButtonItem *flexBack;
    // forwardButton is a property
    UIBarButtonItem *flexForward;
    // loadingIndicator is a property
    UIBarButtonItem *flexLoading;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *flexRefresh;
    UIBarButtonItem *launchSafariButton;
    UIBarButtonItem *flexLaunch;
    UIBarButtonItem *stopButton;
    __unsafe_unretained PNBrowser *pnBrowser;
}

@end

@implementation PNBrowserControlsView

- (id)initWithPubnativeBrowser:(PNBrowser *)p_pnBrowser
{
    self = [super initWithFrame:CGRectMake(0, 0, p_pnBrowser.view.bounds.size.width, kControlsToobarHeight)];
    
    if (self) {
        _controlsToolbar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, p_pnBrowser.view.bounds.size.width, kControlsToobarHeight)];
        pnBrowser = p_pnBrowser;
        // In left to right order, to make layout on screen more clear
        NSData* backButtonData = [NSData dataWithBytesNoCopy:__PNLiteBackButton_png
                                                      length:__PNLiteBackButton_png_len
                                                freeWhenDone:NO];
        UIImage *backButtonImage = [UIImage imageWithData:backButtonData];
        _backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        _backButton.enabled = NO;
        flexBack = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSData* forwardButtonData = [NSData dataWithBytesNoCopy:__PNLiteForwardButton_png
                                                         length:__PNLiteForwardButton_png_len
                                                   freeWhenDone:NO];
        UIImage *forwardButtonImage = [UIImage imageWithData:forwardButtonData];
        _forwardButton = [[UIBarButtonItem alloc] initWithImage:forwardButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];
        _forwardButton.enabled = NO;
        flexForward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIView *placeHolder = [[UIView alloc] initWithFrame:CGRectMake(0,0,kControlsLoadingIndicatorWidthHeight,kControlsLoadingIndicatorWidthHeight)];
        _loadingIndicator = [[UIBarButtonItem alloc] initWithCustomView:placeHolder];  // loadingIndicator will be added here by the browser
        flexLoading = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:(self) action:@selector(refresh:)];
        flexRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        launchSafariButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:(self) action:@selector(launchSafari:)];
        flexLaunch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        stopButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:(self) action:@selector(dismiss:)];
        NSArray *toolbarButtons = @[_backButton, flexBack, _forwardButton, flexForward, _loadingIndicator, flexLoading, refreshButton, flexRefresh, launchSafariButton, flexLaunch, stopButton];
        [_controlsToolbar setItems:toolbarButtons animated:NO];
        _controlsToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_controlsToolbar];
    }
    return  self;
}

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not a valid initializer for the class PubnativeBrowserControlsView"
                                 userInfo:nil];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-initWithFrame: is not a valid initializer for the class PubnativeBrowserControlsView"
                                 userInfo:nil];
    return nil;
}

- (void)dealloc
{
    flexBack = nil;
    flexForward = nil;
    flexLoading = nil;
    refreshButton = nil;
    flexRefresh = nil;
    flexLaunch = nil;
    launchSafariButton = nil;
    stopButton = nil;
}

#pragma mark -
#pragma mark PubnativeBrowserControlsView actions

- (void)back:(id)sender
{
    [pnBrowser back];
}

- (void)dismiss:(id)sender
{
    [pnBrowser dismiss];
}

- (void)forward:(id)sender
{
    [pnBrowser forward];
}

- (void)launchSafari:(id)sender
{
    [pnBrowser launchSafari];
}

- (void)refresh:(id)sender
{
    [pnBrowser refresh];
}

@end
