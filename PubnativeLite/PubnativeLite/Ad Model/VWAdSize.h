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

/// You should consider this struct as an opaque type.
/// Never, ever, rely on size property of this struct - instead use
/// CGSizeFromVWAdSize and other methods defined below.
typedef struct {
  CGSize size;
  NSUInteger flags;
} VWAdSize;


#pragma mark Standard Sizes

/// 320 x 50 or device-width x 50
extern VWAdSize const kVWAdSizeBanner;

/// 300 x 250
extern VWAdSize const kVWAdSizeMediumRectangle;

/// 728 x 90
extern VWAdSize const kVWAdSizeLeaderboard;

/// Undefined
extern VWAdSize const kVWAdSizeUndefined;
