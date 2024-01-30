//
//  Copyright © 2020 PubNative. All rights reserved.
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

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif
#import "HyBidSKAdNetworkViewController.h"
#import "UIApplication+PNLiteTopViewController.h"

NSDictionary *productParameters;

@interface HyBidSKAdNetworkViewController ()
@property (nonatomic, strong) SKStoreProductViewController *skAdnetworkViewController;
@property (nonatomic, weak) id<SKStoreProductViewControllerDelegate> delegate;
@end

@implementation HyBidSKAdNetworkViewController

- (id)initWithProductParameters:(NSDictionary *)parameters delegate:(id<SKStoreProductViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        productParameters = parameters;
        self.delegate = delegate;
    }
    
    return self;
}

- (void)loadProducts:(NSDictionary *)productParameters completionHandler:(void (^)(BOOL success, SKStoreProductViewController * _Nullable skAdnetworkViewController))completionHandler {
    
    SKStoreProductViewController *skAdnetworkViewController = [[SKStoreProductViewController alloc] init];
    skAdnetworkViewController.delegate = self.delegate;
    [skAdnetworkViewController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (!error && result) {
            completionHandler(YES, skAdnetworkViewController);
            return;
        }
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Loading the ad failed, try to load another ad or retry the current ad."];
        completionHandler(NO, nil);
        return;
    }];
}

- (void)presentInTopViewController:(SKStoreProductViewController *)skAdnetworkViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication].topViewController isMemberOfClass: [SKStoreProductViewController class]]) {
            return;
        }
        
        [[UIApplication sharedApplication].topViewController presentViewController: skAdnetworkViewController animated: YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"adSkAdnetworkViewControllerIsShown" object:nil];
        }];
    });
}

- (void)presentSKStoreProductViewController:(void (^)(BOOL success))completionHandler {
    [self loadProducts: productParameters completionHandler:^(BOOL success, SKStoreProductViewController * _Nullable skAdnetworkViewController) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SKStoreProductViewIsReadyToPresent" object:nil];
            [self presentInTopViewController: skAdnetworkViewController];
            completionHandler(YES);
            return;
        }
        completionHandler(NO);
        return;
    }];
}

@end

@implementation SKStoreProductViewController (CustomMethods)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (@available(iOS 17.2, *)) {
        [self loadProductWithParameters:productParameters completionBlock:nil];
    }
}

@end
