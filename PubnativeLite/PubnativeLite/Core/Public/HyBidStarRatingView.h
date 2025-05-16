// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

typedef BOOL(^PNLiteStarRatingViewShouldBeginGestureRecognizerBlock)(UIGestureRecognizer *gestureRecognizer);

IB_DESIGNABLE
@interface HyBidStarRatingView : UIControl
@property (nonatomic) IBInspectable NSUInteger maximumValue;
@property (nonatomic) IBInspectable CGFloat minimumValue;
@property (nonatomic) IBInspectable CGFloat value;
@property (nonatomic) IBInspectable CGFloat spacing;
@property (nonatomic) IBInspectable BOOL allowsHalfStars;
@property (nonatomic) IBInspectable BOOL accurateHalfStars;
@property (nonatomic) IBInspectable BOOL continuous;

@property (nonatomic) BOOL shouldBecomeFirstResponder;

// Optional: if `nil` method will return `NO`.
@property (nonatomic, copy) PNLiteStarRatingViewShouldBeginGestureRecognizerBlock shouldBeginGestureRecognizerBlock;

@property (nonatomic, strong) IBInspectable UIColor *starBorderColor;
@property (nonatomic) IBInspectable CGFloat starBorderWidth;
@property (nonatomic, strong) IBInspectable UIColor *emptyStarColor;
@property (nonatomic, strong) IBInspectable UIImage *emptyStarImage;
@property (nonatomic, strong) IBInspectable UIImage *halfStarImage;
@property (nonatomic, strong) IBInspectable UIImage *filledStarImage;
@end
