// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLitePropertyAnimation.h"

@class PNLiteProgressLabel;

typedef void(^pnprogressLabelValueChangedCompletion)(PNLiteProgressLabel *label, CGFloat progress);
typedef CGFloat(^pnradiansFromDegreesCompletion)(CGFloat degrees);

typedef NS_ENUM(NSUInteger, PNLiteProgressLabelColorTable) {
    PNLiteColorTable_ProgressLabelFillColor,
    PNLiteColorTable_ProgressLabelTrackColor,
    PNLiteColorTable_ProgressLabelProgressColor
};

@interface PNLiteProgressLabel : UILabel

@property (nonatomic, copy) pnprogressLabelValueChangedCompletion progressLabelVCBlock;

@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat startDegree;
@property (nonatomic, assign) CGFloat endDegree;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, copy) NSDictionary *colorTable;

@property (nonatomic, assign) BOOL clockWise;

NSString *NSStringFromPNProgressLabelColorTableKey(PNLiteProgressLabelColorTable tableColor);
UIColor *UIColorDefaultForColorInPNProgressLabelColorTableKey(PNLiteProgressLabelColorTable tableColor);

// Progress is a float between 0.0 and 1.0
- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress timing:(PNLitePropertyAnimationTiming)timing duration:(CGFloat) duration delay:(CGFloat)delay;

@end
