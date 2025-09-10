// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidSkipOverlay.h"
#import "PNLiteProgressLabel.h"
#import "HyBidCloseButton.h"

#define HYBID_MRAID_CLOSE_BUTTON_TAG 1001

@interface HyBidSkipOverlay ()

@property (nonatomic, assign) NSInteger skipOffset;

@property (nonatomic, strong) UILabel *skipOffsetLabel;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) HyBidCloseButton *closeButton;
@property (nonatomic, strong) NSTimer *skipTimer;
@property (nonatomic, assign) NSInteger skipTimeRemaining;
@property (nonatomic, assign) HyBidCountdownStyle countdownStyle;
@property (nonatomic, strong) PNLiteProgressLabel *progressLabel;
@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic) CGSize buttonSize;

@end

@implementation HyBidSkipOverlay

- (id)initWithSkipOffset:(NSInteger)skipOffset
      withCountdownStyle:(HyBidCountdownStyle)countdownStyle
      withContentInfoPositionTopLeft:(BOOL)isContentInfoInTopLeftPosition
      withShouldShowSkipButton:(BOOL)shouldShowSkipButton
                      ad:(HyBidAd *)ad
{
    if (self) {
        self.skipOffset = skipOffset;
        //set default value to get the old behaviour
        self.countdownStyle = HyBidCountdownPieChart;
        self.skipTimeRemaining = skipOffset;
        self.isContentInfoInTopLeftPosition = isContentInfoInTopLeftPosition;
        self.shouldShowSkipButton = shouldShowSkipButton;
        self.ad = ad;
        CGSize screenSize;
        CGFloat width;
        CGFloat height;
        self.buttonSize = [HyBidCloseButton buttonDefaultSize];
        switch(self.countdownStyle){
            case HyBidCountdownPieChart:{
                screenSize = UIScreen.mainScreen.bounds.size;
                width = self.buttonSize.width;
                height = self.buttonSize.height;
                self.padding = self.padding != 0 ? self.padding : 0;
                
                UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
                if (@available(iOS 11.0, *)) {
                    CGFloat safeAreaPadding = (window != nil)
                    ? window.safeAreaInsets.bottom
                    : (self.padding * 2);
                    
                    self = [super initWithFrame:CGRectMake(0, safeAreaPadding - height - self.padding, width, height)];
                } else {
                    self = [super initWithFrame:CGRectMake(0, height - (self.padding * 2), width, height)];
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

- (void)addCloseOverlayButton {
    if (!self.closeButton) {
        self.closeButton = [[HyBidCloseButton alloc] initWithRootView:self action:@selector(skipButtonTapped:) target:self ad:self.ad];
    }
    
    [self.closeButton setTag:HYBID_MRAID_CLOSE_BUTTON_TAG];
    
    if (self.progressLabel) {
        [self.progressLabel removeFromSuperview];
    }
    
    [self addSubview:self.closeButton];
    [self setConstraints:self.closeButton];
}


- (void)addSkipOverlayButton {
    if(self.skipButton){
        [self.skipButton removeFromSuperview];
    }
    self.buttonSize = [HyBidCloseButton buttonSizeBasedOn:self.ad];
    switch(self.countdownStyle){
        case HyBidCountdownPieChart: {
            CGFloat skipButtonX = self.buttonSize.width - self.buttonSize.height;
            self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(skipButtonX, 0, self.buttonSize.width, self.buttonSize.height)];
            [self setBackgroundColor: UIColor.clearColor];
            [self.skipButton setImage:[self bundledImageNamed:@"skip"] forState:UIControlStateNormal];
            [self.skipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            if ([HyBidCloseButton isDefaultSize:self.buttonSize]) {
                [self.skipButton setAccessibilityIdentifier:@"skipButton"];
                [self.skipButton setAccessibilityLabel:@"Skip Button"];
            } else {
                [self.skipButton setAccessibilityIdentifier:@"skipButtonSmall"];
                [self.skipButton setAccessibilityLabel:@"Skip Button Small"];
            }
            if(self.progressLabel){
                [self.progressLabel removeFromSuperview];
            }
            [self addSubview:self.skipButton];
            break;
        }
        case HyBidCountdownSkipOverlayTimer:
            self.skipButton = [[UIButton alloc] init];
            [self setBackgroundColor: UIColor.clearColor];
            [self.skipButton setImage:[self bundledImageNamed:@"skip"] forState:UIControlStateNormal];
            [self.skipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            
            if ([HyBidCloseButton isDefaultSize:self.buttonSize]) {
                [self.skipButton setAccessibilityIdentifier:@"skipButton"];
                [self.skipButton setAccessibilityLabel:@"Skip Button"];
            } else {
                [self.skipButton setAccessibilityIdentifier:@"skipButtonSmall"];
                [self.skipButton setAccessibilityLabel:@"Skip Button Small"];
            }
            
            if(self.skipOffsetLabel){
                [self.skipOffsetLabel removeFromSuperview];
            }

            [self removeConstraints: self.constraints];
            [self addSubview:self.skipButton];
            [self setConstraints:self.skipButton];
            break;
        case HyBidCountdownSkipOverlayProgress:
            self.skipButton = [[UIButton alloc] init];
            [self.skipButton setTitle:@"Skip Ad" forState:UIControlStateNormal];
            [self.skipButton setImage:[self bundledImageNamed:@"skip"] forState:UIControlStateNormal];
            [self.skipButton setImageEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
            [self.skipButton addTarget:self action:@selector(skipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.skipButton setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            
            if ([HyBidCloseButton isDefaultSize:self.buttonSize]) {
                [self.skipButton setAccessibilityIdentifier:@"skipButton"];
                [self.skipButton setAccessibilityLabel:@"Skip Button"];
            } else {
                [self.skipButton setAccessibilityIdentifier:@"skipButtonSmall"];
                [self.skipButton setAccessibilityLabel:@"Skip Button Small"];
            }
            
            if(self.skipOffsetLabel){
                [self.skipOffsetLabel removeFromSuperview];
            }

            [self removeConstraints: self.constraints];
            [self addSubview:self.skipButton];
            [self setConstraints:self.skipButton];
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
            if (!self.progressLabel) {
                CGFloat x = self.bounds.size.width - self.buttonSize.width;
                CGFloat y = 0;
                self.progressLabel = [[PNLiteProgressLabel alloc] initWithFrame:CGRectMake(x, y, self.buttonSize.width, self.buttonSize.height)];
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
                self.progressLabel.font = [UIFont fontWithName:@"Helvetica" size:10]; // Adjust the font size as needed
                
                [self addSubview:self.progressLabel];
                //setting progress animation for the first second of the countdown
                [self.progressLabel setProgress: (1.0 / self.skipOffset) timing:0 duration:1 delay:0];
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
            [self setConstraints:self.skipOffsetLabel];
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
            [self setConstraints:self.skipOffsetLabel];
            break;
    }
}

- (void)updateSkipOffsetOnProgressTick:(NSInteger)newSkipOffset
{
    switch(self.countdownStyle){
        case HyBidCountdownPieChart:{
            Float64 currentSkippablePlayedPercent = 0;
            if (newSkipOffset > 0 && newSkipOffset < self.skipOffset) {
                // counting - 1 second to finish the counting reaching second 0 and completing filling the circle
                currentSkippablePlayedPercent = (double) (self.skipOffset - (newSkipOffset - 1)) / (double) self.skipOffset;
            } else if(newSkipOffset == 0) {
                currentSkippablePlayedPercent = 1;
            }
            
            // avoiding restarting the progress of the pie chart during the first second
            if(self.skipOffset != newSkipOffset){
                [self.progressLabel setProgress: currentSkippablePlayedPercent timing:0 duration:1 delay:0];
            }
            
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
    self.skipOffsetLabel = nil;
    self.skipButton = nil;
    [self.skipTimer invalidate];
    self.skipTimer = nil;
    self.progressLabel = nil;
}

// MARK: - Timer manipulations

- (void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds withTimerState:(HyBidTimerState)timerState
{
    if (seconds <= 0 && self.skipTimeRemaining <= 0) {
        [self updateSkipOffsetOnProgressTick:self.skipTimeRemaining];
        [self skipTimerFinished];
        return;
    }
    
    switch (timerState) {
        case HyBidTimerState_Start:
            if (self.skipTimeRemaining != -1) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.skipTimeRemaining = seconds;
                    [weakSelf updateSkipOffsetOnProgressTick:self.skipTimeRemaining];
                    if(!weakSelf.skipTimer){
                        weakSelf.skipTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                          target:weakSelf
                                                                        selector:@selector(skipTimerTicked)
                                                                        userInfo:nil
                                                                         repeats:YES];
                        [[NSRunLoop mainRunLoop] addTimer:weakSelf.skipTimer forMode:NSRunLoopCommonModes];
                    }
                });
            }
            break;
        case HyBidTimerState_Pause:
            if ([self.skipTimer isValid]) {
                [self invalidateSkipTimer];
                self.skipTimeRemaining = seconds;
            }
            break;
        case HyBidTimerState_Stop:{
            [self invalidateSkipTimer];
            self.skipTimeRemaining = -1;
            [self skipTimerFinished];
            break;
            
        }
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
    [self invalidateSkipTimer];
    self.skipTimeRemaining = -1;
    [self.skipOffsetLabel removeFromSuperview];
    if (self.shouldShowSkipButton)  {
        [self addSkipOverlayButton];
    } else {
        self.isCloseButtonShown = YES;
        [self addCloseOverlayButton];
    }
    self.buttonSize = [HyBidCloseButton buttonSizeBasedOn:self.ad];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.buttonSize.width, self.buttonSize.height);
    if ([self.delegate respondsToSelector:@selector(skipTimerCompleted)]) {
        [self.delegate skipTimerCompleted];
    }
}

- (void)invalidateSkipTimer
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.skipTimer invalidate];
        weakSelf.skipTimer = nil;
    });
}

// MARK: - Helpers

- (UIImage*)bundledImageNamed:(NSString*)name {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:name ofType:@"png"];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

// MARK: - Constraints

- (void)setConstraints:(UIView*)view
{
    [view setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    [[view.topAnchor constraintEqualToAnchor:self.topAnchor constant:0] setActive:YES];
    [[view.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0] setActive:YES];
    
    [[view.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0] setActive:YES];
    [[view.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0] setActive:YES];
}

- (void)addSkipOverlayViewIn:(UIView *)adView delegate:(id<HyBidSkipOverlayDelegate>)delegate
{
    if([adView isEqual: nil] || adView == nil || [adView.subviews containsObject:self]){
        return;
    }
    
    HyBidSkipOverlay* skipOverlayView = self;
    if(!skipOverlayView){
        skipOverlayView = [[HyBidSkipOverlay alloc] initWithSkipOffset:self.skipOffset withCountdownStyle: self.countdownStyle withContentInfoPositionTopLeft:self.isContentInfoInTopLeftPosition withShouldShowSkipButton:self.shouldShowSkipButton ad:self.ad];
    }
    
    skipOverlayView.delegate = delegate;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [adView addSubview: skipOverlayView];
        [skipOverlayView updateTimerStateWithRemainingSeconds:weakSelf.skipOffset withTimerState:HyBidTimerState_Start];
        if ([weakSelf.delegate respondsToSelector:@selector(skipOverlayStarts)]) {
            [weakSelf.delegate skipOverlayStarts];
        }
    });

    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSArray<NSLayoutConstraint *> *positionConstraints;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    positionConstraints = [self getSkipOverlayTopPositionConstraintsIn:adView];
    
    [constraints addObjectsFromArray: [self getSkipOverlaySizeConstraints]];
    [constraints addObjectsFromArray: positionConstraints];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSLayoutConstraint activateConstraints: constraints];
    });
}


- (NSArray<NSLayoutConstraint *> *)getSkipOverlaySizeConstraints
{
    return @[[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant: self.frame.size.width],[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant: self.frame.size.height]];
}

- (NSArray<NSLayoutConstraint *> *)getSkipOverlayTopPositionConstraintsIn:(UIView*)adView
{

    if(self.isContentInfoInTopLeftPosition){
        if (@available(iOS 11.0, *)) {
            return @[
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:adView.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:adView.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]
            ];
        } else {
            return @[
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:adView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:adView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]
            ];
        }
    } else {
        if (@available(iOS 11.0, *)) {
            return @[
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:adView.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:adView.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]
            ];
        } else {
            return @[
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:adView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f],
                [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:adView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]
            ];
        }
    }
}

@end
