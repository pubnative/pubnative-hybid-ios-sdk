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

#import "HyBidSkipOverlay.h"
#import "PNLiteVASTPlayerViewController.h"
#import "HyBidLiteCloseButton.h"
#import "PNLiteProgressLabel.h"
#define kCloseEventRegionSize 26
#define HYBID_MRAID_CLOSE_BUTTON_TAG 1001

@interface HyBidSkipOverlay ()

@property (nonatomic, assign) NSInteger skipOffset;

@property (nonatomic, strong) UILabel *skipOffsetLabel;
@property (nonatomic, strong) UIButton *skipButton;

@property (nonatomic, strong) NSTimer *skipTimer;
@property (nonatomic, assign) NSInteger skipTimeRemaining;
@property (nonatomic, assign) HyBidCountdownStyle countdownStyle;
@property (nonatomic, strong) PNLiteProgressLabel *progressLabel;

@end

@implementation HyBidSkipOverlay

- (id)initWithSkipOffset:(NSInteger)skipOffset
      withCountdownStyle:(HyBidCountdownStyle)countdownStyle
{
    if (self) {
        self.skipOffset = skipOffset;
        self.countdownStyle = countdownStyle;
        self.skipTimeRemaining = skipOffset;
        CGSize screenSize;
        CGFloat width;
        CGFloat height;
        switch(self.countdownStyle){
            case HyBidCountdownPieChart:{
                screenSize = UIScreen.mainScreen.bounds.size;
                width = kCloseEventRegionSize;
                height = kCloseEventRegionSize;
                self.padding = self.padding != 0 ? self.padding : 0;
                
                UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
                if (@available(iOS 11.0, *)) {
                    CGFloat safeAreaPadding = (window != nil)
                    ? window.safeAreaInsets.bottom
                    : (self.padding * 2);
                    
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, safeAreaPadding - height - self.padding, width, height)];
                } else {
                    // Fallback on earlier versions
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, height - (self.padding * 2), width, height)];
                }
                break;
            }
            case HyBidCountdownSkipOverlayTimer:{
                screenSize = UIScreen.mainScreen.bounds.size;
                width = screenSize.width / 5;
                height = 35;
                self.padding = self.padding != 0 ? self.padding : 32;
                
                UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
                if (@available(iOS 11.0, *)) {
                    CGFloat safeAreaPadding = (window != nil)
                    ? window.safeAreaInsets.bottom
                    : (self.padding * 2);
                    
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, safeAreaPadding - height - self.padding, width, height)];
                } else {
                    // Fallback on earlier versions
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, height - (self.padding * 2), width, height)];
                }
                break;
            }
            case HyBidCountdownSkipOverlayProgress:
                screenSize = UIScreen.mainScreen.bounds.size;
                width = screenSize.width / 2.4;
                height = 70;
                self.padding = self.padding != 0 ? self.padding : 32;
                
                UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
                if (@available(iOS 11.0, *)) {
                    CGFloat safeAreaPadding = (window != nil)
                    ? window.safeAreaInsets.bottom
                    : (self.padding * 2);
                    
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, (screenSize.height) - safeAreaPadding - height - self.padding, width, height)];
                } else {
                    // Fallback on earlier versions
                    self = [super initWithFrame:CGRectMake(screenSize.width - width, (screenSize.height) - height - (self.padding * 2), width, height)];
                }
                break;
        }
        [self setupUI];
    }
    return self;
}

- (void)addSkipButton
{
    if(self.skipButton){
        [self.skipButton removeFromSuperview];
    }
    switch(self.countdownStyle){
        case HyBidCountdownPieChart: {
            self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.skipButton setTag:HYBID_MRAID_CLOSE_BUTTON_TAG];
            self.skipButton.backgroundColor = [UIColor clearColor];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setAccessibilityIdentifier:@"closeButton"];
            [self.skipButton setAccessibilityLabel:@"Close Button"];
            if(self.progressLabel){
                [self.progressLabel removeFromSuperview];
            }
            [self addSubview:self.skipButton];
            
            // get button image from header file
            NSData* buttonData = [NSData dataWithBytesNoCopy:__HyBidLite_MRAID_CloseButton_png
                                                      length:___HyBidLite_MRAID_CloseButton_png_len
                                                freeWhenDone:NO];
            UIImage *closeButtonImage = [UIImage imageWithData:buttonData];
            [self.skipButton setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
            
            [self setCloseCircleCountdownConstraints];
            break;
        }
        case HyBidCountdownSkipOverlayTimer:
            self.skipButton = [[UIButton alloc] init];
            [self setBackgroundColor: UIColor.clearColor];
            [self.skipButton setImage:[self bundledImageNamed:@"PNLiteSkip"] forState:UIControlStateNormal];
            [self.skipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            
            [self.skipButton setAccessibilityIdentifier:@"skipButton"];
            [self.skipButton setAccessibilityLabel:@"Skip Button"];
            [self addSubview:self.skipButton];
            [self setSkipButtonConstraints];
            break;
        case HyBidCountdownSkipOverlayProgress:
            self.skipButton = [[UIButton alloc] init];
            [self.skipButton setTitle:@"Skip Ad" forState:UIControlStateNormal];
            [self.skipButton setImage:[self bundledImageNamed:@"PNLiteSkip"] forState:UIControlStateNormal];
            [self.skipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            
            [self.skipButton setAccessibilityIdentifier:@"skipButton"];
            [self.skipButton setAccessibilityLabel:@"Skip Button"];
            [self addSubview:self.skipButton];
            [self setSkipButtonConstraints];
            break;
    }
    
}

- (void)skipButtonTapped:(UIButton *)sender
{
    [self.delegate skipButtonTapped];
}

- (void)setupUI
{
    switch(self.countdownStyle){
        case HyBidCountdownPieChart:
            if(!self.progressLabel) {
                self.progressLabel = [[PNLiteProgressLabel alloc] initWithFrame:self.bounds];
                self.progressLabel.frame = self.bounds;
                self.progressLabel.borderWidth = 3.0;
                self.progressLabel.colorTable = @{
                    NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelTrackColor):[UIColor clearColor],
                    NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelProgressColor):[UIColor whiteColor],
                    NSStringFromPNProgressLabelColorTableKey(PNLiteColorTable_ProgressLabelFillColor):[UIColor clearColor]
                };
                self.progressLabel.textColor = [UIColor whiteColor];
                self.progressLabel.shadowColor = [UIColor darkGrayColor];
                self.progressLabel.shadowOffset = CGSizeMake(1, 1);
                self.progressLabel.textAlignment = NSTextAlignmentCenter;
                self.progressLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
                
                [self.progressLabel setProgress:0.0f];
                [self addSubview:self.progressLabel];
            }
            self.progressLabel.text = [NSString stringWithFormat:@"%ld", (long)self.skipOffset];
            break;
        case HyBidCountdownSkipOverlayTimer:{
            [self setBackgroundColor: [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.7]];
            [self.layer setMasksToBounds:YES];
            [self.layer setCornerRadius:4];
            [self setUserInteractionEnabled:YES];

            self.skipOffsetLabel = [[UILabel alloc] init];
            [self.skipOffsetLabel setNumberOfLines:0];
            
            NSUInteger minutes = (self.skipOffset / 60) % 60;
            NSUInteger seconds = self.skipOffset % 60;

            NSString *formattedTime = [NSString stringWithFormat:@"%02lu:%02lu", minutes, (unsigned long)seconds];
            NSString *skipOffsetText = [[NSString alloc] initWithFormat: @"%@", formattedTime];
            [self.skipOffsetLabel setText: skipOffsetText];
            [self.skipOffsetLabel setTextColor: [UIColor whiteColor]];
            [self addSubview:self.skipOffsetLabel];
            [self setLabelConstraints];
            break;
        }
        case HyBidCountdownSkipOverlayProgress:
            [self setBackgroundColor: [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.7]];
            [self.layer setMasksToBounds:YES];
            [self.layer setCornerRadius:4];
            [self setUserInteractionEnabled:YES];

            self.skipOffsetLabel = [[UILabel alloc] init];
            [self.skipOffsetLabel setNumberOfLines:0];
            
            NSString *skipOffsetText = [[NSString alloc] initWithFormat:@"You can skip ad in %lds", (long)self.skipOffset];
            [self.skipOffsetLabel setText: skipOffsetText];
            [self.skipOffsetLabel setTextColor: [UIColor whiteColor]];
            [self addSubview:self.skipOffsetLabel];
            [self setLabelConstraints];
            break;
    }
}

- (void)updateSkipOffsetOnProgressTick:(NSInteger)newSkipOffset
{
    switch(self.countdownStyle){
        case HyBidCountdownPieChart:{
            Float64 currentSkippablePlayedPercent = 0;
            if (newSkipOffset > 0 && newSkipOffset < self.skipOffset) {
                currentSkippablePlayedPercent = (double) (self.skipOffset - newSkipOffset) / (double) self.skipOffset;
            }
            [self.progressLabel setProgress: currentSkippablePlayedPercent];
            self.progressLabel.text = [NSString stringWithFormat:@"%ld", (long)newSkipOffset];
            break;
        }
        case HyBidCountdownSkipOverlayTimer:{
            NSUInteger minutes = (newSkipOffset / 60) % 60;
            NSUInteger seconds = newSkipOffset % 60;

            NSString *formattedTime = [NSString stringWithFormat:@"%02lu:%02lu", minutes, (unsigned long)seconds];
            NSString *skipOffsetText = [[NSString alloc] initWithFormat: @"%@", formattedTime];
            [self.skipOffsetLabel setText: skipOffsetText];
            break;
        }
        case HyBidCountdownSkipOverlayProgress:{
            NSString *skipOffsetText = [[NSString alloc] initWithFormat:@"You can skip ad in %lds", (long)newSkipOffset];
            [self.skipOffsetLabel setText: skipOffsetText];
            break;
        }
    }
}

- (void)dealloc
{
    self.skipTimer = nil;
    self.skipOffsetLabel = nil;
}

// MARK: - Timer manipulations

- (void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds withTimerState:(HyBidTimerState)timerState
{
    if (seconds <= 0 && self.skipTimeRemaining <= 0) {
        [self skipTimerFinished];
        return;
    }
    
    switch (timerState) {
        case HyBidTimerState_Start:
            if (self.skipTimeRemaining != -1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.skipTimeRemaining = seconds;
                    [self updateSkipOffsetOnProgressTick:self.skipTimeRemaining];
                    self.skipTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(skipTimerTicked) userInfo:nil repeats:YES];
                });
            }
            break;
        case HyBidTimerState_Pause:
            if ([self.skipTimer isValid]) {
                [self.skipTimer invalidate];
                self.skipTimer = nil;
                self.skipTimeRemaining = seconds;
            }
            break;
        case HyBidTimerState_Stop:
            [self.skipTimer invalidate];
            self.skipTimer = nil;
            self.skipTimeRemaining = -1;
            [self skipTimerFinished];
            break;
    }
}

- (NSInteger)getRemainingTime {
    return self.skipTimeRemaining;
}

- (void)skipTimerTicked
{
    self.skipTimeRemaining -= 1;
    [self updateSkipOffsetOnProgressTick:self.skipTimeRemaining];
    
    if (self.skipTimeRemaining <= 0) {
        [self skipTimerFinished];
    }
}

- (void)skipTimerFinished
{
    [self.skipTimer invalidate];
    self.skipTimer = nil;
    self.skipTimeRemaining = -1;
    
    [self.skipOffsetLabel removeFromSuperview];
    [self addSkipButton];
}

// MARK: - Helpers

- (UIImage*)bundledImageNamed:(NSString*)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

// MARK: - Constraints

- (void)setLabelConstraints
{
    [self.skipOffsetLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [[self.skipOffsetLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:8] setActive:YES];
    [[self.skipOffsetLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8] setActive:YES];
    
    [[self.skipOffsetLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12] setActive:YES];
    [[self.skipOffsetLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12] setActive:YES];
}

- (void)setSkipButtonConstraints
{
    [self.skipButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [[self.skipButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:8] setActive:YES];
    [[self.skipButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8] setActive:YES];
    
    [[self.skipButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12] setActive:YES];
    [[self.skipButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12] setActive:YES];
}

- (void)setCloseCircleCountdownConstraints
{
    [self.skipButton setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [[self.skipButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
    [[self.skipButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
    
    [[self.skipButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0] setActive:YES];
    [[self.skipButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0] setActive:YES];
}

@end
