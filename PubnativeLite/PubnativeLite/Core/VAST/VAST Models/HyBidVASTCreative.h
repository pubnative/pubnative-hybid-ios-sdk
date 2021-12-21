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

#import <Foundation/Foundation.h>
#import "HyBidVASTUniversalAdId.h"
#import "HyBidVASTLinear.h"

@interface HyBidVASTCreative : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index;

/**
 A string used to identify the ad server that provides the creative
 */
- (NSString *)id;

/**
 Used to provide the ad server’s unique identifier for the creative
 */
- (NSString *)adID;

/**
 A number representing the numerical order in which each sequenced creative within an ad should play
 */
- (NSString *)sequence;

- (NSString *)apiFramework;

/**
 An array of strings identifying the unique creative identifier. Default value is “unknown”
 */
- (NSArray<HyBidVASTUniversalAdId *> *)universalAdIds;

/**
 Linear Ads are the video or audio formatted ads that play linearly within the streaming content
 */
- (HyBidVASTLinear *)linear;

@end
