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

#import "PNLiteMRAIDModalViewController.h"
#import "PNLiteMRAIDUtil.h"
#import "PNLiteMRAIDOrientationProperties.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

@interface PNLiteMRAIDModalViewController () {
    BOOL isStatusBarHidden;
    BOOL hasViewAppeared;
    BOOL hasRotated;
    
    PNLiteMRAIDOrientationProperties *orientationProperties;
    UIInterfaceOrientation preferredOrientation;
}

- (NSString *)stringfromUIInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation PNLiteMRAIDModalViewController

- (id)init {
    return [self initWithOrientationProperties:nil];
}

- (id)initWithOrientationProperties:(PNLiteMRAIDOrientationProperties *)orientationProps {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        if (orientationProps) {
            orientationProperties = orientationProps;
        } else {
            orientationProperties = [[PNLiteMRAIDOrientationProperties alloc] init];
        }
        
        UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        // If the orientation is forced, accomodate it.
        // If it's not fored, then match the current orientation.
        if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationPortrait) {
            preferredOrientation = UIInterfaceOrientationPortrait;
        } else  if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationLandscape) {
            if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) {
                preferredOrientation = currentInterfaceOrientation;
            } else {
                preferredOrientation = UIInterfaceOrientationLandscapeLeft;
            }
        } else {
            // orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationNone
            preferredOrientation = currentInterfaceOrientation;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - status bar

// This is to hide the status bar on iOS 6 and lower.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    self.view.backgroundColor = self.willShowFeedbackScreen ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    hasViewAppeared = YES;
    
    if (hasRotated) {
        [self.delegate mraidModalViewControllerDidRotate:self];
        hasRotated = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// This is to hide the status bar on iOS 7.
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - rotation/orientation

- (BOOL)shouldAutorotate {
    NSArray *supportedOrientationsInPlist = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
    
    BOOL isPortraitSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationPortrait"];
    BOOL isPortraitUpsideDownSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationPortraitUpsideDown"];
    BOOL isLandscapeLeftSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationLandscapeLeft"];
    BOOL isLandscapeRightSupported = [supportedOrientationsInPlist containsObject:@"UIInterfaceOrientationLandscapeRight"];
    
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    BOOL retval = NO;

    if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationPortrait) {
        retval = (isPortraitSupported && isPortraitUpsideDownSupported);
    } else if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationLandscape) {
        retval = (isLandscapeLeftSupported && isLandscapeRightSupported);
    } else {
        // orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationNone
        if (orientationProperties.allowOrientationChange) {
            retval = YES;
        } else {
            if (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation)) {
                retval = (isPortraitSupported && isPortraitUpsideDownSupported);
            } else {
                // currentInterfaceOrientation is landscape
                return (isLandscapeLeftSupported && isLandscapeRightSupported);
            }
        }
    }
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@ %@", [self.class description], NSStringFromSelector(_cmd), (retval ? @"YES" : @"NO")]];
    return retval;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@ %@",
                                                                                                                 [self.class description],
                                                                                                                 NSStringFromSelector(_cmd),
                                                                                                                 [self stringfromUIInterfaceOrientation:preferredOrientation]
                                                                                                                 ]];
    return preferredOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class])  fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@", [self.class description], NSStringFromSelector(_cmd)]];
    if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    // orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationNone
    
    if (!orientationProperties.allowOrientationChange) {
        if (UIInterfaceOrientationIsPortrait(preferredOrientation)) {
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
        } else {
            return UIInterfaceOrientationMaskLandscape;
        }
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@ %@ to %@", [self.class description], NSStringFromSelector(_cmd), [self stringfromUIInterfaceOrientation:toInterfaceOrientation]]];
    
    // willRotateToInterfaceOrientation code goes here
   
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // willAnimateRotationToInterfaceOrientation code goes here
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // didRotateFromInterfaceOrientation goes here
        if (self->hasViewAppeared) {
            [self.delegate mraidModalViewControllerDidRotate:self];
            self->hasRotated = NO;
        }
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)forceToOrientation:(PNLiteMRAIDOrientationProperties *)orientationProps; {
    NSString *orientationString;
    switch (orientationProps.forceOrientation) {
        case PNLiteMRAIDForceOrientationPortrait:
            orientationString = @"portrait";
            break;
        case PNLiteMRAIDForceOrientationLandscape:
            orientationString = @"landscape";
            break;
        case PNLiteMRAIDForceOrientationNone:
            orientationString = @"none";
            break;
        default:
            orientationString = @"wtf!";
            break;
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"%@ %@ %@ %@",
                                                                                                                 [self.class description],
                                                                                                                 NSStringFromSelector(_cmd),
                                                                                                                 (orientationProperties.allowOrientationChange ? @"YES" : @"NO"),
                                                                                                                 orientationString]
     ];
    
    orientationProperties = orientationProps;
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationPortrait) {
        if (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation)) {
            // this will accomodate both portrait and portrait upside down
            preferredOrientation = currentInterfaceOrientation;
        } else {
            preferredOrientation = UIInterfaceOrientationPortrait;
        }
    } else if (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationLandscape) {
        if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) {
            // this will accomodate both landscape left and landscape right
            preferredOrientation = currentInterfaceOrientation;
        } else {
            preferredOrientation = UIInterfaceOrientationLandscapeLeft;
        }
    } else {
        // orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationNone
        if (orientationProperties.allowOrientationChange) {
            UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
            // NB: UIInterfaceOrientationLandscapeLeft = UIDeviceOrientationLandscapeRight
            // and UIInterfaceOrientationLandscapeLeft = UIDeviceOrientationLandscapeLeft !
            if (currentDeviceOrientation == UIDeviceOrientationPortrait) {
                preferredOrientation = UIInterfaceOrientationPortrait;
            } else if (currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                preferredOrientation = UIInterfaceOrientationPortraitUpsideDown;
            } else if (currentDeviceOrientation == UIDeviceOrientationLandscapeRight) {
                preferredOrientation = UIInterfaceOrientationLandscapeLeft;
            } else if (currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) {
                preferredOrientation = UIInterfaceOrientationLandscapeRight;
            }
            
            // Make sure that the preferredOrientation is supported by the app. If not, then change it.
            
            NSString *preferredOrientationString;
            if (preferredOrientation == UIInterfaceOrientationPortrait) {
                preferredOrientationString = @"UIInterfaceOrientationPortrait";
            } else if (preferredOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                preferredOrientationString = @"UIInterfaceOrientationPortraitUpsideDown";
            } else if (preferredOrientation == UIInterfaceOrientationLandscapeLeft) {
                preferredOrientationString = @"UIInterfaceOrientationLandscapeLeft";
            } else if (preferredOrientation == UIInterfaceOrientationLandscapeRight) {
                preferredOrientationString = @"UIInterfaceOrientationLandscapeRight";
            }
            NSArray *supportedOrientationsInPlist = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
            BOOL isSupported = [supportedOrientationsInPlist containsObject:preferredOrientationString];
            if (!isSupported) {
                // use the first supported orientation in the plist
                preferredOrientationString = supportedOrientationsInPlist[0];
                if ([preferredOrientationString isEqualToString:@"UIInterfaceOrientationPortrait"]) {
                    preferredOrientation = UIInterfaceOrientationPortrait;
                } else if ([preferredOrientationString isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
                    preferredOrientation = UIInterfaceOrientationPortraitUpsideDown;
                } else if ([preferredOrientationString isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
                    preferredOrientation = UIInterfaceOrientationLandscapeLeft;
                } else if ([preferredOrientationString isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
                    preferredOrientation = UIInterfaceOrientationLandscapeRight;
                }
            }
        } else {
            // orientationProperties.allowOrientationChange == NO
            preferredOrientation = currentInterfaceOrientation;
        }
    }
    
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class])  fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"requesting from %@ to %@",
                                                                                                                  [self stringfromUIInterfaceOrientation:currentInterfaceOrientation],
                                                                                                                  [self stringfromUIInterfaceOrientation:preferredOrientation]]
    ];
    
    if ((orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationPortrait && UIInterfaceOrientationIsPortrait(currentInterfaceOrientation)) ||
        (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationLandscape && UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) ||
        (orientationProperties.forceOrientation == PNLiteMRAIDForceOrientationNone && (preferredOrientation == currentInterfaceOrientation)))
    {
        return;
    }
    
    UIViewController *presentingVC;
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        // iOS 5+
        presentingVC = self.presentingViewController;
    } else {
        // iOS 4
        presentingVC = self.parentViewController;
    }
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)] &&
        [self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        // iOS 6+
        [self dismissViewControllerAnimated:NO completion:^{
             [presentingVC presentViewController:self animated:NO completion:nil];
         }];
    } else {
        // < iOS 6
        // Turn off the warning about using a deprecated method.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self dismissModalViewControllerAnimated:NO];
        [presentingVC presentModalViewController:self animated:NO];
#pragma clang diagnostic pop
    }
    
    hasRotated = YES;
}

- (NSString *)stringfromUIInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return @"portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"portrait upside down";
        case UIInterfaceOrientationLandscapeLeft:
            return @"landscape left";
        case UIInterfaceOrientationLandscapeRight:
            return @"landscape right";
        default:
            return @"unknown";
    }
}

@end
