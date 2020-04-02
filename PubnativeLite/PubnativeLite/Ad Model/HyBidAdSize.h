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

@interface HyBidAdSize: NSObject

@property (nonatomic, assign, readonly) NSInteger width;
@property (nonatomic, assign, readonly) NSInteger height;
@property (nonatomic, strong, readonly) NSString *layoutSize;

@property (class, nonatomic, readonly) HyBidAdSize *SIZE_320x50;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_300x250;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_300x50;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_320x480;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_1024x768;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_768x1024;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_728x90;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_160x600;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_250x250;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_300x600;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_320x100;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_480x320;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_INTERSTITIAL;
@property (class, nonatomic, readonly) HyBidAdSize *SIZE_NATIVE;

- (BOOL)isEqualTo:(HyBidAdSize *)hyBidAdSize;

@end

