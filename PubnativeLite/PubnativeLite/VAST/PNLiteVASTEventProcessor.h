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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PNLiteVASTModel.h"

typedef enum : NSInteger {
    PNLiteVASTEvent_Start,
    PNLiteVASTEvent_FirstQuartile,
    PNLiteVASTEvent_Midpoint,
    PNLiteVASTEvent_ThirdQuartile,
    PNLiteVASTEvent_Complete,
    PNLiteVASTEvent_Close,
    PNLiteVASTEvent_Pause,
    PNLiteVASTEvent_Resume,
    PNLiteVASTEvent_Click,
    PNLiteVASTEvent_Unknown
} PNLiteVASTEvent;

@class PNLiteVASTEventProcessor;

@protocol PNLiteVASTEventProcessorDelegate <NSObject>

- (void)eventProcessorDidTrackEvent:(PNLiteVASTEvent)event;

@end

@interface PNLiteVASTEventProcessor : NSObject

// designated initializer, uses tracking events stored in VASTModel
- (id)initWithEvents:(NSDictionary *)events delegate:(id<PNLiteVASTEventProcessorDelegate>)delegate;
// sends the given VASTEvent
- (void)trackEvent:(PNLiteVASTEvent)event;
// sends the set of http requests to supplied URLs, used for Impressions, ClickTracking, and Errors.
- (void)sendVASTUrls:(NSArray *)urls;

@end
