// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import CoreLocation
import AppTrackingTransparency

enum HyBidAppAuthorizationType: CaseIterable {
    case location
    case tracking
}

enum HyBidAppAuthorizationDetail: String {
    case fullAccuracy = "Full Accuracy"
    case reducedAccuracy = "Reduce Accuracy"
    case accuracyDisable = "Precise location is disabled"
    case unknown = "Unknown value"
    case invalidForiOSVersion = "Accuracy authorization invalid for the iOS version"
}

enum HyBidAppStatusAuthorization: String {
    case notDetermined = "Not Determined"
    case restricted = "Restricted"
    case denied = "Denied"
    case authorized = "Authorized"
    case authorizedAlways = "Authorized Always"
    case authorizedWhenInUse = "Authorized When In Use"
    case unknown = "Unknown value"
    case invalidForiOSVersion = "Invalid for the iOS version"
    
    func convertStatus(type:HyBidAppAuthorizationType, status: Any) -> HyBidAppStatusAuthorization {
        switch type {
        case .location:
            guard let status = status as? CLAuthorizationStatus else { return .unknown }
            switch status {
            case .notDetermined: return .notDetermined
            case .restricted: return .restricted
            case .denied: return .denied
            case .authorizedAlways: return .authorizedAlways
            case .authorizedWhenInUse: return .authorizedWhenInUse
            @unknown default: return .unknown
            }
        case .tracking:
            if #available(iOS 14, *) {
                guard let status = status as? ATTrackingManager.AuthorizationStatus else { return .unknown }
                switch status {
                case .notDetermined: return .notDetermined
                case .restricted: return .restricted
                case .denied: return .denied
                case .authorized: return .authorized
                @unknown default: return .unknown
                }
            } else {
                return .invalidForiOSVersion
            }
        }
    }
}

struct HyBidAppAuthorization {
    let type: HyBidAppAuthorizationType
    var status: HyBidAppStatusAuthorization = .unknown
    var details: [HyBidAppAuthorizationDetail] = []
    
    init(type: HyBidAppAuthorizationType) {
        self.type = type
        switch self.type {
        case .location:
            self.status = status.convertStatus(type: type, status: CLLocationManager.authorizationStatus())
            if #available(iOS 14.0, *) {                
                switch self.status {
                case .notDetermined, .denied, .unknown:
                    self.details.append(.accuracyDisable)
                default:
                    switch CLLocationManager().accuracyAuthorization {
                    case .fullAccuracy: self.details.append(.fullAccuracy)
                    case .reducedAccuracy: self.details.append(.reducedAccuracy)
                    @unknown default: self.details.append(.unknown)
                    }
                }
            } else {
                self.details.append(.invalidForiOSVersion)
            }
        case .tracking:
            if #available(iOS 14, *) {
                self.status = status.convertStatus(type: type, status: ATTrackingManager.trackingAuthorizationStatus)
            } else {
                self.status = .invalidForiOSVersion
            }
        }
    }
    
    func detailsString() -> String? {
        guard self.details.isEmpty == false else { return nil }
        let detailsValues: [HyBidAppAuthorizationDetail] = self.details.filter{ return $0 != .unknown }
        guard detailsValues.isEmpty == false else { return nil }
        let detailsString = detailsValues.map{ return $0.rawValue }
        return detailsString.joined(separator: ", ")
    }
}
