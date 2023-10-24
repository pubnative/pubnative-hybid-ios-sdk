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
