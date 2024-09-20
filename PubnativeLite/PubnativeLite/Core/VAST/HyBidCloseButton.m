//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidCloseButton.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kClickableAreaDefaultSize 30.0
#define kCloseImageDefaultSize 30.0

#define kClickableAreaResizedSize 20.0
#define kCloseImageResizedSize 20.0

@implementation HyBidCloseButton {
    UIImageView *closeImageView;
}

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target ad:(HyBidAd *)ad {
    return [self initWithRootView:rootView action:action target:target showSkipButton:NO useCustomClose:NO ad:ad];
}

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target showSkipButton:(BOOL)showSkipButton ad:(HyBidAd *)ad {
    return [self initWithRootView:rootView action:action target:target showSkipButton:showSkipButton useCustomClose:NO ad:ad];
}

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target showSkipButton:(BOOL)showSkipButton useCustomClose:(BOOL)useCustomClose ad:(HyBidAd *)ad {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *closeImage;
        CGSize buttonSize = [self buttonSizeBasedOn:ad];
        if (showSkipButton) {
            if ([self isDefaultSize:buttonSize]) {
                [self setAccessibilityIdentifier:@"skipButton"];
                [self setAccessibilityLabel:@"Skip Button"];
            } else {
                [self setAccessibilityIdentifier:@"skipButtonSmall"];
                [self setAccessibilityLabel:@"Skip Button Small"];
            }
            closeImage = [self bundledImageNamed:@"skip"];
        } else {
            if ([self isDefaultSize:buttonSize]) {
                [self setAccessibilityIdentifier:@"closeButton"];
                [self setAccessibilityLabel:@"Close Button"];
            } else {
                [self setAccessibilityIdentifier:@"closeButtonSmall"];
                [self setAccessibilityLabel:@"Close Button Small"];
            }
            closeImage = [self bundledImageNamed:@"close"];
        }
        
        if (!useCustomClose) {
            closeImageView = [[UIImageView alloc] initWithImage:closeImage];
            closeImageView.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        }
        
        [self addSubview:closeImageView];
        
        // Setup constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;
        closeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [rootView addSubview:self];
        
        // We had to remove the button label to avoid getting XCUIElementTypeStaticText under UIButton in Appium inspector.
        [self.titleLabel removeFromSuperview];
        
        NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObjects:
                                                             [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant: buttonSize.width],
                                                             [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant: buttonSize.height], nil];
        
        if (@available(iOS 11.0, *)) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        }
        
        [NSLayoutConstraint activateConstraints:constraints];
        
        NSArray<NSLayoutConstraint *> *closeImageViewConstraints = @[
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:buttonSize.width],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:buttonSize.height]
        ];

        [NSLayoutConstraint activateConstraints:closeImageViewConstraints];
    }
    return self;

}

- (UIImage*)bundledImageNamed:(NSString*)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

+ (BOOL)buttonShouldBeResized:(HyBidAd *)ad {
    if (!ad || !ad.adExperience) {
        return NO;
    }
    if (![ad.adExperience isEqualToString:HyBidAdExperiencePerformanceValue]) {
        return NO;
    }
    if (!ad || !ad.iconSizeReduced) {
        return NO;
    }
    return YES;
}

- (CGSize)buttonSizeBasedOn:(HyBidAd *)ad {
    return [HyBidCloseButton buttonSizeBasedOn:ad];
}

+ (CGSize)buttonSizeBasedOn:(HyBidAd *)ad {
    return [HyBidCloseButton buttonShouldBeResized:ad] ? CGSizeMake(kCloseImageResizedSize, kCloseImageResizedSize)
                                                       : CGSizeMake(kCloseImageDefaultSize, kCloseImageDefaultSize);
}

+ (CGSize)buttonDefaultSize {
    return CGSizeMake(kCloseImageDefaultSize, kCloseImageDefaultSize);
}

+ (BOOL)isDefaultSize:(CGSize)size {
    return CGSizeEqualToSize(size, [HyBidCloseButton buttonDefaultSize]);
}

- (BOOL)isDefaultSize:(CGSize)size {
    return [HyBidCloseButton isDefaultSize:size];
}

@end
