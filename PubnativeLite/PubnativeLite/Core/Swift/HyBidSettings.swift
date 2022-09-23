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

@objc
public class HyBidSettings: NSObject {
    
    @objc public static let sharedInstance = HyBidSettings()
    
    // CONFIGURABLE PARAMETERS
    @objc public var test: Bool = false
    @objc public var coppa: Bool = false
    @objc public var targeting: HyBidTargetingModel?
    @objc public var appToken: String?
    @objc public var apiURL: String?
    @objc public var openRtbApiURL: String?
    @objc public var appID: String?
    @objc public var videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_VIDEO_SKIP_OFFSET), isCustom: false)
    @objc public var htmlSkipOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_HTML_SKIP_OFFSET), isCustom: false)
    @objc public var endCardCloseOffset = HyBidSkipOffset(offset: NSNumber(value: DEFAULT_END_CARD_CLOSE_OFFSET), isCustom: false)
    @objc public var showEndCard: Bool = false {
        didSet {
            if !videoSkipOffset.isCustom {
                let skipOffset = showEndCard ? DEFAULT_VIDEO_SKIP_OFFSET : DEFAULT_SKIP_OFFSET_WITHOUT_ENDCARD
                videoSkipOffset = HyBidSkipOffset(offset: NSNumber(value: skipOffset), isCustom: false)
            }
        }
    }
    
    // Starting SDK version 2.15.1 we support multiple fidelities
    @objc public var supportMultipleFidelities: Bool = true
    @objc public var interstitialActionBehaviour: HyBidInterstitialActionBehaviour = HB_CREATIVE
    
    @objc public var interstitialCloseOnFinish: Bool = false
    @objc public var isInterstitialCloseOnFinishSet: Bool = false
    @objc public var rewardedCloseOnFinish: Bool = false
    @objc public var isRewardedCloseOnFinishSet: Bool = false
    @objc public var audioStatus: HyBidAudioStatus = HyBidAudioStatusMuted
    @objc public var mraidExpand: Bool = true
    @objc public var interstitialSKOverlay: Bool = false
    @objc public var rewardedSKOverlay: Bool = false
    @objc public var adFeedback: Bool = false
    @objc public var contentInfoURL: String?

    // COMMON PARAMETERS
    @objc public var advertisingId: String? {
        var result: String?
        if !self.coppa && (NSClassFromString("ASIdentifierManager") != nil) {
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
    
    @objc public var deviceName: String {
        let currentDevice = UIDevice.current
        return currentDevice.model
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
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return "portrait";
        case .landscapeLeft, .landscapeRight:
            return "landscape"
        default:
            return "none"
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
    
    @objc public var locationTrackingEnabled: Bool {
        return PNLiteLocationManager.locationTrackingEnabled()
    }
    
    @objc public var locationUpdatesEnabled: Bool {
        return PNLiteLocationManager.locationUpdatesEnabled()
    }
    
    @objc public var location: CLLocation? {
        var result: CLLocation? = nil
        if !self.coppa {
            result = PNLiteLocationManager.getLocation()
        }
        return result;
    }
    
    @objc public var identifierForVendor: String? {
        var result: String? = nil
        if !self.coppa {
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
    
    @objc public var bannerSKOverlay: Bool {
        return false
    }
    
    @objc public var appTrackingTransparency: NSNumber? {
        if #available(iOS 14, *) {
            return NSNumber(value: ATTrackingManager.trackingAuthorizationStatus.rawValue)
        }
        return nil
    }
}
