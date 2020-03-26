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

#import "HyBidAdSize.h"

@implementation HyBidAdSize

-(id)initWithWidth:(NSInteger)width height:(NSInteger)height adLayoutSize: (NSString*)adLayoutSize
{
     self = [super init];
     if (self) {
         self.width = width;
         self.height = height;
         self.adLayoutSize = adLayoutSize;
     }
     return self;
}

+(HyBidAdSize *)SIZE_320x50 {
    return  [[HyBidAdSize alloc]initWithWidth:320 height:50 adLayoutSize:@"s"];
}
+(HyBidAdSize *)SIZE_300x250 {
    return  [[HyBidAdSize alloc]initWithWidth:300 height:250 adLayoutSize:@"m"];
}
+(HyBidAdSize *)SIZE_300x50 {
    return  [[HyBidAdSize alloc]initWithWidth:300 height:50 adLayoutSize:@"s"];
}
+(HyBidAdSize *)SIZE_320x480 {
    return  [[HyBidAdSize alloc]initWithWidth:320 height:480 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_1024x768 {
    return  [[HyBidAdSize alloc]initWithWidth:1024 height:768 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_768x1024 {
    return  [[HyBidAdSize alloc]initWithWidth:768 height:1024 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_728x90 {
    return  [[HyBidAdSize alloc]initWithWidth:768 height:90 adLayoutSize:@"s"];
}
+(HyBidAdSize *)SIZE_160x600 {
    return  [[HyBidAdSize alloc]initWithWidth:160 height:600 adLayoutSize:@"m"];
}
+(HyBidAdSize *)SIZE_250x250 {
    return  [[HyBidAdSize alloc]initWithWidth:250 height:250 adLayoutSize:@"m"];
}
+(HyBidAdSize *)SIZE_300x600 {
    return  [[HyBidAdSize alloc]initWithWidth:300 height:600 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_320x100 {
    return  [[HyBidAdSize alloc]initWithWidth:320 height:100 adLayoutSize:@"s"];
}
+(HyBidAdSize *)SIZE_480x320 {
    return  [[HyBidAdSize alloc]initWithWidth:480 height:320 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_INTERSTITIAL {
    return  [[HyBidAdSize alloc]initWithWidth:0 height:0 adLayoutSize:@"l"];
}
+(HyBidAdSize *)SIZE_NATIVE {
    return  [[HyBidAdSize alloc]initWithWidth:-1 height:-1 adLayoutSize:@"native"];
}
@end
//
//const HyBidAdSize *SIZE_300x250 = {300, 250, @"m"};
//const HyBidAdSize *SIZE_300x50 = {300, 50, @"s"};
//const HyBidAdSize *SIZE_320x480 = {320, 480, @"l"};
//const HyBidAdSize *SIZE_1024x768 = {1024, 768, @"l"};
//const HyBidAdSize *SIZE_768x1024 = {768, 1024, @"l"};
//const HyBidAdSize *SIZE_728x90 = {728, 90, @"s"};
//const HyBidAdSize *SIZE_160x600 = {160, 600, @"m"};
//const HyBidAdSize *SIZE_250x250 = {250, 250, @"m"};
//const HyBidAdSize *SIZE_300x600 = {300, 600, @"l"};
//const HyBidAdSize *SIZE_320x100 = {320, 100, @"s"};
//const HyBidAdSize *SIZE_480x320 = {480, 320, @"l"};
//const HyBidAdSize *SIZE_INTERSTITIAL = {0, 0, @"l"};
//const HyBidAdSize *SIZE_NATIVE = {-1, -1, @"native"};
