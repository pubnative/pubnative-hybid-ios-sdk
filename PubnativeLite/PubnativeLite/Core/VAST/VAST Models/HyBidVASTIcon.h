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
#import "HyBidXMLElementEx.h"
#import "HyBidVASTStaticResource.h"
#import "HyBidVASTIconClicks.h"
#import "HyBidVASTIconClickTracking.h"
#import "HyBidVASTIconViewTracking.h"

@interface HyBidVASTIcon : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithIconXMLElement:(HyBidXMLElementEx *)iconXMLElement;

/**
 The program represented in the icon (e.g. "AdChoices").
 */
- (NSString *)program;

/**
 Pixel width of the icon asset.
 */
- (NSString *)width;

/**
 Pixel height of the icon asset.
 */- (NSString *)height;

/**
 The x-coordinate of the top, left corner of the icon asset relative to the ad display area.
 */
- (NSString *)xPosition;

/**
 The y-coordinate of the top left corner of the icon asset relative to the ad display area.
 */
- (NSString *)yPosition;

/**
 The duration the icon should be displayed unless clicked or ad is finished playing; provided in the format HH:MM:SS.mmm or HH:MM:SS where .mmm is milliseconds and optional.
 */
- (NSString *)duration;

/**
 The time of delay from when the associated linear creative begins playing to when the icon should be displayed; provided in the format HH:MM:SS.mmm or HH:MM:SS.
 */
- (NSString *)offset;

/**
 The pixel ratio for which the icon creative is intended.
 */
- (NSString *)pxRatio;

/**
 A URI for the tracking resource file to be called when the icon creative is displayed.
 */
- (NSArray<HyBidVASTIconViewTracking *> *)iconViewTracking;

/**
 A URI to the static creative file to be used for the ad component identified in the parent element.
 */
- (NSArray<HyBidVASTStaticResource *> *)staticResources;

/**
 The <IconClicks> element is a container for <IconClickThrough> and <ClickTracking>.
 */
- (HyBidVASTIconClicks *)iconClicks;

@end
