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

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, AssetGroupType) {
    MRAID_320x50 = 10,
    MRAID_300x50 = 12,
    MRAID_300x250 = 8,
    MRAID_320x480 = 21,
    MRAID_1024x768 = 22,
    MRAID_768x1024 = 23,
    MRAID_728x90 = 24,
    MRAID_160x600 = 25,
    MRAID_250x250 = 26,
    MRAID_300x600 = 27,
    MRAID_320x100 = 28,
    MRAID_480x320 = 29,

    VAST_MRECT = 4,
    VAST_INTERSTITIAL = 15,
    VAST_REWARDED = 15,
    
    NON_DEFINED = 0
};
