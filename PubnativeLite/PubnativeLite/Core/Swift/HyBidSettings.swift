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
import AVFoundation
import AppTrackingTransparency
import AdSupport
import CoreLocation
import CoreBluetooth
import CoreTelephony
import Network
import SystemConfiguration
import AdSupport

@objc
public class HyBidSettings: NSObject, CLLocationManagerDelegate {
    
    @objc public static let sharedInstance = HyBidSettings()
    private var locationManager: CLLocationManager?
    
    override init(){
        super.init()
    }
    
    // Starting SDK version 2.15.1 we support multiple fidelities
    @objc public var supportMultipleFidelities: Bool = true

    // COMMON PARAMETERS
    @objc public var advertisingId: String? {
        var result: String?
        if !HyBidConsentConfig.sharedConfig.coppa && (NSClassFromString("ASIdentifierManager") != nil) {
            if #available(iOS 14, *) {
                if #available(iOS 14.5, *) {
                    if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                        result = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    }
                } else {
                    if ATTrackingManager.trackingAuthorizationStatus == .authorized
                        || ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                        result = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    }
                }
            } else {
                if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                    result = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                }
            }
        }
        return result
    }
    
    @objc public var os: String {
        let currentDevice = UIDevice.current
        return currentDevice.systemName
    }
    
    @objc public var osVersion: String {
        let currentDevice = UIDevice.current
        return currentDevice.systemVersion
    }
    
    @objc public var deviceModel: String {
        let currentDevice = UIDevice.current
        return currentDevice.model
    }
    
    @objc public var deviceModelIdentifier: String {
        return UIDevice.modelName
    }
    
    @objc public var deviceMake: String {
        return "Apple"
    }
    
    @objc public var deviceType: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "4"
        case .pad:
            return "5"
        case .tv:
            return "3"
        case .carPlay:
            return "-1"
        case .unspecified:
            return "-1"
        case .mac:
            return "2"
        @unknown default:
            return "-1"
        }
    }
    
    @objc public var screenHeightInPixelss: String {
        let scale = UIScreen.main.scale
        let screenHeightInPoints = UIScreen.main.bounds.height
        let screenHeightInPixels = screenHeightInPoints * scale
        return String(Int(screenHeightInPixels))
    }
    
    @objc public var screenWidthInPixels: String {
        let scale = UIScreen.main.scale
        let screenWidth = UIScreen.main.bounds.size.width
        let screenWidthInPixels = screenWidth * scale
        return String(Int(screenWidthInPixels))
    }
    
    @objc public var pxRatio: String {
        let pixelRatio = UIScreen.main.scale
        return String(format: "%.3f", pixelRatio)
    }

    @objc public var language: String? {
        if let languageTag = Locale.preferredLanguages.first,
            let languageCode = Locale(identifier: languageTag).languageCode {
            return languageCode
        }
        return nil
    }
    
    @objc public var jsValue: String {
        return "1"
    }

    @objc public func geoFetchSupport() -> String {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()

            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                return "1"
            }
        }
        return "0"
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            print("Location permission denied")
        }
    }
    
    @objc public var languageBCP47: String? {
        let bcp47LanguageTag = Locale.preferredLanguages.first
        return bcp47LanguageTag
    }

    @objc public var carrierName: String? {
        let telephonyInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let subscribers = telephonyInfo.serviceSubscriberCellularProviders {
                for (_, carrier) in subscribers {
                    if let carrierName = carrier.carrierName {
                        return carrierName;
                    }
                }
            }
        }
        return nil
    }
    
    @objc public var carrierMCCMNC: String? {
        let telephonyInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            if let subscribers = telephonyInfo.serviceSubscriberCellularProviders {
                for (_, carrier) in subscribers {
                    if let mnc = carrier.mobileNetworkCode, !mnc.isEmpty,
                       let mcc = carrier.mobileCountryCode, !mcc.isEmpty {
                        let mccMncCode = "\(mcc)\(mnc)"
                        return mccMncCode
                    }
                }
            }
        }
        return nil
    }

    @available(iOS 14.1, *)
    @objc public var connectionType: String {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else {
            return "0"
        }

        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)

        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)

        if isReachable {
            if isWWAN {
                let networkInfo = CTTelephonyNetworkInfo()
                
                guard let carrierType = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else {
                    return "3"
                }

                switch carrierType {
                case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                    return "4"
                case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
                    return "5"
                case CTRadioAccessTechnologyLTE:
                    return "6"
                case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
                    return "7"
                default:
                    return "3"
                }
            } else {
                return "2"
            }
        } else {
            return "0"
        }
    }

    func getOrientationIndependentScreenSize() -> CGSize {
        return CGSize(width: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height), height: max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height))
    }
    
    @objc public var deviceWidth: String {
        return String(format: "%.0f", getOrientationIndependentScreenSize().width)
    }
    
    @objc public var deviceHeight: String {
        return String(format: "%.0f", getOrientationIndependentScreenSize().height)
    }
    
    @objc public var orientation: String {
        if Thread.isMainThread {
            let orientation = UIApplication.shared.statusBarOrientation
            switch orientation {
            case .portrait, .portraitUpsideDown:
                return "portrait"
            case .landscapeLeft, .landscapeRight:
                return "landscape"
            default:
                return "none"
            }
        } else {
            return DispatchQueue.main.sync {
                let orientation = UIApplication.shared.statusBarOrientation
                switch orientation {
                case .portrait, .portraitUpsideDown:
                    return "portrait"
                case .landscapeLeft, .landscapeRight:
                    return "landscape"
                default:
                    return "none"
                }
            }
        }
    }
    
    @objc public var deviceSound: String {
        if AVAudioSession.sharedInstance().outputVolume == 0 {
            return "0"
        }
        return "1"
    }
    
    @objc public var audioVolumePercentage: NSNumber {
        return NSNumber(value:  AVAudioSession.sharedInstance().outputVolume)
    }
    
    @objc public var locale: String? {
        return Locale.current.languageCode
    }
    
    @objc public var sdkVersion: String?
    
    @objc public var appBundleID: String? {
        return Bundle.main.bundleIdentifier
    }
    
    @objc public var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    @objc public var isDeviceCharging: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryState = UIDevice.current.batteryState
        
        switch batteryState {
            case .charging, .full:
                return "1"
            default:
                return "0"
        }
    }
    
    @objc public var batteryLevel: String? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryPercentage = UIDevice.current.batteryLevel * 100
        switch batteryPercentage {
        case 0..<5:
            return "1"
        case 5..<10:
            return "2"
        case 10..<25:
            return "3"
        case 25..<40:
            return "4"
        case 40..<55:
            return "5"
        case 55..<70:
            return "6"
        case 70..<85:
            return "7"
        case 85...100:
            return "8"
        default:
            return nil
        }
    }
    
    @objc public var batterySaver: String {
        return (ProcessInfo.processInfo.isLowPowerModeEnabled) ? "1" : "0"
    }
    
    @objc public var location: CLLocation? {
        var result: CLLocation? = nil
        if !HyBidConsentConfig.sharedConfig.coppa {
            result = PNLiteLocationManager.getLocation()
        }
        return result;
    }
    
    @objc public var identifierForVendor: String? {
        var result: String? = nil
        if !HyBidConsentConfig.sharedConfig.coppa {
            result = UIDevice.current.identifierForVendor?.uuidString
        }
        return result
    }
    
    @objc public var ip: String? {
        guard let url = URL(string: "https://api.ipify.org/") else {
            return nil
        }
        let ipAddress = try? String(contentsOf: url, encoding: .utf8)
        return ipAddress
    }
    
    @objc public var appTrackingTransparency: NSNumber? {
        if #available(iOS 14, *) {
            return NSNumber(value: ATTrackingManager.trackingAuthorizationStatus.rawValue)
        }
        return nil
    }
    
    @objc public var isDarkModeEnabled: String? {
        if #available(iOS 13.0, *) {
                return UITraitCollection.current.userInterfaceStyle == .dark ? "1" : "0"
        } else {
            return nil
        }
    }

    @objc public var isAirplaneModeEnabled: String? {
        if #available(iOS 12, *) {
            let networkInfo = CTTelephonyNetworkInfo()
            guard let radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology else {
                return nil
            }
            return radioAccessTechnology.isEmpty ? "1" : "0"
        }
        return nil
    }
}

public extension UIDevice {
  static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    func mapToDevice(identifier: String) -> String {
      #if os(iOS)
      switch identifier {
      case "iPod5,1":                                 return "iPod Touch 5"
      case "iPod7,1":                                 return "iPod Touch 6"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
      case "iPhone4,1":                               return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
      case "iPhone7,2":                               return "iPhone 6"
      case "iPhone7,1":                               return "iPhone 6 Plus"
      case "iPhone8,1":                               return "iPhone 6s"
      case "iPhone8,2":                               return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
      case "iPhone8,4":                               return "iPhone SE"
      case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":                return "iPhone X"
      case "iPhone11,2":                              return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
      case "iPhone11,8":                              return "iPhone XR"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
      case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
      case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
      case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
      case "iPad6,11", "iPad6,12":                    return "iPad 5"
      case "iPad7,5", "iPad7,6":                      return "iPad 6"
      case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
      case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
      case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
      case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
      case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
      case "AppleTV5,3":                              return "Apple TV"
      case "AppleTV6,2":                              return "Apple TV 4K"
      case "AudioAccessory1,1":                       return "HomePod"
      case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default:                                        return identifier
      }
      #elseif os(tvOS)
      switch identifier {
      case "AppleTV5,3": return "Apple TV 4"
      case "AppleTV6,2": return "Apple TV 4K"
      case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
      default: return identifier
      }
      #endif
    }
    
    return mapToDevice(identifier: identifier)
  }()

}
