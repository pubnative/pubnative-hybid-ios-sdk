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

#import "HyBidContentInfoView.h"
#import "PNLiteMeta.h"
#import "PNLiteOrientationManager.h"
#import "HyBidAdFeedbackView.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <HyBid/HyBid-Swift.h>
#else
    #import "HyBid-Swift.h"
#endif

CGFloat PNLiteContentViewIcontDefaultSize = 15.0f;
NSLayoutConstraint *contentInfoViewIconWidthConstraint;
NSLayoutConstraint *contentInfoViewIconHeightConstraint;
NSTimeInterval const PNLiteContentViewClosingTime = 3.0f;
CGFloat standardScreenWidth = 428.0;
CGFloat const HyBidIconMaximumWidth = 120.0f;
CGFloat const HyBidIconMaximumHeight = 30.0f;

@interface HyBidContentInfoView () <PNLiteOrientationManagerDelegate, HyBidAdFeedbackViewDelegate>

@property (nonatomic, strong) UILabel *textView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) CGFloat openSize;
@property (nonatomic, strong) NSTimer *closeTimer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) HyBidAdFeedbackView *adFeedbackView;
@property (nonatomic, assign) BOOL closeButtonTapped;
@property (nonatomic, assign) BOOL adFeedbackViewRequested;
@property (nonatomic, assign) CGFloat xPosition;

@end

@implementation HyBidContentInfoView

- (void)dealloc {
    [self.closeTimer invalidate];
    self.closeTimer = nil;
    [self.textView removeFromSuperview];
    self.textView = nil;
    [self.iconView removeFromSuperview];
    self.iconView = nil;
    self.iconImage = nil;
    
    [self.tapRecognizer removeTarget:self action:@selector(handleTap:)];
    [self removeGestureRecognizer:self.tapRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tapRecognizer = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, PNLiteContentViewIcontDefaultSize, PNLiteContentViewIcontDefaultSize)];
        self.backgroundColor = [UIColor colorWithRed: 0.95 green: 0.98 blue: 1.00 alpha: 0.70];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.f;
        
        self.hidden = YES;
        self.isOpen = NO;
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.tapRecognizer];
        self.textView = [[UILabel alloc] init];
        [self.textView setFont:[self.textView.font fontWithSize:10]];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textView setNumberOfLines: 1];
                
        self.iconView = [[UIImageView alloc] init];
        [self.iconView setFrame: self.frame];
        [self.iconView setContentMode:UIViewContentModeScaleAspectFit];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.iconView];
        [self addSubview:self.textView];

        [PNLiteOrientationManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)addingConstraints {
    if(self.iconView){
        contentInfoViewIconWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.f
                                                                   constant:self.iconView.frame.size.width];
        
        contentInfoViewIconHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.f
                                                                    constant:self.iconView.frame.size.height];
        [self addConstraints:@[contentInfoViewIconWidthConstraint, contentInfoViewIconHeightConstraint]];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *image))completionBlock
{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                completionBlock(YES, data);
            } else{
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
                completionBlock(NO, nil);
            }
        }];
        [dataTask resume];
    });
}

- (void)downloadCustomContentInfoViewIconWithCompletionBlock:(void (^)(BOOL isFinished))completionBlock
{
    if (self.icon != nil && [self.icon length] > 0) {
        NSString *trimmedIcon;
        NSURL *iconURL;
        if ([self.icon rangeOfString:@" \n..."].location != NSNotFound) {
            trimmedIcon = [self.icon stringByReplacingOccurrencesOfString:@" \n..." withString:@""];
            iconURL = [[NSURL alloc] initWithString:trimmedIcon];
        }else {
            iconURL = [[NSURL alloc] initWithString:self.icon];
        }
        if(iconURL){
            [self downloadImageWithURL:iconURL completionBlock:^(BOOL succeeded, NSData *data) {
                if (data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.iconImage = [UIImage imageWithData: data];
                        completionBlock(YES);
                    });
                } else {
                    completionBlock(NO);
                }
            }];
        } else{
            completionBlock(NO);
        }
    } else {
        completionBlock(YES);
    }
}

- (void)didMoveToWindow
{
    if (!self.closeButtonTapped) {
        [self downloadCustomContentInfoViewIconWithCompletionBlock:^(BOOL isFinished) {
            [self configureView];
        }];
    }
}

- (void)configureView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addingConstraints];
    });
    
//    NSString *positionString = [NSString stringWithFormat:@"%@ %@",
//                                self.verticalPosition == HyBidContentInfoVerticalPositionTop ? @"top" : @"bottom",
//                                self.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ? @"left" : @"right"];

    // ContentInfo: Hardcoding Accessibility ID (xPosition to left and yPosition to bottom)
    NSString* positionString = @"bottom left";
    [self.iconView setIsAccessibilityElement:YES];
    [self.iconView setAccessibilityLabel:[NSString stringWithFormat:@"contentInfoIconView - %@", positionString]];
    
    [self.textView setIsAccessibilityElement:YES];
    [self.textView setAccessibilityLabel:[NSString stringWithFormat:@"contentInfoTextView - %@", positionString]];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self) {
            if (self.iconView && self.textView) {
                [self.iconView.superview layoutIfNeeded];
                if (self.text) {
                    self.textView.text = self.text;
                } else {
                    self.textView.text = @"Learn about this ad";
                }
                [self.textView sizeToFit];
                if (self.iconImage && [self.iconImage isMemberOfClass:[UIImage class]]) {
                    [self.iconView setImage:self.iconImage];
                } else {
                    NSString *path = [[NSBundle bundleForClass:[self class]]pathForResource:@"VerveContentInfo" ofType:@"png"];
                    UIImage* image = [[UIImage alloc] initWithContentsOfFile: path];
                    self.iconImage = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.iconView setImage:self.iconImage];
                    });
                    self.link = @"https://pubnative.net/content-info";
                }
                if (!self.link) {
                    self.link = @"https://pubnative.net/content-info";
                }
                self.openSize = self.iconView.frame.size.width + self.textView.frame.size.width;
                self.hidden = NO;
            }
        }
    });
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint position = [self convertPoint:self.bounds.origin toView:window];
        if(!weakSelf.xPosition){
            weakSelf.xPosition = position.x;
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            if (screenWidth > standardScreenWidth) {
                [self setElementsOrientation: weakSelf.xPosition >= (screenWidth / 2.0) ? HyBidContentInfoHorizontalPositionRight : HyBidContentInfoHorizontalPositionLeft];
            } else {
                [self setElementsOrientation: weakSelf.xPosition >= (screenWidth / 3.0) ? HyBidContentInfoHorizontalPositionRight : HyBidContentInfoHorizontalPositionLeft];
            }
        }
    });
}

- (void)stopCloseTimer {
    [self.closeTimer invalidate];
    self.closeTimer = nil;
}

- (void)startCloseTimer {
    self.closeTimer = [NSTimer scheduledTimerWithTimeInterval:PNLiteContentViewClosingTime target:self selector:@selector(closeFromTimer) userInfo:nil repeats:NO];
}

- (void)closeFromTimer {
    if ([self.closeTimer isValid]) {
        [self close];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (self.link != nil && [self.link length] > 0) {
        if (self.clickAction == HyBidContentInfoClickActionExpand) {
            if (sender.state == UIGestureRecognizerStateEnded) {
                if(self.isOpen) {
                    [self handleDisplay];
                } else {
                    [self open];
                }
            }
        } else {
            [self handleDisplay];
        }
    }
}

- (void)handleDisplay {
    if (self.display == HyBidContentInfoDisplaySystem) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link] options:@{} completionHandler:nil];
    } else {
        if (!self.adFeedbackViewRequested) {
            self.adFeedbackViewRequested = YES;
            if ([self.link rangeOfString:@" \n..."].location != NSNotFound) {
                NSString*link = [self.link stringByReplacingOccurrencesOfString:@" \n..." withString:@""];
                self.adFeedbackView = [[HyBidAdFeedbackView alloc] initWithURL:link withZoneID:self.zoneID];
            }else {
                self.adFeedbackView = [[HyBidAdFeedbackView alloc] initWithURL:self.link withZoneID:self.zoneID];
            }
            self.adFeedbackView.delegate = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"adFeedbackViewIsReady" object:nil];
        }
    }
}

- (void)setElementsOrientation:(HyBidContentInfoHorizontalPosition) orientation {
    if(self.iconView && self.textView){
        NSArray *constraints = [self.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            if([object isEqual: contentInfoViewIconWidthConstraint] || [object isEqual: contentInfoViewIconHeightConstraint]){
                return NO;
            }
            return YES;
        }]];
        
        [self removeConstraints: constraints];
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.iconView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.f
                                                             constant:0.f]]];
    }
    if(orientation == HyBidContentInfoHorizontalPositionRight){
        if(self.iconView && self.textView){
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.textView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.iconView
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.f
                                                                 constant:0.f],
                                   [NSLayoutConstraint constraintWithItem:self.textView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.f
                                                                 constant:0.f],
                                   [NSLayoutConstraint constraintWithItem:self.iconView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.f
                                                                 constant:0.f]]];
        }
    } else {
        if(self.iconView && self.textView){
            [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.textView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.iconView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.f
                                                                 constant:0.f],
                                   [NSLayoutConstraint constraintWithItem:self.textView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.f
                                                                 constant:0.f],
                                   [NSLayoutConstraint constraintWithItem:self.iconView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.f
                                                                 constant:0.f]]];
        }
    }
}

- (void)setIconSize:(CGSize) size {
    CGSize newSize = [self getValidIconSizeWith:CGSizeMake(size.width, size.height)];
    
    [self removeConstraint: contentInfoViewIconWidthConstraint];
    [self removeConstraint: contentInfoViewIconHeightConstraint];

    [self setFrame: CGRectMake(0, 0, newSize.width, newSize.height)];
    
    if(self.iconView){
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        contentInfoViewIconWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.f
                                                                           constant:newSize.width];
        
        contentInfoViewIconHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.f
                                                                            constant:newSize.height];
        
        [self addConstraints:@[contentInfoViewIconWidthConstraint, contentInfoViewIconHeightConstraint]];
    }
}

- (CGSize)getValidIconSizeWith:(CGSize)size
{
    int32_t width = size.width;
    int32_t height = size.height;
    
    // condition to equalize behavior on Android integer data type
    if(width == -1 || width == 2147483647 || height == -1 || height == 2147483647){
        return CGSizeMake(PNLiteContentViewIcontDefaultSize, PNLiteContentViewIcontDefaultSize);
    }
    
    if(width <= 0){
        width = PNLiteContentViewIcontDefaultSize;
    }
    
    if(height <= 0){
        height = PNLiteContentViewIcontDefaultSize;
    }
    
    if (height > HyBidIconMaximumHeight || width > HyBidIconMaximumWidth) {
        CGFloat aspectRatio = width / height;
        
        if (aspectRatio == 1.0) {
            width = HyBidIconMaximumHeight < HyBidIconMaximumWidth ? HyBidIconMaximumHeight : HyBidIconMaximumWidth;
            height = HyBidIconMaximumHeight < HyBidIconMaximumWidth ? HyBidIconMaximumHeight : HyBidIconMaximumWidth;
            
        } else if (width > height) {
            if (width > HyBidIconMaximumWidth) {
                height = (int32_t) (HyBidIconMaximumWidth * ((CGFloat) height / (CGFloat) width));
                width = HyBidIconMaximumWidth;
                height = height > HyBidIconMaximumHeight ? HyBidIconMaximumHeight : height;
            }
        } else {
            width = (int32_t) (HyBidIconMaximumHeight * ((CGFloat) width / (CGFloat) height));
            height = HyBidIconMaximumHeight;
            width = width > HyBidIconMaximumWidth ? HyBidIconMaximumWidth : width;
        }
    }
    
    return CGSizeMake(width, height);
}

- (void)open {
    self.isOpen = YES;
    [self layoutIfNeeded];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGPoint position = [self convertPoint:self.bounds.origin toView:window];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if(position.x >= (screenWidth / 2)) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, contentInfoViewIconHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x - self.openSize, self.superview.frame.origin.y, self.openSize, self.superview.frame.size.height);
            if (@available(iOS 11.0, *)) {
                [self.trailingAnchor constraintEqualToAnchor:self.superview.safeAreaLayoutGuide.trailingAnchor].active = YES;
            } else {
                [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor].active = YES;
            }
        }
        
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, contentInfoViewIconHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.openSize, self.superview.frame.size.height);
        }
    }
    [self resizeSuperView];
    [self layoutIfNeeded];
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
    [self startCloseTimer];
}

- (void)close {
    self.isOpen = NO;
    [self stopCloseTimer];
    [self layoutIfNeeded];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGPoint position = [self convertPoint:self.bounds.origin toView:window];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if(position.x >= (screenWidth / 2)) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentInfoViewIconWidthConstraint.constant, contentInfoViewIconHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x + self.openSize - contentInfoViewIconWidthConstraint.constant, self.superview.frame.origin.y, contentInfoViewIconWidthConstraint.constant, self.superview.frame.size.height);
        }
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentInfoViewIconWidthConstraint.constant, contentInfoViewIconHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, contentInfoViewIconWidthConstraint.constant, self.superview.frame.size.height);
        }
    }
    [self resizeSuperView];
    [self layoutIfNeeded];
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
    self.closeButtonTapped = YES;
}

- (void)resizeSuperView {
    if(self.superview){
        self.superview.translatesAutoresizingMaskIntoConstraints = false;
        NSArray *constraints = [self.superview constraints];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", NSLayoutAttributeWidth];
        NSArray *filteredArray = [constraints filteredArrayUsingPredicate:predicate];
        if(filteredArray.count > 0){
              [self.superview removeConstraints: filteredArray];
        }
        [self.superview.widthAnchor constraintGreaterThanOrEqualToConstant: self.frame.size.width].active = YES;
    }
}

#pragma mark PNLiteOrientationManagerDelegate

- (void)orientationManagerDidChangeOrientation {
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
}

#pragma mark HyBidAdFeedbackViewDelegate

- (void)adFeedbackViewDidLoad {
    [self.adFeedbackView show];
    self.adFeedbackViewRequested = NO;
    [self close];
}

- (void)adFeedbackViewDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Feedback failed with error: %@",error.localizedDescription]];
    self.adFeedbackViewRequested = NO;
    [self close];
}

@end
