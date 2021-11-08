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

typedef NSString * HyBidVASTAdTrackingEventType;

// Player Operation Metrics
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_mute;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_unmute;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_pause;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_resume;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_rewind;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_click;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_skip;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_playerExpand;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_playerCollapse;

// Linear Ad Metrics

extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_loaded;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_start;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_firstQuartile;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_midpoint;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_thirdQuartile;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_complete;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_otherAdInteraction;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_progress;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_closeLinear;

// Non Linear Ad Metrics
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_acceptInvitation;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_adExpand;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_adCollapse;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_minimize;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_close;
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_overlayViewDuration;

// Companign Ad Metrics
extern HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_creativeView;

