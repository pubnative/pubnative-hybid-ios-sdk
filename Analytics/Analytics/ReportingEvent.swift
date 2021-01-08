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

public typealias ReportingKey = String

@objc
public class ReportingProperties: NSObject {}

@objc
public class Common: ReportingProperties {
    @objc static let AD_FORMAT = "ad_format"
    @objc static let AD_SIZE = "ad_size"
    @objc static let CATEGORY_ID = "category_id"
    @objc static let CAMPAIGN_ID = "campaign_id"
    @objc static let EVENT_TYPE = "event_type"
    @objc static let CREATIVE_TYPE = "creative_type"
    @objc static let TIMESTAMP = "timestamp"
}

@objc
public class EventType: ReportingProperties  {
    @objc static let IMPRESSION = "impression"
    @objc static let CLICK = "click"
    @objc static let INTERSTITIAL_CLOSED = "interstitial_closed"
    @objc static let VIDEO_STARTED = "video_started"
    @objc static let VIDEO_DISMISSED = "video_dismissed"
    @objc static let VIDEO_FINISHED = "video_finished"
    @objc static let VIDEO_MUTE = "video_mute"
    @objc static let VIDEO_UNMUTE = "video_unmute"
}

@objc
public class CreativeType: ReportingProperties  {
    @objc static let STANDARD = "standard"
    @objc static let VIDEO = "video"
}

@objc
public class AdFormat: ReportingProperties  {
    @objc static let NATIVE = "native"
    @objc static let BANNER = "banner"
    @objc static let FULLSCREEN = "fullscreen"
    @objc static let REWARDED = "rewarded"
}

@objc
public class ReportingEvent: NSObject {
    
    @objc public var properties: [ReportingKey: String]
    
    public init(properties: [ReportingKey: String]) {
        self.properties = properties
        super.init()
    }
    
    @objc
    public func toJSON() -> String {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(properties) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return ""
    }
}
