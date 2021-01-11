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
public class ReportingProperties: NSObject {
}

@objc(ReportingPropertiesCommon)
public class Common: ReportingProperties {
    @objc public static let AD_FORMAT = "ad_format"
    @objc public static let AD_SIZE = "ad_size"
    @objc public static let CATEGORY_ID = "category_id"
    @objc public static let CAMPAIGN_ID = "campaign_id"
    @objc public static let EVENT_TYPE = "event_type"
    @objc public static let CREATIVE_TYPE = "creative_type"
    @objc public static let TIMESTAMP = "timestamp"
}

@objc(ReportingPropertiesEventType)
public class EventType: ReportingProperties  {
    @objc public static let IMPRESSION = "impression"
    @objc public static let CLICK = "click"
    @objc public static let INTERSTITIAL_CLOSED = "interstitial_closed"
    @objc public static let VIDEO_STARTED = "video_started"
    @objc public static let VIDEO_DISMISSED = "video_dismissed"
    @objc public static let VIDEO_FINISHED = "video_finished"
    @objc public static let VIDEO_MUTE = "video_mute"
    @objc public static let VIDEO_UNMUTE = "video_unmute"
}

@objc(ReportingPropertiesCreativeType)
public class CreativeType: ReportingProperties  {
    @objc public static let STANDARD = "standard"
    @objc public static let VIDEO = "video"
}

@objc(ReportingPropertiesAdFormat)
public class AdFormat: ReportingProperties  {
    @objc public static let NATIVE = "native"
    @objc public static let BANNER = "banner"
    @objc public static let FULLSCREEN = "fullscreen"
    @objc public static let REWARDED = "rewarded"
}
