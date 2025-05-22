// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import UIKit

@objc
public class HyBidReportingVASTTracker:  NSObject {
    
    @objc public var properties: [ReportingKey: Any]? = [:]
    @objc public var trackerType: String
    
    @objc
    public init(with trackerType: String, properties: [ReportingKey: Any]? = nil) {
        self.trackerType = trackerType
        self.properties = properties ?? [:]
        self.properties?[Common.VAST_TRACKER_TYPE] = trackerType
        self.properties?[Common.TIMESTAMP] = String(Date().timeIntervalSince1970 * 1000.0)
    }
}
