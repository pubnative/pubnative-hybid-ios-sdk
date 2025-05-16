// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import CoreLocation

@objc
public class HyBidLocationConfig: NSObject {
    
    @objc public static let sharedConfig = HyBidLocationConfig()
    
    private override init() {
        PNLiteLocationManager.setLocationTrackingEnabled(true)
        PNLiteLocationManager.setLocationUpdatesEnabled(false)
    }
    
    @objc public var locationTrackingEnabled: Bool {
        get {
            return PNLiteLocationManager.locationTrackingEnabled()
        }
        set (enabled) {
            PNLiteLocationManager.setLocationTrackingEnabled(enabled)
        }
    }
    
    @objc public var locationUpdatesEnabled: Bool {
        get {
            return PNLiteLocationManager.locationUpdatesEnabled()
        }
        set (enabled) {
            PNLiteLocationManager.setLocationUpdatesEnabled(enabled)
        }
    }
}
