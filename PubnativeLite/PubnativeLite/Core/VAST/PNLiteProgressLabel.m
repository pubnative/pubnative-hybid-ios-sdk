// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <QuartzCore/QuartzCore.h>
#import "PNLiteProgressLabel.h"

@implementation PNLiteProgressLabel {
    pnradiansFromDegreesCompletion _radiansFromDegrees;
}

#pragma mark Core

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    _radiansFromDegrees = ^(CGFloat degrees) {
        return (CGFloat)((degrees) / 180.0 * M_PI);
    };
    
    [self setBackgroundColor:[UIColor clearColor]];

    _borderWidth = 5;
    _startDegree = -90;
    _endDegree = -90;
    _progress = 0;
    _clockWise = YES;

    // This just warms the color table dictionary as the setter will populate with the default values immediately.
    [self colorTableDictionaryWarmer];
    [self squareDimensions];
}

- (void)drawRect:(CGRect)rect {
    [self drawProgressLabelCircleInRect:rect];
    [super drawTextInRect:rect];
}

- (void)setColorTable:(NSDictionary *)colorTable {

    // The Default values...
    NSMutableDictionary *mutableColorTable = [ @{
            @"fillColor": [UIColor clearColor],
            @"trackColor": [UIColor lightGrayColor],
            @"progressColor": [UIColor blackColor],
    } mutableCopy];

    // Overload with previous colors (in case they only want to change a single key color)
    if(!_colorTable) [mutableColorTable addEntriesFromDictionary:[_colorTable mutableCopy]];
    // Load in the new colors
    [mutableColorTable addEntriesFromDictionary:colorTable];

    _colorTable = [NSDictionary dictionaryWithDictionary:[mutableColorTable copy]];

    [self setNeedsDisplay];
}

// Set square frame.
- (void)squareDimensions {
    CGRect rect = self.frame;
    rect.size.height = self.frame.size.width;
    self.frame = rect;
}

#pragma mark - Public API
- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void)setStartDegree:(CGFloat)startDegree {
    _startDegree = startDegree - 90;
    [self setNeedsDisplay];
}

- (void)setEndDegree:(CGFloat)endDegree {
    _endDegree = endDegree - 90;
    _progress = endDegree/360;
    [self setNeedsDisplay];
}

- (void)setClockWise:(BOOL)clockWise {
    _clockWise = clockWise;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    if(_progress != progress) {

        _progress = progress;

        [self setStartDegree:0.0];
        [self setEndDegree:progress*360];

        PNLiteProgressLabel *__weak weakSelf = self;
        if(self.progressLabelVCBlock) {
            self.progressLabelVCBlock(weakSelf, progress);
        }
    }
}

- (void)setProgress:(CGFloat)progress timing:(PNLitePropertyAnimationTiming)timing duration:(CGFloat)duration delay:(CGFloat)delay {
    PNLitePropertyAnimation *animation = [PNLitePropertyAnimation propertyAnimationWithKeyPath:@"progress"];
    animation.fromValue = @(_progress);
    animation.toValue = @(progress);
    animation.duration = duration;
    animation.startDelay = delay;
    animation.timing = timing;
    [animation beginWithTarget:self];
}

#pragma mark -
#pragma mark Helpers
#pragma mark -

- (void)colorTableDictionaryWarmer {
    if(!self.colorTable || !self.colorTable[@"fillColor"]) {
        self.colorTable = [NSDictionary new];
    }
}

NSString *NSStringFromPNProgressLabelColorTableKey(PNLiteProgressLabelColorTable tableColor) {
    switch(tableColor) {
        case PNLiteColorTable_ProgressLabelFillColor: return @"fillColor";
        case PNLiteColorTable_ProgressLabelTrackColor: return @"trackColor";
        case PNLiteColorTable_ProgressLabelProgressColor: return @"progressColor";
        default: return nil;
    }
}

UIColor *UIColorDefaultForColorInPNProgressLabelColorTableKey(PNLiteProgressLabelColorTable tableColor) {
    switch(tableColor) {
        case PNLiteColorTable_ProgressLabelFillColor: return [UIColor clearColor];
        case PNLiteColorTable_ProgressLabelTrackColor: return [UIColor lightGrayColor];
        case PNLiteColorTable_ProgressLabelProgressColor: return [UIColor blackColor];
        default: return nil;
    }
}

- (void)drawProgressLabelCircleInRect:(CGRect)rect {
    [self colorTableDictionaryWarmer];

    UIColor *fillColor = self.colorTable[@"fillColor"];
    UIColor *trackColor = self.colorTable[@"trackColor"];
    UIColor *progressColor = self.colorTable[@"progressColor"];

    CGRect circleRect= [self rectForCircle:rect];

    CGFloat archXPos = rect.size.width/2;
    CGFloat archYPos = rect.size.height/2;
    CGFloat archRadius = (rect.size.width - _borderWidth) / 2.0;
    int clockWise = (_clockWise) ? 0 : 1;

    CGFloat trackStartAngle = _radiansFromDegrees(0);
    CGFloat trackEndAngle = _radiansFromDegrees(360);

    CGFloat progressStartAngle = _radiansFromDegrees(_startDegree);
    CGFloat progressEndAngle = _radiansFromDegrees(_endDegree);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // The Circle
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    CGContextSetLineWidth(context, _borderWidth);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextStrokePath(context);

    // Back border
    CGContextSetStrokeColorWithColor(context, trackColor.CGColor);
    CGContextSetLineWidth(context, _borderWidth-0.2);
    CGContextAddArc(context, archXPos,archYPos, archRadius, trackStartAngle, trackEndAngle, 1);
    CGContextStrokePath(context);

    // Top Border
    CGContextSetStrokeColorWithColor(context, progressColor.CGColor);

    // Adding 0.2 to fill it properly and reduce the noise.
    CGContextSetLineWidth(context, _borderWidth+0.2);
    CGContextAddArc(context, archXPos,archYPos, archRadius, progressStartAngle, progressEndAngle, clockWise);
    CGContextStrokePath(context);
}

- (CGRect)rectForCircle:(CGRect)rect {
    CGFloat circleRadius = (self.bounds.size.width / 2) - (_borderWidth * 2);
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    return CGRectMake(circleCenter.x - circleRadius, circleCenter.y - circleRadius, 2 * circleRadius, 2 * circleRadius);
}

@end
