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
#import "HyBidVASTAdType.h"
#import "HyBidXMLElementEx.h"
#import "HyBidVASTAdInline.h"
#import "HyBidVASTAdWrapper.h"

@interface HyBidVASTAd : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithXMLElement:(HyBidXMLElementEx *)xmlElement;

/**
 An optional string that identifies the type of ad
 */
- (HyBidVASTAdType)adType;

/**
 An ad server-defined identifier string for the ad
 */
- (NSString *)id;

/**
 A integer greater than zero (0) that identifies the sequence in which an ad should
 */
- (NSString *)sequence;

/**
 A Boolean that identifies a conditional ad
 [Deprecated in VAST 4.1, along with apiFramework]
 */
- (BOOL)isConditionalAd;

/**
 Within the nested elements of an <InLine> ad are all the files and URIs necessary to play and track the ad.
 */
- (HyBidVASTAdInline *)inLine;

/**
 VAST Wrappers are used to redirect the media player to another server for either an additional <Wrapper> or the VAST <InLine> ad.
 */
- (HyBidVASTAdWrapper *)wrapper;

@end
