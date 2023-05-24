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

#define kClickableAreaSize 50.0
#define kCloseImageSize 30.0

@implementation HyBidCloseButton {
    UIImageView *closeImageView;
}

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target {
    return [self initWithRootView:rootView action:action target:target useCustomClose:NO];
}

- (instancetype)initWithRootView:(UIView *)rootView action:(SEL)action target:(id)target useCustomClose:(BOOL)useCustomClose {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self setAccessibilityIdentifier:@"closeButton"];
        [self setAccessibilityLabel:@"Close Button"];
        
        UIImage *closeImage = [self bundledImageNamed:@"close"];
        if (!useCustomClose) {
            closeImageView = [[UIImageView alloc] initWithImage:closeImage];
            closeImageView.frame = CGRectMake(0, 0, kCloseImageSize, kCloseImageSize);
        }
        [self addSubview:closeImageView];
        
        // Setup constraints
        self.translatesAutoresizingMaskIntoConstraints = NO;
        closeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [rootView addSubview:self];
        
        NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithObjects:
                                                             [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kClickableAreaSize],
                                                             [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kClickableAreaSize], nil];
        
        if (@available(iOS 11.0, *)) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        }
        
        [NSLayoutConstraint activateConstraints:constraints];
        
        NSArray<NSLayoutConstraint *> *closeImageViewConstraints = @[
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseImageSize],
            [NSLayoutConstraint constraintWithItem:closeImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:kCloseImageSize]
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

@end
