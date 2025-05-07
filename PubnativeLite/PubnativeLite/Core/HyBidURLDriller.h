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

@protocol HyBidURLDrillerDelegate <NSObject>

@optional
- (void)didStartWithURL:(NSURL *)url;
- (void)didRedirectWithURL:(NSURL *)url;
- (void)didFinishWithURL:(NSURL *)url trackingType:(NSString *)trackingType;
- (void)didFailWithURL:(NSURL *)url andError:(NSError *)error;

@end

@interface HyBidURLDriller : NSObject

- (void)startDrillWithURLString:(NSString *)urlString
                       delegate:(NSObject<HyBidURLDrillerDelegate> *)delegate;
- (void)startDrillWithURLString:(NSString *)urlString
                       delegate:(NSObject<HyBidURLDrillerDelegate> *)delegate
               withTrackingType:(NSString *)trackingType;

@end

