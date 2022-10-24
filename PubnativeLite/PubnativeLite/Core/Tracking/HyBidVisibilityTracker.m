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

#import "HyBidVisibilityTracker.h"
#import "PNLiteVisibilityTrackerItem.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSTimeInterval const PNLiteVisibilityTrackerPeriod = 0.1f; // 100ms

@interface HyBidVisibilityTracker ()

@property (nonatomic, assign) BOOL isVisibilityScheduled;
@property (nonatomic, strong) NSMutableArray<PNLiteVisibilityTrackerItem *> *trackedItems;
@property (nonatomic, strong) NSMutableArray<UIView *> *visibleViews;
@property (nonatomic, strong) NSMutableArray<UIView *> *invisibleViews;
@property (nonatomic, strong) NSMutableArray<PNLiteVisibilityTrackerItem *> *removedItems;
@property (nonatomic, assign) BOOL isValid;

@end

@implementation HyBidVisibilityTracker

- (void)dealloc {
    self.isValid = NO;
    self.isVisibilityScheduled = NO;
    
    self.delegate = nil;
    [self.trackedItems removeAllObjects];
    self.trackedItems = nil;
    [self.visibleViews removeAllObjects];
    self.visibleViews = nil;
    [self.invisibleViews removeAllObjects];
    self.invisibleViews = nil;
    [self.removedItems removeAllObjects];
    self.removedItems = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isValid = YES;
        self.trackedItems = [NSMutableArray array];
        self.visibleViews = [NSMutableArray array];
        self.invisibleViews = [NSMutableArray array];
        self.removedItems = [NSMutableArray array];
    }
    return self;
}

- (void)addView:(UIView*)view withMinVisibility:(CGFloat)minVisibility {
    if(!view) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:@"View is nil and required, dropping this call."];
    } else if ([self isTrackingView:view]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:@"View is already being tracked, dropping this call."];
    } else {
        PNLiteVisibilityTrackerItem *item = [[PNLiteVisibilityTrackerItem alloc] init];
        item.view = view;
        item.minVisibility = minVisibility;
        if (self.trackedItems) {
            [self.trackedItems addObject:item];
            [self scheduleVisibilityCheck];
        }
    }
}

- (void)removeView:(UIView*)view {
    
}

- (void)clear {
    self.isValid = NO;
    if (self.trackedItems) {
        [self.trackedItems removeAllObjects];
    }
    self.isVisibilityScheduled = NO;
}

#pragma mark Tracking Views

- (BOOL)isTrackingView:(UIView*)view {
    return [self indexOfView:view] >= 0;
}

- (NSInteger)indexOfView:(UIView*)view {
    NSInteger result = -1;
    if (self.trackedItems) {
        for (int i = 0; i < self.trackedItems.count; i++) {
            PNLiteVisibilityTrackerItem *item = self.trackedItems[i];
            if (item != nil && view == item.view) {
                result = i;
                break;
            }
        }
    }
    return result;
}

#pragma mark Visibility Check

- (void)scheduleVisibilityCheck {
    if(self.isValid && !self.isVisibilityScheduled) {
        self.isVisibilityScheduled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, PNLiteVisibilityTrackerPeriod * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
          [self checkVisibility];
        });
    }
}

- (void)checkVisibility {
    if (self.trackedItems && self.visibleViews && self.invisibleViews) {
        for (int i = 0; i < [self.trackedItems count]; i++) {
            PNLiteVisibilityTrackerItem *item = [self.trackedItems objectAtIndex: i];
            // For safety we need to ensure that the view being tracked wasn't removed, in which case we stop tracking It
            if (item != nil) {
                if (!item.view || !item.view.superview) {
                    [self.removedItems addObject:item];
                } else if (![self.removedItems containsObject:item]) {
                    if([self isVisibleView:item.view]
                       && [self view:item.view visibleWithMinPercent:item.minVisibility]) {
                        [self.visibleViews addObject:item.view];
                    } else {
                        [self.invisibleViews addObject:item.view];
                    }
                }
            }
        }
    
    
        // We clear up all removed views
        for (int i = 0; i < [self.removedItems count]; i++) {
            PNLiteVisibilityTrackerItem *item = [self.removedItems objectAtIndex: i];
            
            if(item != nil) {
                [self.trackedItems removeObject:item];
            }
        }
        [self.removedItems removeAllObjects];
        
        [self invokeCheckVisibiltyWithVisibleViews:self.visibleViews andWithInvisibleViews:self.invisibleViews];
        [self.visibleViews removeAllObjects];
        [self.invisibleViews removeAllObjects];
        
        self.isVisibilityScheduled = NO;
        [self scheduleVisibilityCheck];
    }
}

#pragma mark Visibility Helpers

- (BOOL)isVisibleView:(UIView*)view {
    return (!view.hidden
            && ![self hasHiddenAncestorForView:view]
            && [self inersectsParentViewOfView:view]);
}

- (BOOL)hasHiddenAncestorForView:(UIView*)view {
    UIView *ancestor = view.superview;
    while (ancestor) {
        if (ancestor.hidden) return YES;
        ancestor = ancestor.superview;
    }
    return NO;
}

- (BOOL)inersectsParentViewOfView:(UIView*)view {
    UIWindow *parentWindow = [self parentWindowForView:view];
    
    if (!parentWindow) {
        return NO;
    }
    
    CGRect viewFrameInWindowCoordinates = [view.superview convertRect:view.frame toView:parentWindow];
    return CGRectIntersectsRect(viewFrameInWindowCoordinates, parentWindow.frame);
}

- (BOOL)view:(UIView*)view visibleWithMinPercent:(CGFloat)percentVisible {
    UIWindow *parentWindow = [self parentWindowForView:view];
    
    if (!parentWindow) {
        return NO;
    }
    
    // We need to call convertRect:toView: on this view's superview rather than on this view itself.
    CGRect viewFrameInWindowCoordinates = [view.superview convertRect:view.frame toView:parentWindow];
    CGRect intersection = CGRectIntersection(viewFrameInWindowCoordinates, parentWindow.frame);
    
    CGFloat intersectionArea = CGRectGetWidth(intersection) * CGRectGetHeight(intersection);
    CGFloat originalArea = CGRectGetWidth(view.bounds) * CGRectGetHeight(view.bounds);
    
    return intersectionArea >= (originalArea * percentVisible);
}

- (UIWindow*)parentWindowForView:(UIView*)view {
    UIView *ancestor = view.superview;
    while (ancestor) {
        if ([ancestor isKindOfClass:[UIWindow class]]) {
            return (UIWindow *)ancestor;
        }
        ancestor = ancestor.superview;
    }
    return nil;
}

#pragma mark Callback Helpers

- (void)invokeCheckVisibiltyWithVisibleViews:(NSArray<UIView*>*)visibleViews andWithInvisibleViews:(NSArray<UIView*>*)invisibleViews {
    if(self.delegate && [self.delegate respondsToSelector:@selector(checkVisibilityWithVisibleViews:andWithInvisibleViews:)]) {
        [self.delegate checkVisibilityWithVisibleViews:visibleViews andWithInvisibleViews:invisibleViews];
    }
}

@end
