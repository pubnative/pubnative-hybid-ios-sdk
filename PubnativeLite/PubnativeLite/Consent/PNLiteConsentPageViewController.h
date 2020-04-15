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

@class PNLiteConsentPageViewController;

@protocol PNLiteConsentPageViewControllerDelegate<NSObject>

@optional

- (void)consentPageViewControllerWillDisappear:(PNLiteConsentPageViewController * _Nonnull)consentDialogViewController;
- (void)consentPageViewControllerDidDismiss:(PNLiteConsentPageViewController * _Nonnull)consentDialogViewController;

@end

@interface PNLiteConsentPageViewController : UIViewController

@property (nonatomic, weak) id<PNLiteConsentPageViewControllerDelegate> _Nullable delegate;

- (instancetype _Nullable)initWithConsentPageURL:(NSString * _Nonnull)consentPageURL NS_DESIGNATED_INITIALIZER;
- (void)loadConsentPageWithCompletion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completion;

/**
 These initializers are not available
 */
- (instancetype _Nullable)init NS_UNAVAILABLE;
- (instancetype _Nullable)initWithCoder:(NSCoder *_Nullable)aDecoder NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;

@end
