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
