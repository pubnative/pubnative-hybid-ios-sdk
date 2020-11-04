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

#import "AMCustomEventBanner.h"

@implementation AMCustomEventBanner

- (HyBidAdSize *)getHyBidAdSizeFromSize:(CGSize)size {
    if (size.width != 0 && size.height != 0) {
        if (size.height >= 1024) {
            if (size.width >= HyBidAdSize.SIZE_768x1024.width) {
                return HyBidAdSize.SIZE_768x1024;
            }
        } else if (size.height >= 768) {
            if (size.width >= HyBidAdSize.SIZE_1024x768.width) {
                return HyBidAdSize.SIZE_1024x768;
            }
        } else if (size.height >= 600) {
            if (size.width >= HyBidAdSize.SIZE_300x600.width) {
                return HyBidAdSize.SIZE_300x600;
            } else if (size.width >= HyBidAdSize.SIZE_160x600.width) {
                return HyBidAdSize.SIZE_160x600;
            }
        } else if (size.height >= 480) {
            if (size.width >= HyBidAdSize.SIZE_320x480.width) {
                return HyBidAdSize.SIZE_320x480;
            }
        } else if (size.height >= 320) {
            if (size.width >= HyBidAdSize.SIZE_480x320.width) {
                return HyBidAdSize.SIZE_480x320;
            }
        } else if (size.height >= 250) {
            if (size.width >= HyBidAdSize.SIZE_300x250.width) {
                return HyBidAdSize.SIZE_300x250;
            } else if (size.width >= HyBidAdSize.SIZE_250x250.width) {
                return HyBidAdSize.SIZE_250x250;
            }
        } else if (size.height >= 100) {
            if (size.width >= HyBidAdSize.SIZE_320x100.width) {
                return HyBidAdSize.SIZE_320x100;
            }
        } else if (size.height >= 90) {
            if (size.width >= HyBidAdSize.SIZE_728x90.width) {
                return HyBidAdSize.SIZE_728x90;
            }
        } else if (size.height >= 50) {
            if (size.width >= HyBidAdSize.SIZE_320x50.width) {
                return HyBidAdSize.SIZE_320x50;
            } else if (size.width >= HyBidAdSize.SIZE_300x50.width) {
                return HyBidAdSize.SIZE_300x50;
            }
        } else {
            return HyBidAdSize.SIZE_320x50;
        }
    }
    return [super getHyBidAdSizeFromSize:size];
}

@end
