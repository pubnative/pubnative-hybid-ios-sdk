// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidCloseButton.h"
#import "HyBidAdExperienceManager.h"
#import "HyBidAd+Internal.h"

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

// Kept out of a grown tap area so a control drawn by the creative next to the X stays reachable.
#define kAdjacentControlSize 18.0
#define kAdjacentControlGap 10.0

@implementation HyBidCloseButton {
    UIImageView *closeImageView;
    HyBidAd *pnAd;
    CGFloat pnTouchSize;
    CGFloat pnInitialTouchSize;
    BOOL pnIsSkipControl;
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
        pnIsSkipControl = showSkipButton;
        pnAd = ad;
        pnTouchSize = [HyBidCloseButton touchSizeBasedOn:ad];
        pnInitialTouchSize = [HyBidCloseButton initialTouchSizeBasedOn:ad];
        
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
        
        if (rootView) {
            if (@available(iOS 11.0, *)) {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
                [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
            } else {
                [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
                [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
            }
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

#pragma mark - Configurable tappable size

+ (CGFloat)touchSizeBasedOn:(HyBidAd *)ad {
    CGFloat drawn = [HyBidCloseButton buttonSizeBasedOn:ad].width;
    NSNumber *served = [ad closeButtonTouchSize];
    if (served == nil) {
        return drawn;
    }
    return MAX((CGFloat)served.integerValue, drawn);
}

+ (CGFloat)initialTouchSizeBasedOn:(HyBidAd *)ad {
    NSNumber *served = [ad closeButtonInitialTouchSize];
    if (served == nil) {
        return [HyBidCloseButton touchSizeBasedOn:ad];
    }
    return (CGFloat)served.integerValue;
}

+ (CGRect)touchAreaForBounds:(CGRect)bounds touchSize:(CGFloat)touchSize {
    if (touchSize <= 0) {
        return bounds;
    }
    CGFloat dx = (CGRectGetWidth(bounds) - touchSize) / 2.f;
    CGFloat dy = (CGRectGetHeight(bounds) - touchSize) / 2.f;
    return CGRectInset(bounds, dx, dy);
}

+ (CGRect)adjacentControlAreaForBounds:(CGRect)bounds towardsTheLeft:(BOOL)towardsTheLeft {
    CGFloat x = towardsTheLeft ? CGRectGetMinX(bounds) - kAdjacentControlGap - kAdjacentControlSize
                               : CGRectGetMaxX(bounds) + kAdjacentControlGap;
    return CGRectMake(x, CGRectGetMinY(bounds), kAdjacentControlSize, kAdjacentControlSize);
}

// The adjacent control area sits on the side of the X that faces the middle of the screen.
- (BOOL)isOnTheRightHalf {
    UIView *reference = self.window;
    if (!reference) {
        reference = self;
        while (reference.superview) {
            reference = reference.superview;
        }
    }
    CGRect frame = [self convertRect:self.bounds toView:reference];
    return CGRectGetMidX(frame) > CGRectGetMidX(reference.bounds);
}

- (CGFloat)activeTouchSize {
    if (self.touchSize) {
        return self.touchSize.doubleValue;
    }
    return pnAd.hasRegisteredClick ? pnTouchSize : pnInitialTouchSize;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (pnIsSkipControl) {
        return [super pointInside:point withEvent:event];
    }
    CGRect touchArea = [HyBidCloseButton touchAreaForBounds:self.bounds touchSize:[self activeTouchSize]];
    if (!CGRectContainsPoint(touchArea, point)) {
        return NO;
    }
    if (CGRectContainsPoint(self.bounds, point)) {
        return YES;
    }
    CGRect adjacentControlArea = [HyBidCloseButton adjacentControlAreaForBounds:self.bounds towardsTheLeft:[self isOnTheRightHalf]];
    return !CGRectContainsPoint(adjacentControlArea, point);
}

+ (BOOL)buttonShouldBeResized:(HyBidAd *)ad {
    if (![HyBidAdExperienceManager hasPerformanceExperience:ad]) {
        return NO;
    }
    if (!ad.iconSizeReduced) {
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
