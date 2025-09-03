// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation

public typealias ReportingKey = String

@objc
public class HyBidReportingEvent: NSObject {
    
    @objc public var properties: [ReportingKey: Any]? = [:]
    @objc public var eventType: String
    
    @objc
    public init(with eventType: String, adFormat: String? = nil, properties: [ReportingKey: Any]? = nil) {
        self.eventType = eventType
        self.properties = properties ?? [:]
        self.properties?[Common.EVENT_TYPE] = eventType
        self.properties?[Common.AD_FORMAT] = adFormat
        self.properties?[Common.TIMESTAMP] = String(Date().timeIntervalSince1970 * 1000.0)
    }
    
    @objc
    public init(with eventType: String, errorMessage: String? = nil, properties: [ReportingKey: Any]? = nil) {
        self.eventType = eventType
        self.properties = properties ?? [:]
        self.properties?[Common.EVENT_TYPE] = eventType
        self.properties?[Common.ERROR_MESSAGE] = errorMessage
        self.properties?[Common.TIMESTAMP] = String(Date().timeIntervalSince1970 * 1000.0)
    }
    
    public func propertiesValue() -> String {
        guard var properties = properties else {
            return ""
        }
        
        if let beacons = properties[VASTBeacon.BEACONS] as? Array<HyBidDataModel> {
            let codableBeacons = beacons.map({ return $0.dictionary })
            properties[VASTBeacon.BEACONS] = codableBeacons
        }
        
        return "\(properties)"
    }
}
