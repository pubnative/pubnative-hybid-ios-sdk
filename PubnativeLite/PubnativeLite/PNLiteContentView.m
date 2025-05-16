// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteContentInfoView.h"
#import "PNLiteMeta.h"
#import "PNLiteOrientationManager.h"

CGFloat const kPNLiteContentViewHeight = 15.0f;
CGFloat const kPNLiteContentViewWidth = 15.0f;
NSTimeInterval const kPNLiteContentViewClosingTime = 3.0f;

@interface PNLiteContentInfoView () <PNLiteOrientationManagerDelegate>

@property (nonatomic, strong) UILabel *textView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) CGFloat openSize;
@property (nonatomic, strong) NSTimer *closeTimer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation PNLiteContentInfoView

- (void)dealloc
{
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, kPNLiteContentViewWidth, kPNLiteContentViewHeight)];
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2.f;
        
        self.isOpen = NO;
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.tapRecognizer];
        self.textView = [[UILabel alloc] init];
        [self.textView setFont:[self.textView.font fontWithSize:10]];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.iconView];
        [self addSubview:self.textView];
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNLiteContentViewHeight],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNLiteContentViewWidth],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.iconView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:kPNLiteContentViewHeight],
                               [NSLayoutConstraint constraintWithItem:self.textView
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
                               [NSLayoutConstraint constraintWithItem:self.textView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f]]];
        
        [PNLiteOrientationManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    self.hidden = YES;
    
    if(self.iconImage == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *iconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.icon]];
            self.iconImage = [UIImage imageWithData:iconData];
            [self configureView];
        });
    } else {
        [self configureView];
    }
}

- (void)configureView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = self.text;
        [self.textView sizeToFit];
        [self.iconView setImage:self.iconImage];
        self.openSize = self.iconView.frame.size.width + self.textView.frame.size.width;
        self.hidden = NO;
    });
}

- (void)stopCloseTimer
{
    [self.closeTimer invalidate];
    self.closeTimer = nil;
}

- (void)startCloseTimer
{
    self.closeTimer = [NSTimer scheduledTimerWithTimeInterval:kPNLiteContentViewClosingTime target:self selector:@selector(closeFromTimer) userInfo:nil repeats:NO];
}

-(void)closeFromTimer
{
    if ([self.closeTimer isValid]) {
        [self close];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.isOpen) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
            [self close];
        } else {
            [self open];
        }
    }
}

- (void)open
{
    self.isOpen = YES;
    [self layoutIfNeeded];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.openSize, self.frame.size.height);
    [self layoutIfNeeded];
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
    [self startCloseTimer];
}

- (void)close
{
    self.isOpen = NO;
    [self stopCloseTimer];
    [self layoutIfNeeded];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kPNLiteContentViewWidth, self.frame.size.height);
    [self layoutIfNeeded];
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
}

#pragma mark PNLiteOrientationManagerDelegate

- (void)orientationManagerDidChangeOrientation
{
    [self.delegate contentInfoViewWidthNeedsUpdate:[NSNumber numberWithFloat: self.frame.size.width]];
}

@end
