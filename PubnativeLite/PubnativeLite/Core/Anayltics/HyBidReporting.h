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

@interface HyBidReportingCommon : NSObject

@property (class, nonatomic, readonly) NSString *AD_FORMAT;
@property (class, nonatomic, readonly) NSString *AD_SIZE;
@property (class, nonatomic, readonly) NSString *CATEGORY_ID;
@property (class, nonatomic, readonly) NSString *CAMPAIGN_ID;
@property (class, nonatomic, readonly) NSString *EVENT_TYPE;
@property (class, nonatomic, readonly) NSString *CREATIVE_TYPE;
@property (class, nonatomic, readonly) NSString *TIMESTAMP;

@end

@interface HyBidReportingEventType : NSObject

@property (class, nonatomic, readonly) NSString *AD_REQUEST;
@property (class, nonatomic, readonly) NSString *IMPRESSION;
@property (class, nonatomic, readonly) NSString *CLICK;
@property (class, nonatomic, readonly) NSString *ERROR;
@property (class, nonatomic, readonly) NSString *INTERSTITIAL_CLOSED;
@property (class, nonatomic, readonly) NSString *VIDEO_STARTED;
@property (class, nonatomic, readonly) NSString *VIDEO_DISMISSED;
@property (class, nonatomic, readonly) NSString *VIDEO_FINISHED;
@property (class, nonatomic, readonly) NSString *VIDEO_MUTE;
@property (class, nonatomic, readonly) NSString *VIDEO_UNMUTE;

@property (class, nonatomic, readonly) NSString *AD_SESSION_INITIALIZED;
@property (class, nonatomic, readonly) NSString *AD_SESSION_LOADED;
@property (class, nonatomic, readonly) NSString *AD_SESSION_STARTED;
@property (class, nonatomic, readonly) NSString *AD_SESSION_STOPPED;

@property (class, nonatomic, readonly) NSString *VIDEO_AD_FIRST_QUARTILE;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_MIDPOINT;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_THIRD_QUARTILE;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_COMPLETE;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_PAUSE;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_RESUME;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_BUFFER_START;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_BUFFER_FINISH;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_VOLUME_CHANGE;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_SKIPPED;
@property (class, nonatomic, readonly) NSString *VIDEO_AD_CLICKED;

@end

@interface HyBidReportingCreativeType : NSObject

@property (class, nonatomic, readonly) NSString *STANDARD;
@property (class, nonatomic, readonly) NSString *VIDEO;

@end

@interface HyBidReportingAdFormat : NSObject

@property (class, nonatomic, readonly) NSString *NATIVE;
@property (class, nonatomic, readonly) NSString *BANNER;
@property (class, nonatomic, readonly) NSString *FULLSCREEN;
@property (class, nonatomic, readonly) NSString *REWARDED;

@end
