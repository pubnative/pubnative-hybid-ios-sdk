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

#import "PNLiteMRAIDResizeProperties.h"

@implementation PNLiteMRAIDResizeProperties

- (id)init {
    self = [super init];
    if (self) {
        _width = 0;
        _height = 0;
        _offsetX = 0;
        _offsetY = 0;
        _customClosePosition = PNLiteMRAIDCustomClosePositionTopRight;
        _allowOffscreen = YES;
    }
    return self;
}

+ (PNLiteMRAIDCustomClosePosition)MRAIDCustomClosePositionFromString:(NSString *)s {
    NSArray *names = @[
                       @"top-left",
                       @"top-center",
                       @"top-right",
                       @"center",
                       @"bottom-left",
                       @"bottom-center",
                       @"bottom-right"
                       ];
    NSUInteger i = [names indexOfObject:s];
    if (i != NSNotFound) {
        return (PNLiteMRAIDCustomClosePosition)i;
    }
    // Use top-right for the default value
    return PNLiteMRAIDCustomClosePositionTopRight;;
}

@end
