//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import <Foundation/Foundation.h>

typedef struct HyBidAdSizeStruct HyBidAdSize;

struct HyBidAdSizeStruct {
    NSInteger width;            ///< The ad width. Don't modify this value directly.
    NSInteger height;           ///< The ad height. Don't modify this value directly.
    NSString *adLayoutSize;     ///< The ad layout. Don't modify this value directly
};

extern HyBidAdSize const SIZE_320x50;
extern HyBidAdSize const SIZE_300x250;
extern HyBidAdSize const SIZE_300x50;
extern HyBidAdSize const SIZE_320x480;
extern HyBidAdSize const SIZE_1024x768;
extern HyBidAdSize const SIZE_768x1024;
extern HyBidAdSize const SIZE_728x90;
extern HyBidAdSize const SIZE_160x600;
extern HyBidAdSize const SIZE_250x250;
extern HyBidAdSize const SIZE_300x600;
extern HyBidAdSize const SIZE_320x100;
extern HyBidAdSize const SIZE_480x320;
extern HyBidAdSize const SIZE_INTERSTITIAL;
extern HyBidAdSize const SIZE_NATIVE;
