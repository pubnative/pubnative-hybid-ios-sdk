// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// Animation timing types
typedef enum {
    PNLitePropertyAnimationTimingLinear,
    PNLitePropertyAnimationTimingEaseIn,
    PNLitePropertyAnimationTimingEaseOut,
    PNLitePropertyAnimationTimingEaseInEaseOut
} PNLitePropertyAnimationTiming;

@interface PNLitePropertyAnimation : NSObject {    
    @private
    NSTimeInterval startTime;
}

// Create a new animation
+ (PNLitePropertyAnimation*)propertyAnimationWithKeyPath:(NSString*)keyPath;

// Get all animations for the given target object (if there are no animations, will return an empty array)
// You can then cancel all animations for a target by calling [[ALPropertyAnimation allPropertyAnimationsForTarget:object] makeObjectsPerformSelector:@selector(cancel)]
+ (NSArray*)allPropertyAnimationsForTarget:(id)target;

// Start the animation
- (void)beginWithTarget:(id)target;

// Cancel the animation
- (void)cancel;

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id target;
@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat startDelay;
@property (nonatomic, retain) id fromValue;
@property (nonatomic, retain) id toValue;
@property (nonatomic, assign) PNLitePropertyAnimationTiming timing;
@property (nonatomic, retain) PNLitePropertyAnimation *chainedAnimation;
@end

// Implement this to act as a delegate
@interface NSObject (ALPropertyAnimationDelegate)
- (void)propertyAnimationDidFinish:(PNLitePropertyAnimation*)propertyAnimation;
@end
