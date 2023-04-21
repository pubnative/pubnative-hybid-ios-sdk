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
NSLayoutConstraint *contentViewWidthConstraint;
NSLayoutConstraint *contentViewHeightConstraint;
NSTimeInterval const PNLiteContentViewClosingTime = 3.0f;
CGFloat const PNLiteMaxContentInfoViewHeight = 20.0f;
CGFloat standardScreenWidth = 428.0;

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
        self.textView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.70];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textView setNumberOfLines: 1];
                
        self.iconView = [[UIImageView alloc] init];
        [self.iconView setContentMode:UIViewContentModeScaleAspectFit];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.iconView];
        [self addSubview:self.textView];
        
        [self addingConstraints];
        [PNLiteOrientationManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)addingConstraints {
    if(self.iconView){
        contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.f
                                                                   constant:PNLiteContentViewIcontDefaultSize];
        
        contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.f
                                                                    constant:PNLiteContentViewIcontDefaultSize];
        [self addConstraints:@[contentViewWidthConstraint, contentViewHeightConstraint]];
        [self setElementsOrientation: HyBidContentInfoHorizontalPositionLeft];
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
        NSURL *iconURL = [[NSURL alloc] initWithString:self.icon];
        
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

- (void)layoutSubviews {
    //adapting content info elements orientation after being added in a super view
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

- (void)configureView {
    
    NSString *positionString = [NSString stringWithFormat:@"%@ %@",
                                self.verticalPosition == HyBidContentInfoVerticalPositionTop ? @"top" : @"bottom",
                                self.horizontalPosition == HyBidContentInfoHorizontalPositionLeft ? @"left" : @"right"];

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
                }
                if (!self.link) {
                    self.link = @"https://pubnative.net/content-info";
                }
                self.openSize = self.iconView.frame.size.width + self.textView.frame.size.width;
                self.hidden = NO;
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
            self.adFeedbackView = [[HyBidAdFeedbackView alloc] initWithURL:self.link withZoneID:self.zoneID];
            self.adFeedbackView.delegate = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"adFeedbackViewIsReady" object:nil];
        }
    }
}

- (void)setElementsOrientation:(HyBidContentInfoHorizontalPosition) orientation {
    if(self.iconView && self.textView){
        NSArray *constraints = [self.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            if([object isEqual: contentViewWidthConstraint] || [object isEqual: contentViewHeightConstraint]){
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
    CGFloat newWidth = size.width;
    CGFloat newHeight = size.height < 0.0 || size.height > PNLiteMaxContentInfoViewHeight ? PNLiteContentViewIcontDefaultSize : size.height;
    [self removeConstraint: contentViewWidthConstraint];
    [self removeConstraint: contentViewHeightConstraint];
    [self setFrame: CGRectMake(0, 0, newWidth, newHeight)];
    if(self.iconView){
        if(self.iconView){
            contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.f
                                                                       constant:newWidth];
            
            contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.f
                                                                        constant:newHeight];
            
            [self addConstraints:@[contentViewWidthConstraint, contentViewHeightConstraint]];
        }
    }
}

- (void)open {
    self.isOpen = YES;
    [self layoutIfNeeded];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGPoint position = [self convertPoint:self.bounds.origin toView:window];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if(position.x >= (screenWidth / 2)) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, contentViewHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x - self.openSize, self.superview.frame.origin.y, self.openSize, self.superview.frame.size.height);
            if (@available(iOS 11.0, *)) {
                [self.trailingAnchor constraintEqualToAnchor:self.superview.safeAreaLayoutGuide.trailingAnchor].active = YES;
            } else {
                [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor].active = YES;
            }
        }
        
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, contentViewHeightConstraint.constant);
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
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentViewWidthConstraint.constant, contentViewHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x + self.openSize - contentViewWidthConstraint.constant, self.superview.frame.origin.y, contentViewWidthConstraint.constant, self.superview.frame.size.height);
        }
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, contentViewWidthConstraint.constant, contentViewHeightConstraint.constant);
        if(self.superview){
            self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, contentViewWidthConstraint.constant, self.superview.frame.size.height);
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
