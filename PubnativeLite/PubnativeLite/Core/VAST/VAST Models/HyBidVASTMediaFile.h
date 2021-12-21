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

@interface HyBidVASTMediaFile : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDocumentArray:(NSArray *)array atIndex: (int)index;

/**
 Either “progressive” for progressive download protocols (such as HTTP) or “streaming” for streaming protocols.
 */
- (NSString *)delivery;

/**
 MIME type for the file container. Popular MIME types include, but are not limited to “video/mp4” for MP4, “audio/mpeg” and "audio/aac" for audio ads.
 */
- (NSString *)type;

/**
 The native width of the video file, in pixels. (0 for audio ads)
 */
- (NSString *)width;

/**
 The native height of the video file, in pixels. (0 for audio ads)
 */
- (NSString *)height;

- (NSString *)url;

@end
