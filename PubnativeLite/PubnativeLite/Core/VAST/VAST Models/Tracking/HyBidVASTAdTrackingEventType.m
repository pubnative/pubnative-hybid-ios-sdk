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
#import "HyBidVASTAdTrackingEventType.h"

// Player Operation Metrics
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_mute = @"mute";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_unmute = @"unmute";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_pause = @"pause";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_resume = @"resume";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_rewind = @"rewind";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_click = @"click";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_skip = @"skip";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_expand = @"playerExpand";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_collapse = @"playerCollapse";

// Linear Ad Metrics
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_loaded = @"loaded";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_start = @"start";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_firstQuartile = @"firstQuartile";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_midpoint = @"midpoint";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_thirdQuartile = @"thirdQuartile";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_complete = @"complete";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_otherAdInteraction = @"otherAdInteraction";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_progress = @"progress";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_closeLinear = @"closeLinear";

// Non Linear Ad Metrics
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_acceptInvitation = @"acceptInvitation";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_adExpand = @"adExpand";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_adCollapse = @"adCollapse";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_minimize = @"minimize";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_close = @"close";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_overlayViewDuration = @"overlayViewDuration";

// Companion Ad Metrics
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_creativeView = @"creativeView";
HyBidVASTAdTrackingEventType const HyBidVASTAdTrackingEventType_ctaClick = @"CTAClick";

