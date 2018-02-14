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

#import <UIKit/UIKit.h>
#import "PNBrowserControlsView.h"

extern NSString * const kPubnativeBrowserFeatureSupportInlineMediaPlayback;
extern NSString * const kPubnativeBrowserFeatureDisableStatusBar;
extern NSString * const kPubnativeBrowserFeatureScalePagesToFit;

@class PNBrowser;

@protocol PNBrowserDelegate <NSObject>

@required

- (void)pubnativeBrowserClosed:(PNBrowser *)pubnativeBrowser;  // sent when the PubnativeBrowser viewController has dismissed - required
- (void)pubnativeBrowserWillExitApp:(PNBrowser *)pubnativeBrowser;  // sent when the PubnativeBrowser exits by opening the system openURL command

@optional

- (void)pubnativeTelPopupOpen:(PNBrowser *)pubnativeBrowser; // sent when the telephone dial confirmation popup is on the screen
- (void)pubnativeTelPopupClosed:(PNBrowser *)pubnativeBrowser; // sent when the telephone dial confirmation popip is dismissed

@end

@interface PNBrowser : UIViewController <PubnativeBrowserControlsViewDelegate>

@property (nonatomic, unsafe_unretained) id<PNBrowserDelegate>delegate;

- (id)initWithDelegate:(id<PNBrowserDelegate>)delegate withFeatures:(NSArray *)pubnativeBrowserFeatures;  // designated initializer for PubnativeBrowser

- (void)loadRequest:(NSURLRequest *)urlRequest;   // load urlRequest and present the souceKitBrowserViewController Note: requests such as tel: will immediately be presented using the UIApplication openURL: method without presenting the PubnativeBrowser's viewController

@end
