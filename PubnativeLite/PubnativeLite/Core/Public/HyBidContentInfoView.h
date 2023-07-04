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
#import "HyBidVASTIconViewTracking.h"

@class HyBidContentInfoView;

typedef enum {
    HyBidContentInfoClickActionExpand,
    HyBidContentInfoClickActionOpen
} HyBidContentInfoClickAction;

typedef enum {
    HyBidContentInfoDisplayInApp,
    HyBidContentInfoDisplaySystem
} HyBidContentInfoDisplay;

typedef enum {
    HyBidContentInfoHorizontalPositionLeft,
    HyBidContentInfoHorizontalPositionRight
} HyBidContentInfoHorizontalPosition;

typedef enum {
    HyBidContentInfoVerticalPositionTop,
    HyBidContentInfoVerticalPositionBottom
} HyBidContentInfoVerticalPosition;

@protocol HyBidContentInfoViewDelegate<NSObject>

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width;

@end

@interface HyBidContentInfoView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSArray<HyBidVASTIconViewTracking *> *viewTrackers;
@property (nonatomic, weak) NSObject <HyBidContentInfoViewDelegate> *delegate;
@property (nonatomic) HyBidContentInfoClickAction clickAction;
@property (nonatomic) HyBidContentInfoDisplay display;
@property (nonatomic) HyBidContentInfoHorizontalPosition horizontalPosition;
@property (nonatomic) HyBidContentInfoVerticalPosition verticalPosition;

- (void)setIconSize:(CGSize) size;
- (void)setElementsOrientation:(HyBidContentInfoHorizontalPosition) orientation;
- (CGSize)getValidIconSizeWith:(CGSize)size;

@end
