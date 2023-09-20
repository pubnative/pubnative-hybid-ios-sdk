//
//  Copyright © 2021 PubNative. All rights reserved.
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
#import "HyBidTimerState.h"

@protocol HyBidSkipOverlayDelegate <NSObject>

- (void)skipButtonTapped;
- (void)skipTimerCompleted;

@end

@interface HyBidSkipOverlay : UIView

- (id)initWithSkipOffset:(NSInteger)skipOffset withCountdownStyle:(HyBidCountdownStyle)countdownStyle withContentInfoPositionTopLeft:(BOOL)isContentInfoInTopLeftPosition withShouldShowSkipButton:(BOOL)shouldShowSkipButton;

- (void)addSkipOverlayViewIn:(UIView *)adView delegate:(id<HyBidSkipOverlayDelegate>)delegate withIsMRAID:(BOOL)isMRAID;
- (void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds withTimerState:(HyBidTimerState)timerState;
- (NSInteger)getRemainingTime;

@property (nonatomic, weak) NSObject<HyBidSkipOverlayDelegate> *delegate;
@property (nonatomic) NSInteger padding;
@property (nonatomic) BOOL isContentInfoInTopLeftPosition;
@property (nonatomic) BOOL isCloseButtonShown;
@property (nonatomic) BOOL shouldShowSkipButton;

@end
