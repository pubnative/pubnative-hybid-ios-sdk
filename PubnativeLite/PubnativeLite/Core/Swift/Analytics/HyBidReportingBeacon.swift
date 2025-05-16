// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

@objc
public class HyBidReportingBeacon: NSObject {
    
    @objc public var properties: [ReportingKey: Any]? = [:]
    @objc public var beaconType: String
    
    @objc
    public init(with beaconType: String, properties: [ReportingKey: Any]? = nil) {
        self.beaconType = beaconType
        self.properties = properties ?? [:]
        self.properties?[Common.BEACON_TYPE] = beaconType
        self.properties?[Common.TIMESTAMP] = String(Date().timeIntervalSince1970 * 1000.0)
    }
}

