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

#import "PNLiteImpressionTracker.h"
#import "PNLiteImpressionTrackerItem.h"
#import "HyBidVisibilityTracker.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSTimeInterval const kPNImpressionCheckPeriod = 0.25f; // Check every 250 ms
CGFloat const kPNVisibilityThreshold = 0.5f; // 50% of the view
CGFloat const kPNVisibilityImpressionTime = 1; // 1 second

@interface PNLiteImpressionTracker () <HyBidVisibilityTrackerDelegate>

@property (nonatomic, strong) NSMutableArray<PNLiteImpressionTrackerItem*> *visibleViews;
@property (nonatomic, strong) NSMutableArray<UIView*> *trackedViews;
@property (nonatomic, strong) HyBidVisibilityTracker *visibilityTracker;
@property (nonatomic, assign) BOOL isVisibiltyCheckScheduled;
@property (nonatomic, assign) BOOL isVisibiltyCheckValid;

@end

@implementation PNLiteImpressionTracker

- (void)dealloc {
    self.delegate = nil;
    [self.trackedViews removeAllObjects];
    self.trackedViews = nil;
    [self.visibleViews removeAllObjects];
    self.visibleViews = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.visibleViews = [NSMutableArray array];
        self.trackedViews = [NSMutableArray array];
        self.visibilityTracker = [[HyBidVisibilityTracker alloc] init];
        self.visibilityTracker.delegate = self;
        self.isVisibiltyCheckScheduled = NO;
        self.isVisibiltyCheckValid = NO;
    }
    return self;
}

- (void)addView:(UIView*)view {
    if (self.trackedViews) {
        if([self.trackedViews containsObject:view]) {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"View is already being tracked, dropping this call."];
        } else {
            [self.trackedViews addObject:view];
            [self.visibilityTracker addView:view withMinVisibility:kPNVisibilityThreshold];
        }
    }
}

- (void)removeView:(UIView*)view {
    if (self.visibilityTracker && self.trackedViews && [self.trackedViews containsObject:view]) {
        [self.visibilityTracker removeView:view];
        [self.trackedViews removeObject:view];
    }
}

- (void)clear {
    self.isVisibiltyCheckValid = NO;
    self.isVisibiltyCheckScheduled = NO;
    if (self.visibleViews) {
        [self.visibleViews removeAllObjects];
        self.visibleViews = nil;
    }
    if (self.visibilityTracker) {
        [self.visibilityTracker clear];
        self.visibilityTracker = nil;
    }
}

- (void)scheduleNextRun {
    if(self.isVisibiltyCheckValid && !self.isVisibiltyCheckScheduled) {
        self.isVisibiltyCheckScheduled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPNImpressionCheckPeriod * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(!self.delegate) {
                [self clear];
            } else if (self.trackedViews && self.trackedViews.count > 0) {
                [self checkVisibility];
            }
        });
        
    } else {
        self.isVisibiltyCheckValid = YES;
    }
}

- (void)checkVisibility {
    if(self.visibleViews) {
        for (int i = 0; i < [self.visibleViews count]; i++) {
            PNLiteImpressionTrackerItem* item = [self.visibleViews objectAtIndex: i];
            if (item && item.view ) {
                // It could happen that we've removed the view right when we're tracking, so we simply skip this item
                if(self.trackedViews && [self.trackedViews containsObject:item.view]) {
                    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
                    NSTimeInterval elapsedTime = currentTimestamp - item.timestamp;
                    if(kPNVisibilityImpressionTime <= elapsedTime) {
                        [self removeView:item.view];
                        [self invokeImpressionDetected:item.view];
                    }
                }
            } else {
                // We have emptied the visible views while going through It, so we leave this for
                break;
            }
        }
        self.isVisibiltyCheckScheduled = NO;
        if(self.visibleViews.count > 0) {
            [self scheduleNextRun];
        }
    }
}

- (NSInteger)indexOfVisibleView:(UIView*)view {
    NSInteger result = -1;
    if (self.visibleViews) {
        for (int index = 0; index< [self.visibleViews count]; index++) {
            PNLiteImpressionTrackerItem *item = self.visibleViews[index];
            if(item.view == view) {
                result = index;
                break;
            }
        }
    }
    return result;
}

#pragma mark Callback Helper

- (void)invokeImpressionDetected:(UIView*)view {
    if (self.delegate && [self.delegate respondsToSelector:@selector(impressionDetectedWithView:)]) {
        [self.delegate impressionDetectedWithView:view];
    }
}

#pragma mark HyBidVisibilityTrackerDelegate

- (void)checkVisibilityWithVisibleViews:(NSArray<UIView *> *)visibleViews andWithInvisibleViews:(NSArray<UIView *> *)invisibleViews {
    if(!self.delegate) {
        [self clear];
    } else {
        for (int i = 0; i < [visibleViews count]; i++) {
            UIView *visibleView = [visibleViews objectAtIndex: i];
            NSInteger index = [self indexOfVisibleView:visibleView];
            PNLiteImpressionTrackerItem *item;
            if(index < 0) {
                // First time it's visible, add it
                item = [[PNLiteImpressionTrackerItem alloc] init];
                item.view = visibleView;
                item.timestamp = [[NSDate date] timeIntervalSince1970];
                [self.visibleViews addObject:item];
            }
        }
        for (int i = 0; i < [invisibleViews count]; i++) {
            UIView *invisibleView = [invisibleViews objectAtIndex: i];
            NSInteger index = [self indexOfVisibleView:invisibleView];
            if(index >= 0) {
                [self.visibleViews removeObjectAtIndex:index];
            }
        }
        if (self.visibleViews.count > 0) {
            [self scheduleNextRun];
        }
    }
}

@end
