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

#import "PNLitePropertyAnimation.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kRefreshRate 1.0/30.0

// Storage for singleton manager
@class PNLitePropertyAnimationManager;
static PNLitePropertyAnimationManager *__manager = nil;

// Manager declaration
@class PNLitePropertyAnimation;
@interface PNLitePropertyAnimationManager : NSObject {
    id timer;
    NSMutableArray *animations;
}
+ (PNLitePropertyAnimationManager*)manager;
- (NSArray*)allPropertyAnimationsForTarget:(id)target;
- (void)update:(id)sender;
- (void)addAnimation:(PNLitePropertyAnimation*)animation;
- (void)removeAnimation:(PNLitePropertyAnimation*)animation;
@end

@interface PNLitePropertyAnimation ()
@property (nonatomic, readonly) NSTimeInterval startTime;
@end

// Main class
@implementation PNLitePropertyAnimation
@synthesize target, delegate, keyPath, duration, timing, fromValue, toValue, chainedAnimation, startTime, startDelay;

- (id)initWithKeyPath:(NSString*)theKeyPath {
    if ( !(self = [super init]) ) return nil;
    keyPath = theKeyPath ;
    timing = PNLitePropertyAnimationTimingEaseInEaseOut;
    duration = 0.5;
    startDelay = 0.0;
    return self;
}

+ (PNLitePropertyAnimation*)propertyAnimationWithKeyPath:(NSString*)keyPath {
    return [[PNLitePropertyAnimation alloc] initWithKeyPath:keyPath] ;
}

+ (NSArray*)allPropertyAnimationsForTarget:(id)target {
    return [[PNLitePropertyAnimationManager manager] allPropertyAnimationsForTarget:target];
}

- (void)begin {
    startTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ( !fromValue ) {
        self.fromValue = [target valueForKey:keyPath];
    }
    
    [[PNLitePropertyAnimationManager manager] addAnimation:self];
}

- (void)beginWithTarget:(id)theTarget {
    self.target = theTarget;
    [self begin];
}

- (void)cancel {
    [[PNLitePropertyAnimationManager manager] removeAnimation:self];
}

@end

#pragma mark -
#pragma mark Timing

static inline CGFloat funcQuad(CGFloat ft, CGFloat f0, CGFloat f1) {
	return f0 + (f1 - f0) * ft * ft;
}

static inline CGFloat funcQuadInOut(CGFloat ft, CGFloat f0, CGFloat f1) {
    CGFloat a = ((f1 - f0)/2.0);
    if ( ft < 0.5 ) {
        return f0 + a * (2*ft)*(2*ft);
    } else {
        CGFloat b = ((2*ft) - 2);
        return f0 + a + ( a * (1 - (b*b)) );
    }
}

static inline CGFloat funcQuadOut(CGFloat ft, CGFloat f0, CGFloat f1) {
	return f0 + (f1 - f0) * (1.0 - (ft-1.0)*(ft-1.0));
}

#pragma mark -
#pragma mark Manager

@implementation PNLitePropertyAnimationManager

+ (PNLitePropertyAnimationManager*)manager {
    if ( !__manager ) {
        __manager = [[PNLitePropertyAnimationManager alloc] init];
    }
    return __manager;
}

- (NSArray*)allPropertyAnimationsForTarget:(id)target {
    NSMutableArray *result = [NSMutableArray array];
    if ( animations ) {
        for ( PNLitePropertyAnimation* animation in animations ) {
            if ( animation.target == target ) [result addObject:animation];
        }
    }
    return result;
}

- (void)addAnimation:(PNLitePropertyAnimation *)animation {
    if ( !animations ) {
        animations = [[NSMutableArray alloc] init];
    }
    
    [animations addObject:animation];
    
    if ( !timer ) {
        if ( NSClassFromString(@"CADisplayLink") != NULL ) {
            timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
            [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        } else {
            timer = [NSTimer scheduledTimerWithTimeInterval:kRefreshRate target:self selector:@selector(update:) userInfo:nil repeats:YES];
        }
    }
}

- (void)removeAnimation:(PNLitePropertyAnimation *)animation {
    [animations removeObject:animation];
    
    if ( [animations count] == 0 ) {
        [timer invalidate]; timer = nil;
        __manager = nil;
    }
}

- (void)dealloc {
    if ( timer ) [timer invalidate];
}

- (void)update:(id)sender {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    for ( PNLitePropertyAnimation *animation in [animations copy] ) {
        
        if ( now < animation.startTime + animation.startDelay ) continue; // Animation hasn't started yet
        
        // Calculate proportion of time through animation, and the corresponding position given the timing function
        NSTimeInterval time = (now - (animation.startTime+animation.startDelay)) / animation.duration;
        if ( time > 1.0 ) time = 1.0;
        
        CGFloat position = time;
        switch ( animation.timing ) {
            case PNLitePropertyAnimationTimingEaseIn:
                position = funcQuad(time, 0.0, 1.0);
                break;
            case PNLitePropertyAnimationTimingEaseOut:
                position = funcQuadOut(time, 0.0, 1.0);
                break;
            case PNLitePropertyAnimationTimingEaseInEaseOut:
                position = funcQuadInOut(time, 0.0, 1.0);
                break;                
            case PNLitePropertyAnimationTimingLinear:
            default:
                break;
        }
        
        // Determine interpolation between values given position
        id value = nil;
        if ( [animation.fromValue isKindOfClass:[NSNumber class]] ) {
            value = [NSNumber numberWithDouble:[animation.fromValue doubleValue] + (position*([animation.toValue doubleValue] - [animation.fromValue doubleValue]))];
        } else {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Unsupported property type %@", NSStringFromClass([animation.fromValue class])]];
        }
        
        // Apply new value
        if ( value ) {
            [animation.target setValue:value forKeyPath:animation.keyPath];
        }
        
        if ( time >= 1.0 ) {
            // Animation has finished. Notify delegate, fire chained animation if there is one, and remove
            if ( animation.delegate ) {
                [animation.delegate propertyAnimationDidFinish:animation];
            }
            if ( animation.chainedAnimation ) {
                [animation.chainedAnimation begin];
            }
            [self removeAnimation:animation];
        }
    }
}
@end
