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

#import "HyBidReporting.h"

@implementation HyBidReportingCommon

+ (NSString *)AD_FORMAT { return @"ad_format"; }
+ (NSString *)AD_SIZE { return @"ad_size"; }
+ (NSString *)CATEGORY_ID { return @"category_id"; }
+ (NSString *)CAMPAIGN_ID { return @"campaign_id"; }
+ (NSString *)EVENT_TYPE { return @"event_type"; }
+ (NSString *)CREATIVE_TYPE { return @"creative_type"; }
+ (NSString *)TIMESTAMP { return @"timestamp"; }
+ (NSString *)APPTOKEN { return @"app_token"; }
+ (NSString *)ZONE_ID { return @"zone_id"; }
+ (NSString *)INTEGRATION_TYPE { return @"integration_type"; }
+ (NSString *)TIME_TO_LOAD { return @"time_to_load"; }
+ (NSString *)AD_TYPE { return @"ad_type"; }
+ (NSString *)CACHE_TIME { return @"cache_time"; }
+ (NSString *)AD_REQUEST { return @"ad_request"; }
+ (NSString *)AD_RESPONSE { return @"ad_response"; }
+ (NSString *)RESPONSE_TIME { return @"response_time"; }
+ (NSString *)RENDER_TIME { return @"render_time"; }
+ (NSString *)AD_POSITION { return @"ad_position"; }
+ (NSString *)ERROR_CODE { return @"error_code"; }
+ (NSString *)ERROR_MESSAGE { return @"error_message"; }
+ (NSString *)CREATIVE { return @"creative"; }

@end

@implementation HyBidReportingEventType

+ (NSString *)AD_REQUEST { return @"ad_request"; }
+ (NSString *)IMPRESSION { return @"impression"; }
+ (NSString *)OMID_IMPRESSION { return @"omid_impression"; }
+ (NSString *)CLICK { return @"click"; }
+ (NSString *)ERROR { return @"error"; }
+ (NSString *)INTERSTITIAL_CLOSED { return @"interstitial_closed"; }
+ (NSString *)VIDEO_STARTED { return @"video_started"; }
+ (NSString *)VIDEO_DISMISSED { return @"video_dismissed"; }
+ (NSString *)VIDEO_FINISHED { return @"video_finished"; }
+ (NSString *)VIDEO_MUTE { return @"video_mute"; }
+ (NSString *)VIDEO_UNMUTE { return @"video_unmute"; }

+ (NSString *)AD_SESSION_INITIALIZED { return @"session_initialized"; }
+ (NSString *)AD_SESSION_LOADED { return @"session_loaded"; }
+ (NSString *)AD_SESSION_STARTED { return @"session_started"; }
+ (NSString *)AD_SESSION_STOPPED { return @"session_stopped"; }

+ (NSString *)VIDEO_AD_FIRST_QUARTILE { return @"first_quartile"; }
+ (NSString *)VIDEO_AD_MIDPOINT { return @"midpoint"; }
+ (NSString *)VIDEO_AD_THIRD_QUARTILE { return @"third_quartile"; }
+ (NSString *)VIDEO_AD_COMPLETE { return @"ad_complete"; }
+ (NSString *)VIDEO_AD_PAUSE { return @"pause"; }
+ (NSString *)VIDEO_AD_RESUME { return @"resume"; }
+ (NSString *)VIDEO_AD_BUFFER_START { return @"buffer_start"; }
+ (NSString *)VIDEO_AD_BUFFER_FINISH { return @"buffer_finish"; }
+ (NSString *)VIDEO_AD_VOLUME_CHANGE { return @"volume_change"; }
+ (NSString *)VIDEO_AD_SKIPPED { return @"skipped"; }
+ (NSString *)VIDEO_AD_CLICKED { return @"clicked"; }

+ (NSString *)LOAD { return @"load"; }
+ (NSString *)LOAD_FAIL { return @"load_fail"; }
+ (NSString *)CACHE { return @"cache"; }
+ (NSString *)RESPONSE { return @"response"; }
+ (NSString *)RENDER { return @"render"; }
+ (NSString *)RENDER_ERROR { return @"render_error"; }

@end

@implementation HyBidReportingCreativeType

+ (NSString *)STANDARD { return @"standard"; }
+ (NSString *)VIDEO { return @"video"; }

@end

@implementation HyBidReportingAdFormat

+ (NSString *)NATIVE { return @"native"; }
+ (NSString *)BANNER { return @"banner"; }
+ (NSString *)FULLSCREEN { return @"fullscreen"; }
+ (NSString *)REWARDED { return @"rewarded"; }

@end
