// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

import Foundation
import AppTrackingTransparency

@objc
public class HyBidSDKConfig: NSObject {
    @objc public static let sharedConfig = HyBidSDKConfig()
    
    private override init() {}
    
    @objc public var test: Bool = false
    @objc public var reporting: Bool = false
    @objc public var atomEnabled: Bool = false
    @objc public var targeting: HyBidTargetingModel?
    @objc public var appToken: String?
    @objc public var apiURL: String {
        get {
            if #available(iOS 14, *) {
                if(ATTrackingManager.trackingAuthorizationStatus == .authorized){
                    return "https://server.pubnative.net"
                } else {
                    return "https://api.pubnative.net"
                }
            } else {
                return "https://api.pubnative.net"
            }
        }
        set {
        }
    }
    @objc public var openRtbApiURL: String = "https://dsp.pubnative.net"
    @objc public var appID: String?
    @objc public var customRemoteConfigURL: String?
}
