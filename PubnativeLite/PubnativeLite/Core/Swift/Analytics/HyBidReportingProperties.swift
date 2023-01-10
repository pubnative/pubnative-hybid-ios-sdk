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

import Foundation

@objc
public class HyBidReportingProperties: NSObject {
}

@objc(HyBidReportingCommon)
public class Common: HyBidReportingProperties {
    @objc public static let AD_FORMAT = "ad_format"
    @objc public static let AD_SIZE = "ad_size"
    @objc public static let CATEGORY_ID = "category_id"
    @objc public static let CAMPAIGN_ID = "campaign_id"
    @objc public static let EVENT_TYPE = "event_type"
    @objc public static let CREATIVE_TYPE = "creative_type"
    @objc public static let TIMESTAMP = "timestamp"
    @objc public static let APPTOKEN = "app_token"
    @objc public static let ZONE_ID = "zone_id"
    @objc public static let INTEGRATION_TYPE = "integration_type"
    @objc public static let KEY_MEDIATION_VENDOR = "mediation_vendor"
    @objc public static let TIME_TO_LOAD = "time_to_load"
    @objc public static let AD_TYPE = "ad_type"
    @objc public static let CACHE_TIME = "cache_time"
    @objc public static let AD_REQUEST = "ad_request"
    @objc public static let AD_RESPONSE = "ad_response"
    @objc public static let RESPONSE_TIME = "response_time"
    @objc public static let RENDER_TIME = "render_time"
    @objc public static let AD_POSITION = "ad_position"
    @objc public static let ERROR_CODE = "error_code"
    @objc public static let ERROR_MESSAGE = "error_message"
    @objc public static let CREATIVE = "creative"
    @objc public static let HAS_END_CARD = "has_end_card"
    @objc public static let LAST_SESSION_TIMESTAMP = "last_session_timestamp"
    @objc public static let IMPRESSION_SESSION_COUNT = "impression_count"
    @objc public static let START_SESSION_TIMESTAMP = "start_session_timestamp"
    @objc public static let SESSION_DURATION = "session_duration"
    @objc public static let AGE_OF_APP = "age_of_app"
}

@objc(HyBidReportingEventType)
public class EventType: HyBidReportingProperties  {
    @objc public static let REQUEST = "request"
    @objc public static let IMPRESSION = "impression"
    @objc public static let OMID_IMPRESSION = "omid_impression"
    @objc public static let CLICK = "click"
    @objc public static let ERROR = "error"
    @objc public static let INTERSTITIAL_CLOSED = "interstitial_closed"
    @objc public static let VIDEO_STARTED = "video_started"
    @objc public static let VIDEO_DISMISSED = "video_dismissed"
    @objc public static let VIDEO_FINISHED = "video_finished"
    @objc public static let VIDEO_MUTE = "video_mute"
    @objc public static let VIDEO_UNMUTE = "video_unmute"
    @objc public static let AD_SESSION_INITIALIZED = "session_initialized"
    @objc public static let AD_SESSION_LOADED = "session_loaded"
    @objc public static let AD_SESSION_STARTED = "session_started"
    @objc public static let AD_SESSION_STOPPED = "session_stopped"
    @objc public static let VIDEO_AD_FIRST_QUARTILE = "first_quartile"
    @objc public static let VIDEO_AD_MIDPOINT = "midpoint"
    @objc public static let VIDEO_AD_THIRD_QUARTILE = "third_quartile"
    @objc public static let VIDEO_AD_COMPLETE = "ad_complete"
    @objc public static let VIDEO_AD_PAUSE = "pause"
    @objc public static let VIDEO_AD_RESUME = "resume"
    @objc public static let VIDEO_AD_BUFFER_START = "buffer_start"
    @objc public static let VIDEO_AD_BUFFER_FINISH = "buffer_finish"
    @objc public static let VIDEO_AD_VOLUME_CHANGE = "volume_change"
    @objc public static let VIDEO_AD_SKIPPED = "skipped"
    @objc public static let VIDEO_AD_CLICKED = "clicked"
    @objc public static let LOAD = "load"
    @objc public static let LOAD_FAIL = "load_fail"
    @objc public static let CACHE = "cache"
    @objc public static let RESPONSE = "response"
    @objc public static let RENDER = "render"
    @objc public static let RENDER_ERROR = "render_error"
    @objc public static let COMPANION_VIEW = "companion_view"
    @objc public static let REWARD = "reward"
    @objc public static let SESSION_REPORT_INFO = "session_report_info"
}

@objc(HyBidReportingCreativeType)
public class CreativeType: HyBidReportingProperties  {
    @objc public static let STANDARD = "standard"
    @objc public static let VIDEO = "video"
}

@objc(HyBidReportingAdFormat)
public class AdFormat: HyBidReportingProperties  {
    @objc public static let NATIVE = "native"
    @objc public static let BANNER = "banner"
    @objc public static let FULLSCREEN = "fullscreen"
    @objc public static let REWARDED = "rewarded"
}
