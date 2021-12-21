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
#import "HyBidVASTAdParameters.h"
#import "HyBidVASTInteractiveCreativeFile.h"
#import "HyBidVASTVideoClick.h"
#import "HyBidVASTIcon.h"
#import "HyBidVASTTrackingEvent.h"
#import "HyBidVASTMediaFiles.h"
#import "HyBidVASTVideoClicks.h"

@interface HyBidVASTLinear : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index;

/**
 Time value that identifies when skip controls are made available to the end user.
 */
- (NSString *)skipOffset;

/**
 A time value for the duration of the Linear ad in the format HH:MM:SS.mmm (.mmm is optional and indicates milliseconds).
 */
- (NSString *)duration;

/**
 Metadata for the ad.
 */
- (HyBidVASTAdParameters *)adParameters;

/**
 The <VideoClicks> element provides URIs for clickthroughs, clicktracking, and custom clicks and is available for Linear Ads in both the InLine and Wrapper formats. 
 */
- (HyBidVASTVideoClicks *)videoClicks;

/**
 The <VideoClicks> element provides URIs for clickthroughs, clicktracking, and custom clicks and is available for Linear Ads in both the InLine and Wrapper formats.
 */
- (NSArray<HyBidVASTIcon *> *)icons;

- (HyBidVASTMediaFiles *)mediaFiles;

- (NSArray<HyBidVASTTrackingEvent *> *)trackingEvents;

@end
